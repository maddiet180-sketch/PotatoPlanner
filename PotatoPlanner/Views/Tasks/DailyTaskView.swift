//
//  MainTaskView.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/18/25.
//

import SwiftUI

struct DailyTasks: View {
    @Environment(PotatoPlannerStore.self) var store

    let style: TaskStyle

    enum TaskStyle {
        case main, calendar
    }

    init(style: TaskStyle = .main) {
        self.style = style
    }
    
    var body: some View {
        ZStack {
            listBackground
                .padding(.top, style == .main ? 10 : 0)
            VStack(spacing: 0) {
                listHeader
                Spacer()
                let currentTasks = store.tasks(on: store.selectedDate)
                if currentTasks.isEmpty {
                    emptyStateView
                } else {
                    tasksList(for: currentTasks)
                }
                Spacer()
            }
            listForeground
                .padding(.top, style == .main ? 10 : 0 )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        ZStack(alignment: .top) {
            VStack(spacing: 7) {
                HStack(alignment: .center) {
                    Spacer()
                    dateNavButton(direction: "left")
                    Spacer()
                    VStack(alignment: .center, spacing: 0) {
                        Text(store.selectedDate.ttyOrMediumDate())
                            .font(.custom("Myfont-Regular", size: 20))
                            .font(.title2)
                        Text("\(store.totalFocusTime(on: store.selectedDate).asHMS) scheduled")
                            .foregroundStyle(.secondary)
                    }
                    .foregroundStyle(.textboxBackground)
                    Spacer()
                    dateNavButton(direction: "right")
                    Spacer()
                }
                .padding(.top, 10)
                
                ProgressView(value: dailyProgress)
                    .tint(.accentColor3C)
            }
            .background(.accentColor3B)
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 12, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 12))
            .padding(.top, 10)
            
            Image("MainListFrame")
                .resizable()
                .scaledToFit()
        }
    }
    
    private var dailyProgress: Double {
        let completed = Double(store.completedFocusTime(on: store.selectedDate))
        let total = Double(store.totalFocusTime(on: store.selectedDate))
        guard total > 0 else { return 0 }
        return completed / total
    }
    
    private var calendarListHeader: some View {
        HStack {
            Text(store.selectedDate.ttyOrMediumDate())
                .font(.title2)
            Text(" · \(store.totalFocusTime(on: store.selectedDate).asHMS)")
                .foregroundStyle(.secondary)
            Spacer()
            Button(action: { store.addEditTaskPresentation = .add(date: store.selectedDate) }) {
                ZStack {
                    Circle()
                        .fill(.accentColor1B)
                    Image(systemName: "plus")
                        
                        .font(.title2)
                        .foregroundStyle(.textboxBackground)
                }
            }
        }
        .frame(height: 30)
        .padding()
    }
    
    private func dateNavButton(direction: String) -> some View {
        Button {
            changeDate(by: direction == "left" ? -1 : 1)
        } label: {
            Image(systemName: "chevron.\(direction).circle.fill")
                .font(.title.bold())
                .symbolRenderingMode(.palette)
                .foregroundStyle(.textboxBackground, .accentColor3C)
        }
    }
    
    private func changeDate(by offset: Int) {
        if let updatedDate = Calendar.current.date(byAdding: .day, value: offset, to: store.selectedDate) {
            store.selectedDate = updatedDate
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Image(style == .main ? "NoTaskIcon" : "GreySpud")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: style == .main ? 70 : 20)
                .padding(style == .main ? .bottom : .horizontal)
            Text(emptyStateMessage)
                .frame(width: style == .main ? 250 : 150)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var emptyStateMessage: String {
        switch style {
        case .main:
            return "Click the + icon below to add tasks and grow your potato"
        case .calendar:
            return "No tasks scheduled for this date"
        }
    }
    
    private func tasksList(for tasks: [TaskEntity]) -> some View {
        List {
            ForEach(tasks) { task in
                IndividualTaskView(task: task, style: style)
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
    
    private var listForeground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.clear)
            .stroke(.primaryText, lineWidth: 3)
    }
}

#Preview {
    DailyTasks(style: .main)
        .environment(PotatoPlannerStore.preview)
}
