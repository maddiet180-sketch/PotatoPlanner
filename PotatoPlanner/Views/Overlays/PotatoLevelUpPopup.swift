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
                                .font(.custom("Myfont-Regular", size: 30))
                                .textShadow(x: 2, y: 2, color: .primaryText)
                                .textStroke(width: 0.5, color: .primaryText)
                                .foregroundStyle(.accentColor2A)
                            Image(potatoType.imageName(for: activePotato.level))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 200)
                            Text("Level \(activePotato.level)")
                                .font(.title3)
                                .fontWeight(.heavy)
                        }
                    }
                }
            }
            .foregroundStyle(.primaryText)
            .appTheme()
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
            ConfettiPopup()
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
