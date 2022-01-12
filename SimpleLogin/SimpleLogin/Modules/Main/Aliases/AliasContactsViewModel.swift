//
//  AliasContactsViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 20/11/2021.
//

import Combine
import SimpleLoginPackage
import SwiftUI

final class AliasContactsViewModel: ObservableObject {
    deinit {
        print("\(Self.self) is deallocated")
    }

    let alias: Alias

    @Published private(set) var isFetchingContacts = false
    @Published private(set) var isLoading = false
    @Published private(set) var isRefreshing = false
    @Published private(set) var contacts: [Contact]?
    @Published private(set) var error: SLClientError?

    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 0
    private var canLoadMorePages = true

    init(alias: Alias) {
        self.alias = alias
    }

    func handledError() {
        self.error = nil
    }

    func getMoreContactsIfNeed(session: Session, currentContact: Contact?) {
        guard let currentContact = currentContact, let contacts = contacts else {
            getMoreContacts(session: session)
            return
        }

        let thresholdIndex = contacts.index(contacts.endIndex, offsetBy: -1)
        if contacts.firstIndex(where: { $0.id == currentContact.id }) == thresholdIndex {
            getMoreContacts(session: session)
        }
    }

    private func getMoreContacts(session: Session) {
        guard !isFetchingContacts && canLoadMorePages else { return }
        isFetchingContacts = true
        session.client.getAliasContacts(apiKey: session.apiKey, id: alias.id, page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isFetchingContacts = false
                switch completion {
                case .finished: break
                case .failure(let error): self.error = error
                }
            } receiveValue: { [weak self] contactArray in
                guard let self = self else { return }
                if self.contacts == nil {
                    self.contacts = [Contact]()
                }
                self.contacts?.append(contentsOf: contactArray.contacts)
                self.currentPage += 1
                self.canLoadMorePages = contactArray.contacts.count == 20
            }
            .store(in: &cancellables)
    }

    func refresh(session: Session) {
        guard !isRefreshing else { return }
        isRefreshing = true
        session.client.getAliasContacts(apiKey: session.apiKey, id: alias.id, page: 0)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isRefreshing = false
                switch completion {
                case .finished: break
                case .failure(let error): self.error = error
                }
            } receiveValue: { [weak self] contactArray in
                guard let self = self else { return }
                self.contacts = contactArray.contacts
                self.currentPage = 1
                self.canLoadMorePages = contactArray.contacts.count == 20
            }
            .store(in: &cancellables)
    }

    func toggleContact(session: Session, contact: Contact) {
        guard !isLoading else { return }
        isLoading = true
        session.client.toggleContact(apiKey: session.apiKey, id: contact.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished: break
                case .failure(let error): self.error = error
                }
            } receiveValue: { [weak self] blockForward in
                guard let self = self else { return }
                self.update(contact: .init(id: contact.id,
                                           email: contact.email,
                                           creationTimestamp: contact.creationTimestamp,
                                           lastEmailSentTimestamp: contact.lastEmailSentTimestamp,
                                           reverseAlias: contact.reverseAlias,
                                           reverseAliasAddress: contact.reverseAliasAddress,
                                           existed: contact.existed,
                                           blockForward: blockForward.value))
            }
            .store(in: &cancellables)
    }

    func deleteContact(session: Session, contact: Contact) {
        guard !isLoading else { return }
        isLoading = true
        session.client.deleteContact(apiKey: session.apiKey, id: contact.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished: break
                case .failure(let error): self.error = error
                }
            } receiveValue: { [weak self] deletedResponse in
                guard let self = self else { return }
                if deletedResponse.value {
                    self.refresh(session: session)
                }
            }
            .store(in: &cancellables)
    }

    private func update(contact: Contact) {
        guard let index = contacts?.firstIndex(where: { $0.id == contact.id }) else { return }
        contacts?[index] = contact
    }
}