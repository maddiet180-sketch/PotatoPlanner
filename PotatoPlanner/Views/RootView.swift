//
//  RootView.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/14/25.
//

import SwiftUI

enum Tab: Hashable {
    case daily, calendar, potato
}

struct RootView: View {
    @State private var selectedTab: Tab = .daily
    @State var showingAddTask: Bool = false
        
    var body: some View {
        TabView(selection: $selectedTab) {
            MainView()
                .tag(Tab.daily)
                .toolbar(.hidden, for: .tabBar)
            MonthlyCalendarView()
                .tag(Tab.calendar)
                .toolbar(.hidden, for: .tabBar)
            PotatosView()
                .tag(Tab.potato)
                .toolbar(.hidden, for: .tabBar)
        }
        .safeAreaInset(edge: .bottom) {
            BottomBarView(
                selectedTab: $selectedTab,
                onAdd: { showingAddTask = true}
            )
            .padding(.horizontal, 20)
        }
        .safeAreaInset(edge: .top) {
            TopBarView()
            .padding(.horizontal, 20)
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(style: .standard)
        }
    }
}
