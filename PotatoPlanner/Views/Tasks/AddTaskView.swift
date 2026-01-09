//
//  AddTaskView.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/9/25.
//

import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var potatoViewModel: PotatoPlannerModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var hours: Int = 0
    @State private var minutes: Int = 5
    @State private var description: String = ""
    @State private var internalDate: Date = Date.now
    
    private var allocatedSeconds: Int {
        (hours * 3600) + (minutes * 60)
    }

    private var isAddDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || allocatedSeconds <= 0
    }
    
    private enum Constants {
        static let listBackground: Color = .textboxBackground
        static let primaryBackground: Color = .accentColor1A
        static let listTextColor: Color = .primaryText
        static let tintColor: Color = .accentColor1C
    }
    
    let style: PickerStyle
    let externalDate: Binding<Date>?
    
    enum PickerStyle {
        case compact, standard
    }
    
    init(style: PickerStyle = .compact, scheduledDate: Binding<Date>) {
        self.externalDate = scheduledDate
        self.style = style
    }
    
    init(style: PickerStyle) {
        self.externalDate = nil
        self.style = style
    }
    
    private var scheduledDate: Binding<Date> {
        externalDate ?? $internalDate
    }
    
    var body: some View {
        NavigationStack {
            formContent
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
                ToolbarItem(placement: .confirmationAction) {
                    addButton
                }
            }
        }
        .appTheme()
    }
    
    private var formContent: some View {
        Form {
            titleAndDescription
            timeStepper
            datePicker
        }
        .listSectionSpacing(10)
        .foregroundStyle(Constants.listTextColor)
        .scrollContentBackground(.hidden)
        .tint(Constants.tintColor)
        .background(
            Image("TaskBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }
    
    private var titleAndDescription: some View {
        Section {
            TextField("Task", text: $title)
            TextField("Description (Optional)", text: $description)
        }
        header: {
            Text("Add Task")
                .font(.largeTitle.bold())
                .foregroundStyle(.primaryText)
                .padding(.bottom, 4)
        }
        .listRowBackground(Constants.listBackground)
    }
    
    private var timeStepper: some View {
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
    
    private var datePicker: some View {
        Section() {
            switch style {
            case .standard:
                standardPicker
            case .compact :
                compactPicker
            }
        }
        .listRowBackground(Constants.listBackground)
    }
    
    private var standardPicker: some View {
        DatePicker(
            "",
            selection: scheduledDate,
            displayedComponents: [.date]
        )
        .datePickerStyle(.graphical)
        .tint(.accentColor1B)
    }
    
    private var compactPicker: some View {
        DatePicker(
            "Date Scheduled",
            selection: scheduledDate,
            displayedComponents: [.date]
        )
        .tint(.accentColor1B)
    }
    
    private var backButton: some View {
        Button("Back") {
            dismiss()
        }
        .tint(.textboxBackground)
    }
    
    private var addButton: some View {
        Button("Add") {
            potatoViewModel.addTask(
                title: title,
                description: description,
                allocatedSeconds: allocatedSeconds,
                scheduledDate: scheduledDate.wrappedValue
            )
            dismiss()
        }
        .disabled(isAddDisabled)
    }
}

#Preview {
    AddTaskView(style: .standard)
        .environmentObject(PotatoPlannerModel())
}
