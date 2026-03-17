//
//  PotatosView.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/14/25.
//

import SwiftUI

struct PotatosView: View {
    let selectedTab: Tab
    
    @State var showingDetailedPotatoView: Bool = false
    @State private var selectedPotatoType: PotatoType?
    @State private var confirmingPotatoType: PotatoType?

    var body: some View {
        ScrollView {
            potatoCards
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .safeAreaPadding(.top, 40)
        .safeAreaPadding(.bottom, 90)
        .appTheme()
        .overlay {
            if showingDetailedPotatoView {
                DetailedPotatoView(isShowing: $showingDetailedPotatoView,
                                   initialPotato: selectedPotatoType ?? PotatoCatalog.starterKind)
            }
        }
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
    PotatosView(selectedTab: .potato)
        .environment(PotatoPlannerStore.preview)
}

