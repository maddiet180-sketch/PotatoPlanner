//
//  AddEditTaskView.swift
//  PotatoPlanner
//
//  Created by Madeline Moody on 3/31/26.
//

import SwiftUI

struct AddEditTaskView: View {
    @Environment(PotatoPlannerStore.self) private var store

    @State private var title: String = ""
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var description: String = ""
    @State private var scheduledDate: Date = Date.now

    private var allocatedSeconds: Int {
        (hours * 3600) + (minutes * 60)
    }

    private var isAddDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || allocatedSeconds <= 0
    }

    let mode: AddEditMode
    let task: TaskEntity?

    enum AddEditMode {
        case add, edit
    }

    init(mode: AddEditMode = .add, date: Date) {
        self.mode = mode
        self.task = nil
        _scheduledDate = State(initialValue: date)
    }

    init(mode: AddEditMode = .edit, task: TaskEntity) {
        self.mode = mode
        self.task = task
        _title = State(initialValue: task.title)
        _hours = State(initialValue: task.allocatedSeconds.asHours)
        _minutes = State(initialValue: task.allocatedSeconds.asRemainingMinutes)
        _description = State(initialValue: task.taskDescription ?? "")
        _scheduledDate = State(initialValue: task.scheduledDate)
    }

    var body: some View {
        VStack {
            actionButtons
            formContent
        }
        .padding(.horizontal, 30)
        .padding(.top, 100)
        .padding(.bottom, 30)
        .frame(maxWidth: .infinity)
        .background(alignment: .top) {
            Image("AddEditTaskBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(.all, edges: [.bottom, .leading, .trailing])
        }
        .overlay(alignment: .top) {
            Image("AddEditTaskForeground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(.all, edges: [.bottom, .leading, .trailing])
                .allowsHitTesting(false)
        }
        .appTheme()
    }

    var actionButtons: some View {
        HStack {
            dismissButton
            Spacer()
            addButton
        }
        .foregroundStyle(.accentColor1A)
        .font(.title)
    }

    private var dismissButton: some View {
        Button {
            store.addEditTaskPresentation = nil
        } label: {
            Image(systemName: "arrowshape.turn.up.backward.circle.fill")
        }
    }

    private var addButton: some View {
        Button {
            if mode == .add {
                store.addTask(
                    title: title,
                    description: description,
                    allocatedSeconds: allocatedSeconds,
                    scheduledDate: scheduledDate
                )
            } else if let task {
                store.updateTask(
                    task,
                    title: title,
                    description: description,
                    allocatedSeconds: allocatedSeconds,
                    scheduledDate: scheduledDate
                )
            }
            store.addEditTaskPresentation = nil
        } label: {
            Image(systemName: "checkmark.circle.fill")
        }
        .disabled(isAddDisabled)
    }

    private var formContent: some View {
        VStack(spacing: 20) {
            Text(mode == .add ? "Add Task" : "Edit Task")
                .font(.custom("Myfont-Regular", size: 35))
                .textShadow(x: 4, y: 4, color: .darkText)
                .foregroundStyle(.accentColor3A)
            titleAndDescription
            datePicker
            timePicker
            if let task {
                finishTaskEarlyButton(task)
                deleteTaskButton(task)
            }
        }
    }

    private var titleAndDescription: some View {
        VStack {
            TextField(
                "Task Title",
                text: $title
            )
            Divider()
            TextField(
                "Description (optional)",
                text: $description
            )
        }
        .padding()
        .background(boxBackground)
    }

    private var datePicker: some View {
        DatePicker(selection: $scheduledDate, displayedComponents: .date) {
            Text("Date Scheduled")
        }
        .datePickerStyle(CompactDatePickerStyle())
        .accentColor(.accentColor1B)
        .padding()
        .background(boxBackground)
    }

    private var timePicker: some View {
        HStack(alignment: .top) {
            TimeUnitPicker(label: "Hours", value: $hours, step: 1, range: 0...10)
            Text(":")
                .font(.system(size: 60, weight: .bold))
                .foregroundStyle(.accentColor1B)
            TimeUnitPicker(label: "Mins", value: $minutes, step: 1, range: 0...55)
        }
        .padding()
        .background(boxBackground)
    }

    private func finishTaskEarlyButton(_ task: TaskEntity) -> some View {
        HStack {
            Button {
                store.finishTaskEarly(task)
                store.addEditTaskPresentation = nil
            } label: {
                Image(systemName: "checkmark")
            }
            Text("Finish task early")
                .padding(.trailing)
            Spacer()
        }
        .padding()
        .background(boxBackground)
    }

    private func deleteTaskButton(_ task: TaskEntity) -> some View {
        HStack {
            Button {
                store.deleteTask(task)
                store.addEditTaskPresentation = nil
            } label: {
                Image(systemName: "trash")
            }
            .padding(.trailing)
            Text("Delete Task")
            Spacer()
        }
        .padding()
        .background(boxBackground)
    }

    private var boxBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.textboxBackground)
    }

}

struct TimeUnitPicker: View {
    let label: String
    @Binding var value: Int
    let step: Int
    let range: ClosedRange<Int>

    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.accentColor1B)
                Text(String(format: "%02d", value))
                    .font(.custom("Myfont-Regular", size: 40))
                    .textShadow(x: 2, y: 2, color: .primaryText.opacity(0.5))
                    .foregroundStyle(.textboxBackground)
                    .padding(.top)
            }
            HStack {
                Text(label)
                Spacer()
                Button { value -= step } label: {
                    Image(systemName: "minus.circle.fill")
                }
                .disabled(value - step < range.lowerBound)
                Button { value += step } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .disabled(value + step > range.upperBound)
            }
        }
        .frame(height: 125)
    }
}

#Preview {
    AddEditTaskView(mode: .add, date: Date())
        .environment(PotatoPlannerStore.preview.self)
}
