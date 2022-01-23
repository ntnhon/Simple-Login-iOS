//
//  MailboxesViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 13/01/2022.
//

import Combine
import SimpleLoginPackage
import SwiftUI

final class MailboxesViewModel: ObservableObject {
    deinit {
        print("\(Self.self) is deallocated")
    }

    @Published private(set) var mailboxes = [Mailbox]()
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    private var cancellables = Set<AnyCancellable>()

    func handledError() {
        error = nil
    }

    func refreshMailboxes(session: Session, isForced: Bool) {
        if !isForced, !mailboxes.isEmpty { return }
        isLoading = true
        session.client.getMailboxes(apiKey: session.apiKey)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished: break
                case .failure(let error): self.error = error.description
                }
            } receiveValue: { [weak self] mailboxArray in
                guard let self = self else { return }
                self.mailboxes = mailboxArray.mailboxes
            }
            .store(in: &cancellables)
    }

    func makeDefault(mailbox: Mailbox, session: Session) {
        guard !isLoading else { return }
        isLoading = true
        session.client.updateMailbox(apiKey: session.apiKey,
                                     id: mailbox.id,
                                     option: .default)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished: break
                case .failure(let error): self.error = error.description
                }
            } receiveValue: { [weak self] _ in
                self?.refreshMailboxes(session: session, isForced: true)
            }
            .store(in: &cancellables)
    }

    func delete(mailbox: Mailbox, session: Session) {
        guard !isLoading else { return }
        isLoading = true
        session.client.deleteMailbox(apiKey: session.apiKey, id: mailbox.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished: break
                case .failure(let error): self.error = error.description
                }
            } receiveValue: { [weak self] deletedResponse in
                guard let self = self else { return }
                if deletedResponse.value {
                    self.mailboxes.removeAll { $0.id == mailbox.id }
                }
            }
            .store(in: &cancellables)
    }

    func addMailbox(email: String, session: Session) {
        guard !isLoading else { return }
        isLoading = true
        session.client.createMailbox(apiKey: session.apiKey, email: email)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished: break
                case .failure(let error): self.error = error.description
                }
            } receiveValue: { [weak self] mailbox in
                guard let self = self else { return }
                self.mailboxes.append(mailbox)
            }
            .store(in: &cancellables)
    }
}