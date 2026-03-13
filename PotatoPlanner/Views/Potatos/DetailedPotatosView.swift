//
//  DetailedPotatosView.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/28/25.
//

import SwiftUI

struct DetailedPotatoView: View {
    @Environment(PotatoPlannerStore.self) var store
    @Binding var isShowing: Bool
    @State private var displayPotatoType: PotatoType
    @State private var confirmingPotatoType: PotatoType?

    init(isShowing: Binding<Bool>, initialPotato: PotatoType) {
        self._isShowing = isShowing
        self._displayPotatoType = State(initialValue: initialPotato)
    }

    var body: some View {
        ZStack {
            Color.primaryText.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isShowing = false
                }

            HStack {
                PotatoNavButton(displayPotatoType: $displayPotatoType, direction: .left)

                VStack {
                    DeatiledPotatoCard(displayPotatoType: displayPotatoType)
                    PotatoActionButton(
                        potatoType: displayPotatoType,
                        style: .large,
                        onBuyTapped: { confirmingPotatoType = displayPotatoType }
                    )
                }

                PotatoNavButton(displayPotatoType: $displayPotatoType, direction: .right)
            }
            .padding(.horizontal)

            if let potatoType = confirmingPotatoType {
                Color.primaryText.opacity(0.0001)
                    .ignoresSafeArea()
                    .onTapGesture { confirmingPotatoType = nil }
                PurchaseConfirmationPopup(
                    isShowing: Binding(
                        get: { confirmingPotatoType != nil },
                        set: { if !$0 { confirmingPotatoType = nil } }
                    ),
                    potatoType: potatoType
                )
            }
        }
    }
}

struct PotatoNavButton: View {
    @Binding var displayPotatoType: PotatoType
    let direction: NavigationDirection
    
    enum NavigationDirection {
        case left, right
        
        var offset: Int {
            self == .right ? 1 : -1
        }
        
        var arrowName: String {
            self == .right ? "chevron.right" : "chevron.left"
        }
    }
    
    var body: some View {
        Button {
            changeDisplayPotato()
        } label: {
            Image(systemName: direction.arrowName)
                .font(.title.bold())
                .foregroundStyle(.textboxBackground)
                .textStroke(width: 1, color: .primaryText)
        }
    }
    
    private func changeDisplayPotato() {
        guard let currentIndex = PotatoCatalog.all.firstIndex(where: { $0.id == displayPotatoType.id}) else { return }
        
        let newIndex = currentIndex + direction.offset
        
        let finalIndex: Int
        if newIndex == PotatoCatalog.all.count {
            finalIndex = 0
        }
        else if newIndex < 0 {
            finalIndex = PotatoCatalog.all.count - 1
        } else {
            finalIndex = newIndex
        }
        print(finalIndex)
        displayPotatoType = PotatoCatalog.all[finalIndex]
    }
}

struct DeatiledPotatoCard: View {
    @Environment(PotatoPlannerStore.self) var store
    
    let displayPotatoType: PotatoType
    
    private var ownedPotato: PotatoEntity? {
        store.ownedPotato(for: displayPotatoType)
    }
    
    private var isOwned: Bool {
        ownedPotato != nil
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 13)
                .fill(.textboxBackground)
                .stroke(.primaryText, lineWidth: 3)
                        
            VStack {
                ZStack {
                    transparentBox
                        .padding()
                    Image(displayPotatoType.imageName(for: potatoLevel))
                        .resizable()
                        .scaledToFit()
                }
                
                Spacer()
                
                potatoInfo
            }
            
            if !isOwned {
                Color.primaryText.opacity(0.4)
                    .ignoresSafeArea()
                
                Image(systemName: "lock.fill")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.textboxBackground)
                    .textStroke(width: 1, color: .primaryText)
            }
        }
        .frame(height: 450)
    }
    
    var potatoLevel: Int {
        store.ownedPotato(for: displayPotatoType)?.level ?? 1
    }
    
    var transparentBox: some View {
        VStack {
            RoundedRectangle(cornerRadius: 13)
                .fill(.accentColor3)
                .opacity(0.4)
                .padding()
            Spacer()
        }
    }
    
    var potatoInfo: some View {
        VStack(alignment: .leading) {
            if let ownedPotato {
                PotatoInfo(potato: ownedPotato, style: .detailed)
                
            } else {
                Text(String(displayPotatoType.displayName))
                    .font(.title.bold())
                Text(String(displayPotatoType.plantType))
                    .fontWeight(.regular)
                    .font(.body.italic())
                Text("Not yet owned!")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .padding(.bottom)
    }
}

#Preview {
    DetailedPotatoView(isShowing: .constant(true), initialPotato: PotatoCatalog.starterKind)
        .environment(PotatoPlannerStore.preview)
}
