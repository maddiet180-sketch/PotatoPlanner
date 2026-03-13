//
//  PurchaseConfirmationPopup.swift
//  PotatoPlanner
//
//  Created by Madeline Moody on 3/12/26.
//

import SwiftUI

struct PurchaseConfirmationPopup: View {
    @Environment(PotatoPlannerStore.self) var store
    @State private var offset: CGFloat = 1000
    @Binding var isShowing: Bool
    
    var potatoType: PotatoType
    
    var body: some View {
        VStack {
            infoText
            spuds
            purchaseButton
        }
        .foregroundStyle(.primaryText)
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
        .fixedSize(horizontal: false, vertical: true)
        .offset(x: 0, y:offset)
        .onAppear {
            withAnimation(.smooth) {
                offset = 0
            }
        }
        .padding()
    }
    
    private var infoText: some View {
        VStack {
            Text("Are you sure you'd like to purchase \(potatoType.displayName)?")
                .font(.title3)
                .fontWeight(.semibold)
        }
        .multilineTextAlignment(.center)
    }
    
    private var spuds: some View {
        HStack {
            Image("SpudIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30)
            Text("\(potatoType.cost)")
                .font(.title)
                .fontWeight(.semibold)
        }
    }
    
    private var purchaseButton: some View {
        Button {
            store.buyPotato(of: potatoType)
            close()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 40)
                    .fill(.accentColor1B)
                    .frame(width: 230, height: 40)
                Text("purchase")
                    .foregroundStyle(.textboxBackground)
                    .fontWeight(.heavy)
                    .padding()
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
    PurchaseConfirmationPopup(
        isShowing: .constant(true),
        potatoType: PotatoType(
            id: "stephania", displayName: "stephan", plantType: "example", plantInfo: "example", maxLevel: 7, baseFertilizerPerLevel: 1, fertilizerMultiplier: 1.2, cost: 100
        )
    )
        .environment(PotatoPlannerStore.preview)
}
