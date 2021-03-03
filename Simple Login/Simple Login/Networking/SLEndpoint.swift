//
//  SLEndpoint.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 29/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

extension URL {
    func append(path: String, queryItems: [URLQueryItem]? = nil) -> URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems

        // Safely force unwrap because constructing a new url
        // based on another url's elements (scheme, host) always succeed
        // swiftlint:disable:next force_unwrapping
        return components.url!
    }
}

extension URLRequest {
    mutating func addApiKeyToHeaders(_ apiKey: ApiKey) {
        addValue(apiKey.value, forHTTPHeaderField: "Authentication")
    }

    mutating func addJsonRequestBody(_ dict: [String: Any?]) {
        httpBody = try? JSONSerialization.data(withJSONObject: dict)
        addValue("application/json", forHTTPHeaderField: "Content-Type")
    }
}

enum HTTPMethod {
    static let delete = "DELETE"
    static let get = "GET"
    static let patch = "PATCH"
    static let post = "POST"
    static let put = "PUT"
}

enum SLEndpoint {
    case aliases(baseUrl: URL, apiKey: ApiKey, page: Int, searchTerm: String?)
    case aliasActivities(baseUrl: URL, apiKey: ApiKey, aliasId: Int, page: Int)
    case activateEmail(baseUrl: URL, email: String, code: String)
    case contacts(baseUrl: URL, apiKey: ApiKey, aliasId: Int, page: Int)
    case createAlias(baseUrl: URL, apiKey: ApiKey, aliasCreationRequest: AliasCreationRequest)
    case createContact(baseUrl: URL, apiKey: ApiKey, aliasId: Int, email: String)
    case createMailbox(baseUrl: URL, apiKey: ApiKey, email: String)
    case customDomains(baseUrl: URL, apiKey: ApiKey)
    case deleteAlias(baseUrl: URL, apiKey: ApiKey, aliasId: Int)
    case deleteContact(baseUrl: URL, apiKey: ApiKey, contactId: Int)
    case deleteMailbox(baseUrl: URL, apiKey: ApiKey, mailboxId: Int)
    case forgotPassword(baseUrl: URL, email: String)
    case getAlias(baseUrl: URL, apiKey: ApiKey, aliasId: Int)
    case getDomainLites(baseUrl: URL, apiKey: ApiKey)
    case login(baseUrl: URL, email: String, password: String, deviceName: String)
    case mailboxes(baseUrl: URL, apiKey: ApiKey)
    case makeDefaultMailbox(baseUrl: URL, apiKey: ApiKey, mailboxId: Int)
    case processPayment(baseUrl: URL, apiKey: ApiKey, receiptData: String)
    case randomAlias(baseUrl: URL, apiKey: ApiKey, randomMode: RandomMode)
    case reactivateEmail(baseUrl: URL, email: String)
    case signUp(baseUrl: URL, email: String, password: String)
    case toggleAlias(baseUrl: URL, apiKey: ApiKey, aliasId: Int)
    case updateAliasMailboxes(baseUrl: URL, apiKey: ApiKey, aliasId: Int, mailboxIds: [Int])
    case updateAliasName(baseUrl: URL, apiKey: ApiKey, aliasId: Int, name: String?)
    case updateAliasNote(baseUrl: URL, apiKey: ApiKey, aliasId: Int, note: String?)
    case updateName(baseUrl: URL, apiKey: ApiKey, name: String?)
    case updateProfilePicture(baseUrl: URL, apiKey: ApiKey, base64String: String?)
    case updateUserSettings(baseUrl: URL, apiKey: ApiKey, option: UserSettings.Option)
    case userInfo(baseUrl: URL, apiKey: ApiKey)
    case userSettings(baseUrl: URL, apiKey: ApiKey)
    case userOptions(baseUrl: URL, apiKey: ApiKey, hostname: String?)
    case verifyMfa(baseUrl: URL, key: String, token: String, deviceName: String)

