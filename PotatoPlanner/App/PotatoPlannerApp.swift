//
//  PotatoPlannerApp.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/9/25.
//

import SwiftUI

@main
struct PotatoPlannerApp: App {
    @StateObject private var plannerModel = PotatoPlannerModel()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(plannerModel)
        }
    }
}
