//
//  ReduxSwiftUIDemoApp.swift
//  ReduxSwiftUIDemo
//

//

import SwiftUI
import ComposableArchitecture

@main
struct ReduxSwiftUIDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: Store(initialState: AppFeature.State()) {
                    AppFeature()
                }
            )
        }
    }
}