    var path: String {
        switch self {
        case .aliases: return "/api/v2/aliases"
        case .aliasActivities(_, _, let aliasId, _): return "/api/aliases/\(aliasId)/activities"
        case .activateEmail: return "/api/auth/activate"
        case .contacts(_, _, let aliasId, _): return "/api/aliases/\(aliasId)/contacts"
        case .createAlias: return "/api/v3/alias/custom/new"
        case .createContact(_, _, let aliasId, _): return "/api/aliases/\(aliasId)/contacts"
        case .createMailbox: return "/api/mailboxes"
        case .customDomains: return "/api/custom_domains"
        case .deleteAlias(_, _, let aliasId): return "/api/aliases/\(aliasId)"
        case .deleteContact(_, _, let contactId): return "/api/contacts/\(contactId)"
        case .deleteMailbox(_, _, let mailboxId): return "/api/mailboxes/\(mailboxId)"
        case .forgotPassword: return "/api/auth/forgot_password"
        case .getAlias(_, _, let aliasId): return "/api/aliases/\(aliasId)"
        case .getDomainLites: return "/api/v2/setting/domains"
        case .login: return "/api/auth/login"
        case .mailboxes: return "/api/v2/mailboxes"
        case .makeDefaultMailbox(_, _, let mailboxId): return "/api/mailboxes/\(mailboxId)"
        case .processPayment: return "/api/apple/process_payment"
        case .randomAlias: return "/api/alias/random/new"
        case .reactivateEmail: return "/api/auth/reactivate"
        case .signUp: return "/api/auth/register"
        case .toggleAlias(_, _, let aliasId): return "/api/aliases/\(aliasId)/toggle"
        case .updateAliasMailboxes(_, _, let aliasId, _): return "/api/aliases/\(aliasId)"
        case .updateAliasName(_, _, let aliasId, _): return "/api/aliases/\(aliasId)"
        case .updateAliasNote(_, _, let aliasId, _): return "/api/aliases/\(aliasId)"
        case .updateName: return ""
        case .updateProfilePicture: return "/api/user_info"
        case .updateUserSettings: return "/api/setting"
        case .userInfo: return "/api/user_info"
        case .userOptions: return "/api/v5/alias/options"
        case .userSettings: return "/api/setting"
        case .verifyMfa: return "/api/auth/mfa"
        }
    }

