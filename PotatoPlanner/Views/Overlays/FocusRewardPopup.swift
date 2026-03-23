//
//  FocusRewardPopup.swift
//  PotatoPlanner
//
//  Created by Madeline Moody on 3/11/26.
//

import SwiftUI

struct FocusRewardPopup: View {
    @State private var offset: CGFloat = 1000
    
    @Binding var isShowing: Bool
    var result: SessionResult
    
    var body: some View {
        VStack {
            infoText
                .padding()
            if result.spudsEarned > 0 {
                spuds
            }
            if result.fertilizerEarned > 0 {
                fertilizer
            }
        }
        .foregroundStyle(.primaryText)
        .fixedSize(horizontal: true, vertical: true)
        .padding()
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 13)
                .fill(.textboxBackground)
                .stroke(.primaryText, lineWidth: 9)
        )
        .clipShape(RoundedRectangle(cornerRadius: 13))
        .overlay {
            exitButton
        }
        .shadow(radius: 13)
        .offset(x: 0, y:offset)
        .onAppear {
            withAnimation(.smooth) {
                offset = 0
            }
        }
    }
    
    private var infoText: some View {
        VStack {
            Text("Great Work!")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundStyle(.accentColor2A)
                .textStroke(width: 0.5, color: .primaryText)
            Text("you've earned...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var spuds: some View {
        HStack {
            Image("SpudIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40)
            Text("\(result.spudsEarned) spuds")
                .font(.title3)
                .fontWeight(.semibold)
        }
    }
    
    private var fertilizer: some View {
        HStack {
            Image("FertilizerIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30)
            Text("\(result.fertilizerEarned) fertilizer")
                .font(.title3)
                .fontWeight(.semibold)
        }
    }
    
    private var exitButton: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    close()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .fontWeight(.medium)
                }
            }
            Spacer()
        }
        .foregroundStyle(.primaryText)
        .padding()
    }
    
    func close() {
        withAnimation(.spring()) {
            offset = 1000
            isShowing = false
        }
    }
}

#Preview {
    FocusRewardPopup(isShowing: .constant(true), result: SessionResult(spudsEarned: 10, fertilizerEarned: 12, levelsGained: false))
}
