//
//  PotatoLevelUpPopup.swift
//  PotatoPlanner
//
//  Created by Madeline Moody on 3/12/26.
//

import SwiftUI

// Custom dialog box adapted from
// Mike Mikina on YouTube:
// https://www.youtube.com/watch?v=K5lj-S3grno

struct PotatoLevelUpPopup: View {
    @State private var offset: CGFloat = 1000
    @State private var flowerOffset: CGFloat = -1500
    @Environment(PotatoPlannerStore.self) var store
    
    @Binding var isShowing: Bool
    
    var body: some View {
        ZStack {
            VStack {
                if let activePotato = store.activePotato {
                    if let potatoType = PotatoCatalog.kind(for: activePotato.typeID) {
                        VStack {
                            Text("\(activePotato.name)...")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("Leveled Up!")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .foregroundStyle(.accentColor2A)
                                .textStroke(width: 0.5, color: .primaryText)
                            Image(potatoType.imageName(for: activePotato.level))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 150)
                            Text("Level \(activePotato.level)")
                                .font(.title3)
                                .fontWeight(.heavy)
                        }
                    }
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
            
            Group {
                Image("FlowerForeground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            .allowsHitTesting(false)
            .offset(x: 0, y:flowerOffset)
            .onAppear {
                withAnimation(.easeInOut.speed(0.05)) {
                    flowerOffset = 2000
                }
            }
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
    PotatoLevelUpPopup(isShowing: .constant(true))
        .environment(PotatoPlannerStore.preview)
}
