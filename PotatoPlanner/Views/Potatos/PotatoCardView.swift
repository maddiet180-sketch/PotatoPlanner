//
//  PotatoCardView.swift
//  PotatoPlanner
//
//  Created by Madeline Moody on 3/12/26.
//

import SwiftUI

struct PotatoCardView: View {
    @Environment(PotatoPlannerStore.self) var store
    
    let potatoType: PotatoType
    var onBuyTapped: (() -> Void)? = nil
    
    private var ownedPotato: PotatoEntity? {
        store.ownedPotato(for: potatoType)
    }
    
    private var isOwned: Bool {
        ownedPotato != nil
    }
    
    var body: some View {
        ZStack {
            cardBackground

            if !isOwned {
                Color.primaryText.opacity(0.4)
                    .ignoresSafeArea()
            }
            
            compactCardContent
            
            if !isOwned {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.textboxBackground)
                    .font(.title.bold())
            }
        }
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.textboxBackground)
            .stroke(.primaryText, lineWidth: 3)
    }

    
    private var compactCardContent: some View {
        VStack {
            if let owned = ownedPotato {
                Text(owned.name)
                    .font(.title3.bold())
            } else {
                Text(potatoType.displayName)
                    .font(.title3.bold())
            }
            
            ZStack {
                if isOwned {
                    transparentBox
                }
                potatoImage
                    .padding(4)
            }
            
            PotatoActionButton(potatoType: potatoType, style: .compact, onBuyTapped: onBuyTapped)
            
        }
        .padding()
    }
    
    private var transparentBox: some View {
        VStack {
            RoundedRectangle(cornerRadius: 13)
                .fill(.accentColor3B)
                .opacity(0.4)
        }
    }
    
    private var potatoImage: some View {
        Image(potatoType.imageName(for: ownedPotato?.level ?? 1))
            .resizable()
            .scaledToFit()
    }
}

#Preview {
    PotatoCardView(potatoType: PotatoCatalog.starterKind)
        .environment(PotatoPlannerStore.preview)
}
