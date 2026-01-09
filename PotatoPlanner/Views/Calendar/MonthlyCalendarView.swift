//
//  MonthlyCalenderView.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/14/25.
//

import SwiftUI

struct MonthlyCalendarView: View {
    @EnvironmentObject var potatoViewModel: PotatoPlannerModel
    @State private var currentDate: Date = Date()
    @State private var didAppear = false
    
    var body: some View {
        VStack {
            calendarTitle
            mainCalendar
            DailyTasks(selectedDate: $currentDate, style: .calendar)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .safeAreaPadding(.top, 40)
        .safeAreaPadding(.bottom, 90)
        .padding(.horizontal, 20)
        .appTheme()
    }
    
    private var calendarTitle: some View {
        Text("Plan Ahead")
            .font(.largeTitle.bold())
            .foregroundStyle(.accentColor1C)
            .textStroke(width: 2, color: .textboxBackground)
    }
    
    private var mainCalendar: some View {
        DatePicker(
            "Date Selection",
            selection: $currentDate,
            displayedComponents: [.date]
        )
        .datePickerStyle(.graphical)
        .tint(.accentColor1B)
        .padding()
        .background(calendarBackground)
        .opacity(didAppear ? 1 : 0.99) // Forces redraw
        .onAppear {
            // Workaround to force DatePicker to keep its inital layout
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.01)) {
                    didAppear = true
                }
            }
        }
    }
    
    private var calendarBackground: some View {
        RoundedRectangle(cornerRadius: 13)
            .fill(.textboxBackground)
            .stroke(.primaryText, lineWidth: 3)
    }
}

#Preview {
    MonthlyCalendarView()
        .environmentObject(PotatoPlannerModel())
}
