//
//  MainTaskView.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/18/25.
//

import SwiftUI

struct DailyTasks: View {
    @Environment(PotatoPlannerStore.self) var store
    @State var addTaskisShowing: Bool = false
    @State var internalDate: Date = Date.now
    
    let style: TaskStyle
    let selectedTab: Tab?
    
    var externalDate: Binding<Date>?
    var selectedDate: Binding<Date> {
        externalDate ?? $internalDate
    }
    
    enum TaskStyle {
        case main, calendar
    }
    
    // init for main view
    init(style: TaskStyle = .main, selectedTab: Tab) {
        self.style = style
        self.externalDate = nil
        self.selectedTab = selectedTab
    }

    // intit for calendar view
    init(style: TaskStyle = .calendar, selectedDate: Binding<Date>) {
        self.style = style
        self.externalDate = selectedDate
        self.selectedTab = nil
    }
    
    var body: some View {
        VStack(spacing: 3) {
            listHeader
            let currentTasks = store.tasks(on: selectedDate.wrappedValue)
            if currentTasks.isEmpty {
                emptyStateView
            } else {
                tasksList(for: currentTasks)
            }
        }
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(listBackground)
        .onChange(of: selectedTab) {
            selectedDate.wrappedValue = Date()
        }
    }
    
    @ViewBuilder
    private var listHeader: some View {
        switch style {
        case .main:
            mainListHeader
        case .calendar:
            calendarListHeader
        }
    }
    
    private var mainListHeader: some View {
        VStack {
            HStack {
                Spacer()
                dateNavButton(direction: "left")
                Spacer()
                VStack(alignment: .center) {
                    Text(selectedDate.wrappedValue.ttyOrMediumDate())
                        .font(.title2)
                    Text("\(store.totalFocusTime(on: selectedDate.wrappedValue).asHMS) scheduled")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                dateNavButton(direction: "right")
                Spacer()
            }
            .padding(.top, 10)
            
            ProgressView(value: dailyProgress)
                .tint(.accentColor3B)
        }
    }
    
    private var dailyProgress: Double {
        let completed = Double(store.completedFocusTime(on: selectedDate.wrappedValue))
        let total = Double(store.totalFocusTime(on: selectedDate.wrappedValue))
        guard total > 0 else { return 0 }
        return completed / total
    }
    
    private var calendarListHeader: some View {
        HStack {
            Text(selectedDate.wrappedValue.ttyOrMediumDate())
                .font(.title2)
            Text(" · \(store.totalFocusTime(on: selectedDate.wrappedValue).asHMS)")
                .foregroundStyle(.secondary)
            Spacer()
            Button(action: {addTaskisShowing = true}) {
                ZStack {
                    Circle()
                        .fill(.accentColor1B)
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundStyle(.textboxBackground)
                }
            }
            .sheet(isPresented: $addTaskisShowing) {
                AddTaskView(style: .compact, scheduledDate: selectedDate)
            }
        }
        .frame(height: 30) // FIXME: - fixed height
        .padding()
    }
    
    private func dateNavButton(direction: String) -> some View {
        Button {
            changeDate(by: direction == "left" ? -1 : 1)
        } label: {
            Image(systemName: "chevron.\(direction)")
                .font(.title.bold())
                .foregroundStyle(.accentColor1B)
        }
    }
    
    private func changeDate(by offset: Int) {
        if let updatedDate = Calendar.current.date(byAdding: .day, value: offset, to: selectedDate.wrappedValue) {
            selectedDate.wrappedValue = updatedDate
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Text(emptyStateMessage)
                .frame(width: 250)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
    
    private var emptyStateMessage: String {
        switch style {
        case .main:
            return "Click the + icon below to add tasks and grow your plant"
        case .calendar:
            return "No tasks scheduled for this date"
        }
    }
    
    private func tasksList(for tasks: [TaskEntity]) -> some View {
        List {
            ForEach(tasks) { task in
                IndividualTaskView(task: task, selectedDate: selectedDate.wrappedValue, style: style)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    private var listBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.textboxBackground)
            .stroke(.primaryText, lineWidth: 3)
    }
}

#Preview {
    DailyTasks(selectedTab: .calendar)
        .environment(PotatoPlannerStore.preview)
}
