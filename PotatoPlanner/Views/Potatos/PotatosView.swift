//
//  PotatosView.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/14/25.
//

import SwiftUI

struct PotatosView: View {
    @EnvironmentObject var potatoViewModel: PotatoPlannerModel
    @State var showingDetailedPotatoView: Bool = false
    @State private var selectedPotatoType: PotatoType?
    
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
    }
    
    private var potatoCards: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 12)]) {
            ForEach(PotatoCatalog.all) { potatoType in
                PotatoCardView(potatoType: potatoType)
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

struct PotatoCardView: View {
    @EnvironmentObject var potatoViewModel: PotatoPlannerModel
    let potatoType: PotatoType
    
    private var ownedPotato: Potato? {
        potatoViewModel.ownedPotato(for: potatoType)
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
                    .font(.subheadline)
            } else {
                Text(potatoType.displayName)
                    .font(.subheadline)
            }
            
            potatoImage
                .padding(4)
            PotatoActionButton(potatoType: potatoType, style: .compact)
            
        }
        .padding()
    }
    
    private var potatoImage: some View {
        Image(potatoType.imageName(for: ownedPotato?.level ?? 1))
            .resizable()
            .scaledToFit()
    }
}

#Preview {
    PotatosView()
        .environmentObject(PotatoPlannerModel())
}

