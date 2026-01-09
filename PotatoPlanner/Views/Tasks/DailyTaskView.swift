//
//  MainTaskView.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/18/25.
//

import SwiftUI

struct DailyTasks: View {
    @EnvironmentObject var potatoViewModel: PotatoPlannerModel
    @State var addTaskisShowing: Bool = false
    @State var internalDate: Date = Date.now
    
    let style: TaskStyle
    let externalDate: Binding<Date>?
    
    
    enum TaskStyle {
        case main, calendar
    }
    
    // init for main view
    init(style: TaskStyle = .main) {
        self.style = style
        self.externalDate = nil
    }

    // intit for calendar view
    init(selectedDate: Binding<Date>, style: TaskStyle = .calendar) {
        self.style = style
        self.externalDate = selectedDate
    }
    
    var selectedDate: Binding<Date> {
        externalDate ?? $internalDate
    }
    
    var body: some View {
        VStack(spacing: 3) {
            listHeader
            
            let currentTasks = potatoViewModel.isScheduled(on: selectedDate.wrappedValue)
            if currentTasks.isEmpty {
                emptyStateView
            } else {
                tasksList(for: currentTasks)
            }
        }
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(listBackground)
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
        HStack {
            Spacer()
            dateNavButton(direction: "left")
            Spacer()
            VStack(alignment: .center) {
                Text(selectedDate.wrappedValue.ttyOrMediumDate())
                    .font(.title2)
                Text("\(potatoViewModel.totalDailyFocusTime(on: selectedDate.wrappedValue).asHMS) scheduled")
                    .foregroundStyle(.secondary)
            }
            Spacer()
            dateNavButton(direction: "right")
            Spacer()
        }
        .padding(.top, 10)
    }
    
    private var calendarListHeader: some View {
        HStack {
            Text(selectedDate.wrappedValue.ttyOrMediumDate())
                .font(.title2)
            Text(" · \(potatoViewModel.totalDailyFocusTime(on: selectedDate.wrappedValue).asHMS)")
                .foregroundStyle(.secondary)
            Spacer()
            Button(action: {addTaskisShowing = true}) {
                ZStack {
                    Circle()
                        .fill(.accentColor1B)
                        .stroke(.primaryText, lineWidth: 3)
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundStyle(.textboxBackground)
                }
            }
            .sheet(isPresented: $addTaskisShowing) {
                AddTaskView(style: .compact, scheduledDate: selectedDate)
            }
        }
        .frame(height: 30) // FIXME: fixed height
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
    
    private func tasksList(for tasks: [Task]) -> some View {
        List {
            ForEach(tasks) { task in
                MainTaskView(task: task, selectedDate: selectedDate.wrappedValue, style: style)
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

struct MainTaskView: View {
    @EnvironmentObject var potatoViewModel: PotatoPlannerModel
    @State private var showingFocus = false
    @State private var showingEditTask = false
    
    let selectedDate: Date
    let task: Task
    let style: DailyTasks.TaskStyle
        
    init(task: Task, selectedDate: Date, style: DailyTasks.TaskStyle) {
        self.task = task
        self.selectedDate = selectedDate
        self.style = style
    }
    
    var body: some View {
        HStack {
            checkbox
            taskInfo
            Spacer()
            if style == .main {
                focusButton
            }
        }
    }
    
    private var checkbox: some View {
        if task.isComplete {
            Image(systemName: "checkmark.square")
                .padding(.trailing, 10)
        } else {
            Image(systemName: "square")
                .padding(.trailing, 10)
        }
    }
    
    private var taskInfo: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(task.title)
            HStack {
                Text("\(task.completedSeconds.asHMS) / \(task.allocatedSeconds.asHMS)")
                    .foregroundStyle(.secondary)
                editTaskButton
            }
        }
    }
    
    private var focusButton: some View {
        return Button("Focus") {
            showingFocus = true
        }
        .buttonStyle(.bordered)
        .background(
            RoundedRectangle(cornerRadius: 13)
                .fill(focusButtonActive ? .accentColor1B : .primaryText)
                .opacity(focusButtonActive ? 0.5 : 0.1)
        )
        .disabled(!focusButtonActive)
        .fullScreenCover(isPresented: $showingFocus) {
            FocusView(task: task)
        }
    }
    
    private var editTaskButton: some View {
        Button(action: { showingEditTask = true }) {
            Image("Edit")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 15)
        }
        .sheet(isPresented: $showingEditTask) {
            EditTaskView(task: task)
        }
    }
    
    private var focusButtonActive: Bool {
        Calendar.current.isDateInToday(selectedDate) && !task.isComplete
    }
}

#Preview {
    DailyTasks()
        .environmentObject(PotatoPlannerModel())
}