    var urlRequest: URLRequest {
        switch self {
        case let .aliases(baseUrl, apiKey, page, searchTerm):
            return aliasesRequest(baseUrl: baseUrl, apiKey: apiKey, page: page, searchTerm: searchTerm)

        case let .aliasActivities(baseUrl, apiKey, aliasId, page):
            return aliasActivitiesRequest(baseUrl: baseUrl, apiKey: apiKey, aliasId: aliasId, page: page)

        case let .activateEmail(baseUrl, email, code):
            return activateEmailRequest(baseUrl: baseUrl, email: email, code: code)

        case let .contacts(baseUrl, apiKey, aliasId, page):
            return contactsRequest(baseUrl: baseUrl, apiKey: apiKey, aliasId: aliasId, page: page)

        case let .createAlias(baseUrl, apiKey, aliasCreationRequest):
            return createAliasRequest(baseUrl: baseUrl, apiKey: apiKey, aliasCreationRequest: aliasCreationRequest)

        case let .createContact(baseUrl, apiKey, aliasId, email):
            return createContactRequest(baseUrl: baseUrl, apiKey: apiKey, aliasId: aliasId, email: email)

        case let .createMailbox(baseUrl, apiKey, email):
            return createMailboxRequest(baseUrl: baseUrl, apiKey: apiKey, email: email)

        case let .customDomains(baseUrl, apiKey):
            return customDomainsRequest(baseUrl: baseUrl, apiKey: apiKey)

        case let .deleteAlias(baseUrl, apiKey, _):
            return deleteRequest(baseUrl: baseUrl, apiKey: apiKey)

        case let .deleteContact(baseUrl, apiKey, _):
            return deleteRequest(baseUrl: baseUrl, apiKey: apiKey)

        case let .deleteMailbox(baseUrl, apiKey, _):
            return deleteRequest(baseUrl: baseUrl, apiKey: apiKey)

        case let .forgotPassword(baseUrl, email):
            return forgotPasswordRequest(baseUrl: baseUrl, email: email)

        case let .getAlias(baseUrl, apiKey, aliasId):
            return getAliasRequest(baseUrl: baseUrl, apiKey: apiKey, aliasId: aliasId)

        case let .getDomainLites(baseUrl, apiKey):
            return getDomainLitesRequest(baseUrl: baseUrl, apiKey: apiKey)

        case let .login(baseUrl, email, password, deviceName):
            return loginRequest(baseUrl: baseUrl, email: email, password: password, deviceName: deviceName)

        case let .mailboxes(baseUrl, apiKey):
            return mailboxesRequest(baseUrl: baseUrl, apiKey: apiKey)

        case let .makeDefaultMailbox(baseUrl, apiKey, mailboxId):
            return makeDefaultMailboxRequest(baseUrl: baseUrl, apiKey: apiKey, mailboxId: mailboxId)

        case let .processPayment(baseUrl, apiKey, receiptData):
            return processPayment(baseUrl: baseUrl, apiKey: apiKey, receiptData: receiptData)

        case let .randomAlias(baseUrl, apiKey, randomMode):
            return randomAlias(baseUrl: baseUrl, apiKey: apiKey, randomMode: randomMode)

        case let .reactivateEmail(baseUrl, email):
            return reactivateEmailRequest(baseUrl: baseUrl, email: email)

        case let .signUp(baseUrl, email, password):
            return signUpRequest(baseUrl: baseUrl, email: email, password: password)

        case let .toggleAlias(baseUrl, apiKey, aliasId):
            return toggleAliasRequest(baseUrl: baseUrl, apiKey: apiKey, aliasId: aliasId)

        case let .updateAliasMailboxes(baseUrl, apiKey, aliasId, mailboxIds):
            return updateAliasMailboxesRequest(baseUrl: baseUrl,
                                               apiKey: apiKey,
                                               aliasId: aliasId,
                                               mailboxIds: mailboxIds)

        case let .updateAliasName(baseUrl, apiKey, aliasId, name):
            return updateAliasNameRequest(baseUrl: baseUrl, apiKey: apiKey, aliasId: aliasId, name: name)

        case let .updateAliasNote(baseUrl, apiKey, aliasId, note):
            return updateAliasNoteRequest(baseUrl: baseUrl, apiKey: apiKey, aliasId: aliasId, note: note)

        case let .updateName(baseUrl, apiKey, name):
            return updateNameRequest(baseUrl: baseUrl, apiKey: apiKey, name: name)

        case let .updateProfilePicture(baseUrl, apiKey, base64String):
            return updateProfilePictureRequest(baseUrl: baseUrl, apiKey: apiKey, base64String: base64String)

        case let .updateUserSettings(baseUrl, apiKey, option):
            return updateUserSettingsRequest(baseUrl: baseUrl, apiKey: apiKey, option: option)

        case let .userInfo(baseUrl, apiKey):
            return userInfoRequest(baseUrl: baseUrl, apiKey: apiKey)

        case let .userOptions(baseUrl, apiKey, hostname):
            return userOptionsRequest(baseUrl: baseUrl, apiKey: apiKey, hostname: hostname)

        case let .userSettings(baseUrl, apiKey):
            return userSettingsRequest(baseUrl: baseUrl, apiKey: apiKey)

        case let .verifyMfa(baseUrl, key, token, deviceName):
            return verifyMfaRequest(baseUrl: baseUrl, key: key, token: token, deviceName: deviceName)
        }
    }
}

extension SLEndpoint {
    private func aliasesRequest(baseUrl: URL, apiKey: ApiKey, page: Int, searchTerm: String?) -> URLRequest {
        let queryItem = URLQueryItem(name: "page_id", value: "\(page)")
        let url = baseUrl.append(path: path, queryItems: [queryItem])

        var request = URLRequest(url: url)

        if let searchTerm = searchTerm {
            request.httpMethod = HTTPMethod.post
            request.addJsonRequestBody(["query": searchTerm])
        } else {
            request.httpMethod = HTTPMethod.get
        }

        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func aliasActivitiesRequest(baseUrl: URL, apiKey: ApiKey, aliasId: Int, page: Int) -> URLRequest {
        let queryItem = URLQueryItem(name: "page_id", value: "\(page)")
        let url = baseUrl.append(path: path, queryItems: [queryItem])

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func activateEmailRequest(baseUrl: URL, email: String, code: String) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        request.addJsonRequestBody(["email": email, "code": code])

        return request
    }

    private func contactsRequest(baseUrl: URL, apiKey: ApiKey, aliasId: Int, page: Int) -> URLRequest {
        let queryItem = URLQueryItem(name: "page_id", value: "\(page)")
        let url = baseUrl.append(path: path, queryItems: [queryItem])

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func createAliasRequest(baseUrl: URL,
                                    apiKey: ApiKey,
                                    aliasCreationRequest: AliasCreationRequest) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        request.addJsonRequestBody(aliasCreationRequest.toRequestBody())
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func createContactRequest(baseUrl: URL,
                                      apiKey: ApiKey,
                                      aliasId: Int,
                                      email: String) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        request.addJsonRequestBody(["contact": email])
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func createMailboxRequest(baseUrl: URL,
                                      apiKey: ApiKey,
                                      email: String) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        request.addJsonRequestBody(["email": email])
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func customDomainsRequest(baseUrl: URL, apiKey: ApiKey) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func deleteRequest(baseUrl: URL, apiKey: ApiKey) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.delete
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func forgotPasswordRequest(baseUrl: URL, email: String) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        request.addJsonRequestBody(["email": email])

        return request
    }

    private func getAliasRequest(baseUrl: URL, apiKey: ApiKey, aliasId: Int) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func getDomainLitesRequest(baseUrl: URL, apiKey: ApiKey) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func loginRequest(baseUrl: URL, email: String, password: String, deviceName: String) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        request.addJsonRequestBody(["email": email,
                                    "password": password,
                                    "device": deviceName])

        return request
    }

