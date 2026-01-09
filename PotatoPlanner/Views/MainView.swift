//
//  TodayView.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/9/25.
//

import SwiftUI
internal import Combine

struct MainView: View {
    @EnvironmentObject var potatoViewModel: PotatoPlannerModel
    @State private var showingAddTask: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 15) {
                
                DateDisplay()
                
                if let activePotato = potatoViewModel.activePotato {
                    MainPotatoView(potato: activePotato)
                }
                
                DailyTasks(style: .main)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .safeAreaPadding(.top, 40)
            .safeAreaPadding(.bottom, 90)
            .padding(.horizontal, 20)
            .appTheme()
        }
    }
    // FIXME: add geo reader for the top and bottom bars and time text
}

struct DateDisplay: View {
    @State private var currentDate = Date.now
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var weekday: String {
        currentDate.formatted(.dateTime.weekday(.wide))
    }
    
    private var fullDate: String {
        currentDate.mediumDate
    }
    
    private var time: String {
        currentDate.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute())
    }
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .trailing, spacing: 0) {
                Text(weekday)
                    .font(.largeTitle.bold())
                    .textStroke(width: 1, color: .primaryText)
                Text(fullDate)
                    .font(.title3)
            }
            Divider() // FIX ME: make the font scale with size
                .frame(width: 5, height: 55)
                .overlay(.primaryText)
            Text(time)
                .font(.system(size: 55))
                .fontWidth(.condensed)
                .textStroke(width: 1, color: .primaryText)
        }
        .foregroundStyle(.textboxBackground)
        .onReceive(timer) { newDate in
            let oldMinute = Calendar.current.component(.minute, from: currentDate)
            let newMinute = Calendar.current.component(.minute, from: newDate)
            
            if oldMinute != newMinute {
                currentDate = newDate
            }
        }
        .onAppear {
            currentDate = Date.now
        }
    }

}

#Preview {
    RootView()
        .environmentObject(PotatoPlannerModel())
}
