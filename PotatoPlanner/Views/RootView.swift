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
    @Environment(PotatoPlannerStore.self) var store
    @State private var selectedTab: Tab = .daily

    var body: some View {
        TabView(selection: $selectedTab) {
            MainView(selectedTab: selectedTab)
                .tag(Tab.daily)
                .toolbar(.hidden, for: .tabBar)
            MonthlyCalendarView(selectedTab: selectedTab)
                .tag(Tab.calendar)
                .toolbar(.hidden, for: .tabBar)
            PotatoesView(selectedTab: selectedTab)
                .tag(Tab.potato)
                .toolbar(.hidden, for: .tabBar)
        }
        .safeAreaInset(edge: .bottom) {
            BottomBarView(
                selectedTab: $selectedTab,
                onAdd: { store.addEditTaskPresentation = .add(date: store.selectedDate) }
            )
            .padding(.horizontal, 20)
        }
        .safeAreaInset(edge: .top) {
            TopBarView()
                .padding(.horizontal, 20)
        }
        .overlay(alignment: .top) {
            if store.addEditTaskPresentation != nil {
                ZStack(alignment: .top) {
                    Color.accentColor3B.opacity(0.0)
                        .ignoresSafeArea()
                        .onTapGesture { store.addEditTaskPresentation = nil }
                    overlayContent
                }
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.spring(duration: 0.5), value: store.addEditTaskPresentation != nil)
        .buttonStyle(SoundButtonStyle())
        .task { store.applyAudioState() }
    }

    @ViewBuilder
    private var overlayContent: some View {
        switch store.addEditTaskPresentation {
        case .add(let date):
            AddEditTaskView(mode: .add, date: date)
        case .edit(let task):
            AddEditTaskView(mode: .edit, task: task)
        case nil:
            EmptyView()
        }
    }
}
