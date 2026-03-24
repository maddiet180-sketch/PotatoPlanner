//
//  IndividualTaskView.swift
//  PotatoPlanner
//
//  Created by Madeline Moody on 3/12/26.
//

import SwiftUI

struct IndividualTaskView: View {
    @Environment(PotatoPlannerStore.self) var store
    @State private var showingFocus = false
    @State private var showingEditTask = false
    
    let selectedDate: Date
    let task: TaskEntity
    let style: DailyTasks.TaskStyle
        
    init(task: TaskEntity, selectedDate: Date, style: DailyTasks.TaskStyle) {
        self.task = task
        self.selectedDate = selectedDate
        self.style = style
    }
    
    var body: some View {
        HStack {
            checkbox
                .padding(.trailing, 10)
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
        } else {
            Image(systemName: "square")
        }
    }
    
    private var taskInfo: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(task.title)
            HStack {
                Text("\(task.clampedCompletedSeconds.asHMS) / \(task.allocatedSeconds.asHMS)")
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
                .opacity(focusButtonActive ? 0.6 : 0.1)
        )
        .disabled(!focusButtonActive)
        .fullScreenCover(isPresented: $showingFocus) {
            FocusView(taskID: task.id)
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
    IndividualTaskView(task: TaskEntity.preview, selectedDate: .now, style: .main)
        .environment(PotatoPlannerStore.preview)
}
