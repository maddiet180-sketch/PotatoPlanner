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

    let task: TaskEntity
    let style: DailyTasks.TaskStyle

    init(task: TaskEntity, style: DailyTasks.TaskStyle) {
        self.task = task
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
            Image("SquareCheckmark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30)
        } else {
            Image("Square")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30)
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
        return Button() {
            showingFocus = true
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 13)
                    .fill(focusButtonActive ? .accentColor1B : .primaryText)
                    .opacity(focusButtonActive ? 0.6 : 0.1)
                    .frame(width: 80, height: 33)
                
                Text("Focus")
//                    .font(.custom("Myfont-Regular", size: 20))
            }
        }
        .disabled(!focusButtonActive)
        .fullScreenCover(isPresented: $showingFocus) {
            FocusView(taskID: task.id)
        }
    }

    private var editTaskButton: some View {
        Button(action: { store.addEditTaskPresentation = .edit(task: task) }) {
            Image("Edit")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 15)
        }
    }

    private var focusButtonActive: Bool {
        Calendar.current.isDateInToday(store.selectedDate) && !task.isComplete
    }
}

#Preview {
    IndividualTaskView(task: TaskEntity.preview, style: .main)
        .environment(PotatoPlannerStore.preview)
}
