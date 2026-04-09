//
//  CustomCalendar.swift
//  PotatoPlanner
//
//  Created by Madeline Moody on 4/2/26.
//

import SwiftUI

// Custom claendar inspired by Stewart Lynch on YouTube
// youtube.com/watch?v=X_boPC1tg_Y

struct CustomCalendarView: View {
    @Environment(PotatoPlannerStore.self) var store
    @State private var displayedMonth: Date = Date()
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdaySymbols = Calendar.current.veryShortWeekdaySymbols
    private let accentColor: Color = .accentColor1B
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                calendarHeader
                daysGrid
            }
            .background(.textboxBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 13)
                    .fill(.clear)
                    .stroke(.primaryText, lineWidth: 7)
            )
            .clipShape(RoundedRectangle(cornerRadius: 13))
//            .padding(.horizontal, 20)
            .padding(.top, 14)
            
            Image("CalendarFrame")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .appTheme()
    }
    
    private var calendarHeader: some View {
        VStack(spacing: -5) {
            HStack {
                Text(displayedMonth .formatted(.dateTime.month(.wide).year()))
                    .font(.custom("Myfont-Regular", size: 24))
                Spacer()
                navButton(direction: "left")
                navButton(direction: "right")
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(weekdaySymbols.indices, id: \.self) { idx in
                    Text(weekdaySymbols[idx])
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
//                        .font(.custom("Myfont-Regular", size: 18))
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 23)
        .background(.accentColor3B)
        .foregroundStyle(.textboxBackground)
    }
        
    private var daysGrid: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(0..<firstEmptyWeekdays, id: \.self) { _ in
                    Color.clear.frame(height: 40)
                }
                
                ForEach(daysInMonth, id:\.self) { date in
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: store.selectedDate),
                            isToday: calendar.isDateInToday(date),
                            hasTasks: store.hasTasks(on: date)
                        )
                        .onTapGesture {apGesture in
                            store.selectedDate = date
                        }
                }
            }
        }
        .padding([.bottom, .leading, .trailing])
        .padding(.top, 8)
    }
    
    private func navButton(direction: String) -> some View {
        Button {
            shiftMonth(by: direction == "left" ? -1 : 1)
        } label: {
            Image(systemName: "chevron.\(direction).circle.fill")
                .font(.title.bold())
                .symbolRenderingMode(.palette)
                .foregroundStyle(.textboxBackground, .accentColor3C)
        }
    }
    
    private var firstEmptyWeekdays: Int {
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) else { return 0 }
        // calendar.firstWeekday is 1-based (1 = Sunday); weekday(of:) is also 1-based
        let weekday = calendar.component(.weekday, from: monthStart)
        return (weekday - calendar.firstWeekday + 7) % 7
    }
    
    private var daysInMonth: [Date] {
        guard
            let range = calendar.range(of: .day, in: .month, for: displayedMonth),
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))
        else { return [] }
 
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: monthStart)
        }
    }
    
    private func shiftMonth(by offset: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: offset, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasTasks: Bool
    
    private let accentColor: Color = .accentColor1C
    
    var body: some View {
        VStack(spacing: 0) {
            Text(date.formatted(.dateTime.day()))
                .padding(5)
                .foregroundStyle(isToday ? .textboxBackground : isSelected ? accentColor : .primaryText)
                .background(
                    Circle()
                        .foregroundStyle(isToday ? accentColor : .clear)
                        .opacity(isSelected ? 1.0 : 0.6)
                        .frame(width: 30)
                )
            
            Circle()
                .fill(hasTasks ? .accentColor3C : .clear)
                .frame(width: 7)
        }
        .frame(width: 40, height: 40)
        .contentShape(Rectangle())
    }
}

#Preview {
    CustomCalendarView()
        .environment(PotatoPlannerStore.preview)
}
