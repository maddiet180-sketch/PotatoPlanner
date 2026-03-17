//
//  MainPotatoView.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/18/25.
//

import SwiftUI

struct MainPotatoView: View {
    let potato: PotatoEntity
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                potatoStats
                Spacer()
            }
            .padding()
            .frame(width: 150)
            // FIXME: add geo reader to cover about 33%
            Group {
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.accentColor3B)
                        .opacity(0.4)
                        .padding()
                        .padding(.vertical)
                    potatoImage
                }
                Spacer()
            }
        }
        .frame(height: 225)
        .background(potatoCardBackground)
    }
    
    private var potatoImage: some View {
        VStack {
            if let potatoType = PotatoCatalog.kind(for: potato.typeID) {
                Spacer()
                Image(potatoType.imageName(for: potato.level))
                    .resizable()
                    .scaledToFit()
            }
        }
    }
    
    private var potatoCardBackground: some View {
        RoundedRectangle(cornerRadius: 12.0)
            .fill(.textboxBackground)
            .stroke(Color(.primaryText), lineWidth: 3)
    }
    
    private var potatoType: PotatoType? {
        PotatoCatalog.kind(for: potato.typeID)
    }

    private var potatoStats: some View {
        VStack(alignment: .leading) {
            Text(potato.name)
                .font(.title2.bold())
            if let potatoType {
                plantTypeLabel(potatoType)
                levelRow(potatoType)
                fertilizerRow(potatoType)
            }
        }
    }

    private func plantTypeLabel(_ potatoType: PotatoType) -> some View {
        Text(potatoType.plantType)
            .font(.caption.italic())
            .foregroundStyle(.secondary)
    }

    private func levelRow(_ potatoType: PotatoType) -> some View {
        HStack {
            Image("FertilizerIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 40)
            Divider()
                .frame(width: 2, height: 25)
                .overlay(.accentColor3C)
            Text(potato.isMaxLevel
                 ? "Max \nLevel"
                 : "Level: \n\(potato.level) of \(potatoType.maxLevel)")
                .font(.subheadline)
        }
    }

    private func fertilizerRow(_ potatoType: PotatoType) -> some View {
        let count = potato.fertilizer
        let needed = potatoType.fertilizerNeeded(for: potato.level)
        let progress = Double(count) / Double(needed)

        return VStack(alignment: .leading) {
            ProgressView(value: potato.isMaxLevel ? 1.0 : progress)
                .tint(.accentColor3C)
            Text(potato.isMaxLevel
                 ? "\(needed) / \(needed) fertilizer"
                 : "\(count) / \(needed) fertilizer")
                .font(.caption2)
        }
    }
}

#Preview {
    MainPotatoView(potato: .preview)
        .environment(PotatoPlannerStore.preview)  
}