    private func mailboxesRequest(baseUrl: URL, apiKey: ApiKey) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func makeDefaultMailboxRequest(baseUrl: URL, apiKey: ApiKey, mailboxId: Int) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.put
        request.addJsonRequestBody(["default": true])
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func processPayment(baseUrl: URL, apiKey: ApiKey, receiptData: String) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        request.addJsonRequestBody(["receipt_data": receiptData])
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func randomAlias(baseUrl: URL, apiKey: ApiKey, randomMode: RandomMode) -> URLRequest {
        let queryItem = URLQueryItem(name: "mode", value: randomMode.rawValue)
        let url = baseUrl.append(path: path, queryItems: [queryItem])

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func reactivateEmailRequest(baseUrl: URL, email: String) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        request.addJsonRequestBody(["email": email])

        return request
    }

    private func signUpRequest(baseUrl: URL, email: String, password: String) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        request.addJsonRequestBody(["email": email, "password": password])

        return request
    }

    private func toggleAliasRequest(baseUrl: URL, apiKey: ApiKey, aliasId: Int) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func updateAliasMailboxesRequest(baseUrl: URL,
                                             apiKey: ApiKey,
                                             aliasId: Int,
                                             mailboxIds: [Int]) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.put
        request.addApiKeyToHeaders(apiKey)
        request.addJsonRequestBody(["mailbox_ids": mailboxIds])

        return request
    }

    private func updateAliasNameRequest(baseUrl: URL,
                                        apiKey: ApiKey,
                                        aliasId: Int,
                                        name: String?) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.put
        request.addJsonRequestBody(["name": name as Any])
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func updateAliasNoteRequest(baseUrl: URL,
                                        apiKey: ApiKey,
                                        aliasId: Int,
                                        note: String?) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.put
        request.addJsonRequestBody(["note": note as Any])
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func updateNameRequest(baseUrl: URL, apiKey: ApiKey, name: String?) -> URLRequest {
        let url = baseUrl.append(path: "/api/user_info")

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.patch
        request.addJsonRequestBody(["name": name])
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func updateProfilePictureRequest(baseUrl: URL, apiKey: ApiKey, base64String: String?) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.patch
        request.addApiKeyToHeaders(apiKey)
        request.addJsonRequestBody(["profile_picture": base64String])

        return request
    }

    private func updateUserSettingsRequest(baseUrl: URL,
                                           apiKey: ApiKey,
                                           option: UserSettings.Option) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.patch
        request.addJsonRequestBody(option.requestBody)
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func userInfoRequest(baseUrl: URL, apiKey: ApiKey) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get
        request.addApiKeyToHeaders(apiKey)
        return request
    }

    private func userOptionsRequest(baseUrl: URL, apiKey: ApiKey, hostname: String?) -> URLRequest {
        let url: URL
        if let hostname = hostname {
            let queryItem = URLQueryItem(name: "hostname", value: hostname)
            url = baseUrl.append(path: path, queryItems: [queryItem])
        } else {
            url = baseUrl.append(path: path)
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func userSettingsRequest(baseUrl: URL, apiKey: ApiKey) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func verifyMfaRequest(baseUrl: URL, key: String, token: String, deviceName: String) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        request.addJsonRequestBody(["mfa_token": token,
                                    "mfa_key": key,
                                    "device": deviceName])

        return request
    }
}
