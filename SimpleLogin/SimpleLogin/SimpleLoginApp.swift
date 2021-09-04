//
//  SimpleLoginApp.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 28/06/2021.
//

import SimpleLoginPackage
import SwiftUI

@main
struct SimpleLoginApp: App {
    @State private var preferences = Preferences.shared
    @State private var apiKey: ApiKey?
    @State private var client: SLClient?

    var body: some Scene {
        WindowGroup {
            if let apiKey = apiKey, let client = client {
                MainView(apiKey: apiKey, client: client)
                    .environmentObject(preferences)
            } else {
                LogInView(apiUrl: preferences.apiUrl) { apiKey, client in
                    self.apiKey = apiKey
                    self.client = client
                }
                .loadableToastable()
                .environmentObject(preferences)
            }
        }
    }
}