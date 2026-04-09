//
//  TopBarView.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/18/25.
//

import SwiftUI

struct TopBarView: View {
    @Environment(PotatoPlannerStore.self) var store
    
    var body: some View {
        HStack{
            Image(systemName: "line.3.horizontal")
                .font(.title2.bold())
                .foregroundStyle(.textboxBackground)
            Spacer()
            rainButton
            bgmButton
            spudButton
        }
        .foregroundStyle(.primaryText)
        .fontWeight(.heavy)
        .frame(maxWidth: .infinity)
    }
    
    var rainButton: some View {
        Button() {
            store.isRainOn.toggle()
        } label: {
            Image(store.isRainOn ? "RainOnIcon" : "RainOffIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30)
        }
    }

    var bgmButton: some View {
        Button() {
            store.isBGMOn.toggle()
        } label: {
            Image(store.isBGMOn ? "SoundOnIcon" : "SoundOffIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30)
        }
    }
    
    var spudButton: some View {
        Button() {
            // FIXME: Add store
        } label: {
            ZStack(alignment: .trailing) {
                Image("SpudCount")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 30)
                Text("\(store.spuds)")
                    .padding(.trailing, 25)
                    .font(.body)
            }
        }
    }
}

#Preview {
    TopBarView()
        .environment(PotatoPlannerStore.preview)  
}
