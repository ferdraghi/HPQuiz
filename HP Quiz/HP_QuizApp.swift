//
//  HP_QuizApp.swift
//  HP Quiz
//
//  Created by Fernando Draghi on 13/11/2024.
//

import SwiftUI

@main
struct HP_QuizApp: App {
    @StateObject private var store = Store()
    @StateObject private var game = GameViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(game)
                .environmentObject(store)
                .task {
                    await store.loadProducts()
                }
        }
    }
}
