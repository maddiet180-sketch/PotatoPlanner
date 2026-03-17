//
//  MonthlyCalenderView.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/14/25.
//

import SwiftUI

struct MonthlyCalendarView: View {
    let selectedTab: Tab
    
    @State private var currentDate: Date = Date()
    @State private var didAppear = false
    
    var body: some View {
        VStack {
            calendarTitle
            mainCalendar
            DailyTasks(style: .calendar, selectedDate: $currentDate)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .safeAreaPadding(.top, 40)
        .safeAreaPadding(.bottom, 90)
        .padding(.horizontal, 20)
        .appTheme()
        .onChange(of: selectedTab) {
            currentDate = Date()
        }
    }
    
    private var calendarTitle: some View {
        Text("Plan Ahead")
            .font(.largeTitle.bold())
            .foregroundStyle(.accentColor1C)
            .textStroke(width: 0.7, color: .textboxBackground)
    }
    
    private var mainCalendar: some View {
        DatePicker(
            "Date Selection",
            selection: $currentDate,
            displayedComponents: [.date]
        )
        .datePickerStyle(.graphical)
        .tint(.accentColor3B)
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
    MonthlyCalendarView(selectedTab: .calendar)
        .environment(PotatoPlannerStore.preview)  
}

