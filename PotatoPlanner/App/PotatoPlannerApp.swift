//
//  PotatoPlannerApp.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/9/25.
//


import SwiftUI
import SwiftData

// NOTE: Store and container are let properties rather than using .modelContainer()
// scene modifier to prevent ModelContext resets. Container should be created once.

@main
struct PotatoPlannerApp: App {

    private let store: PotatoPlannerStore

    @MainActor
    init() {
        store = PotatoPlannerStore(container: PotatoPlannerStore.makeContainer())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
        }
    }
}
