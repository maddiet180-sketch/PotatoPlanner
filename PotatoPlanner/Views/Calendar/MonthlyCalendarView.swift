//
//  MonthlyCalenderView.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/14/25.
//

import SwiftUI

struct MonthlyCalendarView: View {
    @Environment(PotatoPlannerStore.self) var store
    let selectedTab: Tab

    @State private var didAppear = false

    var body: some View {
        @Bindable var store = store
        VStack(spacing: 10) {
            calendarTitle
            CustomCalendarView()
            DailyTasks(style: .calendar)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .safeAreaPadding(.top, 40)
        .safeAreaPadding(.bottom, 80)
        .padding(.horizontal, 20)
        .appTheme()
        .appBackground()
        .onChange(of: selectedTab) {
            store.selectedDate = Date()
        }
    }
    
    private var calendarTitle: some View {
        Text("Plan Ahead")
            .font(.custom("Myfont-Regular", size: 35))
            .textShadow(x: 3, y: 3, color: .primaryText)
            .foregroundStyle(.textboxBackground)
    }
}

#Preview {
    MonthlyCalendarView(selectedTab: .calendar)
        .environment(PotatoPlannerStore.preview)  
}

