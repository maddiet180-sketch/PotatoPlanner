//
//  PotatoesView.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/14/25.
//

import SwiftUI

struct PotatoesView: View {
    let selectedTab: Tab
    
    @State var showingDetailedPotatoView: Bool = false
    @State private var selectedPotatoType: PotatoType?
    @State private var confirmingPotatoType: PotatoType?

    var body: some View {
        ScrollView() {
//            ForEach(UIFont.familyNames.sorted(), id: \.self) { family in
//                        ForEach(UIFont.fontNames(forFamilyName: family), id: \.self) { font in
//                            Text(font)
//                                .font(.custom(font, size: 14))
//                        }
//                    }
            VStack(spacing: 0) {
                Text("Potatoes")
                    .font(.custom("Myfont-Regular", size: 35))
                    .textShadow(x: 3, y: 3, color: .primaryText)
                    .foregroundStyle(.textboxBackground)
                potatoCards
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .safeAreaPadding(.top, 40)
        .safeAreaPadding(.bottom, 80)
        .appTheme()
        .appBackground()
        .overlay {
            if showingDetailedPotatoView {
                DetailedPotatoView(isShowing: $showingDetailedPotatoView,
                                   initialPotato: selectedPotatoType ?? PotatoCatalog.starterKind)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showingDetailedPotatoView)
        .overlay {
            if let potatoType = confirmingPotatoType {
                ZStack {
                    Color.primaryText.opacity(0.5)
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
        .onChange(of: selectedTab) {
            showingDetailedPotatoView = false
        }
    }

    private var potatoCards: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 12)]) {
            ForEach(PotatoCatalog.all) { potatoType in
                PotatoCardView(potatoType: potatoType, onBuyTapped: { confirmingPotatoType = potatoType })
                    .aspectRatio(2/3, contentMode: .fit)
                    .onTapGesture {
                        showingDetailedPotatoView = true
                        selectedPotatoType = potatoType
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(4)
    }
}

#Preview {
    PotatoesView(selectedTab: .potato)
        .environment(PotatoPlannerStore.preview)
}

