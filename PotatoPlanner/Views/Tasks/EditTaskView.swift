//
//  EditTaskView.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/10/25.
//

import SwiftUI

struct EditTaskView: View {
    @Environment(PotatoPlannerStore.self) var store
    @Environment(\.dismiss) private var dismiss
    
    let task: TaskEntity
    
    @State private var title: String = ""
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var description: String = ""
    @State private var scheduledDate: Date = Date()
    
    private var allocatedSeconds: Int {
        (hours * 3600) + (minutes * 60)
    }

    private var isSaveDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || allocatedSeconds <= 0
    }
    
    private enum Constants {
        static let listBackground: Color = .textboxBackground
        static let primaryBackground: Color = .accentColor1A
        static let listTextColor: Color = .primaryText
        static let tintColor: Color = .accentColor1C
    }
    
    init(task: TaskEntity) {
        self.task = task
        _title = State(initialValue: task.title)
        _hours = State(initialValue: task.allocatedSeconds.asHours)
        _minutes = State(initialValue: task.allocatedSeconds.asRemainingMinutes)
        _description = State(initialValue: task.taskDescription ?? "")
        _scheduledDate = State(initialValue: task.scheduledDate)
    }
    
    var body: some View {
        NavigationStack {
            formContent
            .appTheme()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Back")
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            store.updateTask(
                                task,
                                title: title,
                                description: description,
                                allocatedSeconds: allocatedSeconds,
                                scheduledDate: scheduledDate
                            )
                            dismiss()
                        }
                        .disabled(isSaveDisabled)
                    }
                }
        }
    }
    
    var formContent: some View {
        Form {
            titleAndDescription
            timeStepper
            datePicker
            finishEarlyButton
            deleteButton
        }
        .listSectionSpacing(10)
        .foregroundStyle(Constants.listTextColor)
        .scrollContentBackground(.hidden)
        .background(
            Image("TaskBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .tint(Constants.tintColor)
    }
    
    var titleAndDescription: some View {
        Section {
            TextField("Task", text: $title)
            TextField("Description (Optional)", text: $description)
        } header: {
            HStack {
                Spacer()
                Text("Edit Task")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.textboxBackground)
                    .textStroke(width: 1, color: .primaryText)
                    .padding(.bottom, 4)
                Spacer()
            }
        }
        .listRowBackground(Constants.listBackground)
    }
    
    var timeStepper: some View {
        Section {
            HStack {
                Stepper(value: $hours, in: 0...10, step:1) {
                    Text("\(hours) h")
                }
                .padding(.trailing, 25)
                Stepper(value: $minutes, in: 0...55, step:5) {
                    Text("\(minutes) m")
                }
            }
        }
        .listRowBackground(Constants.listBackground)
    }
    
    var datePicker: some View {
        Section() {
            DatePicker(
                "",
                selection: $scheduledDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .tint(.accentColor1B)
        }
        .listRowBackground(Constants.listBackground)
    }
    
    var finishEarlyButton: some View {
        Section {
            Button {
                store.finishTaskEarly(task)
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "checkmark")
                    Text("Finish task early")
                }
            }
        }
        .listRowBackground(Constants.listBackground)
    }
    
    var deleteButton: some View {
        Section {
            Button {
                store.deleteTask(task)
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete")
                }
            }
        }
        .listRowBackground(Constants.listBackground)
    }
}

#Preview {
    EditTaskView(task: .preview)
        .environment(PotatoPlannerStore.preview)  
}
