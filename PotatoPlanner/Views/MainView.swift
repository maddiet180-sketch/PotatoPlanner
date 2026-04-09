//
//  TodayView.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/9/25.
//

import SwiftUI
internal import Combine

struct MainView: View {
    let selectedTab: Tab
    
    @Environment(PotatoPlannerStore.self) var store
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 10) {
                
                DateDisplay()
                
                if let activePotato = store.activePotato {
                    MainPotatoView(potato: activePotato)
                }
                
                DailyTasks(style: .main)
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
        currentDate.formatted(.dateTime.month(.wide).day().year())
    }
    
    private var time: String {
        currentDate.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute())
    }
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .center, spacing: 0) {
                Text(weekday)
                    .font(.custom("Myfont-Regular", size: 35))
                    .textShadow(x: 2, y: 4, color: .primaryText)
                Text(fullDate)
                    .font(.custom("Myfont-Regular", size: 20))
                    .font(.title3)
            }
            Divider() // FIX ME: make the font scale with size
                .frame(width: 3, height: 55)
                .overlay(.primaryText)
            Text(time)
                .font(.custom("Myfont-Regular", size: 45))
                .textShadow(x: 4, y: 4, color: .primaryText)
                .padding(.top)
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
        .environment(PotatoPlannerStore.preview)  
}
