//
//  BottomBarView.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 1/8/26.
//

import SwiftUI

struct BottomBarView: View {
    @Binding var selectedTab: Tab
    var onAdd: () -> Void

    var body: some View {
        ZStack {
            navigationBarBackground
            HStack {
                Button { selectedTab = .calendar } label: {
                    Image("MiniCalendar")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 40)
                }
                Spacer()
                Button { selectedTab = .potato } label: {
                    Image("PotatoPlus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 50)
                }
            }
            .padding(.horizontal, 55)
            middleButton
        }
        .foregroundStyle(.accentColor1B)
        .font(.largeTitle.bold())
    }
    
    var navigationBarBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(.textboxBackground))
            .stroke(.primaryText, lineWidth: 3)
            .frame(width: .infinity, height: 60)
    }
    
    var middleButton: some View {
        ZStack {
            Circle()
                .fill(.accentColor1B)
                .stroke(.primaryText, lineWidth: 4)
                .frame(width: 70, height: 70)
            
            if selectedTab == .daily {
                addButton
            } else {
                homeButton
            }
        }
        .foregroundStyle(.primaryText)
    }
    
    var addButton: some View {
        Button(action: onAdd) {
            Image(systemName: "plus")
        }
        .foregroundStyle(.textboxBackground)
    }
    
    var homeButton: some View {
        Button(action: {selectedTab = .daily}) {
            Image(systemName: "house")
        }
        .foregroundStyle(.textboxBackground)
    }
}


//#Preview {
//    BottomBarView()
//}
