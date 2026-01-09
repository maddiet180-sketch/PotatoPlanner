//
//  PotatoInfo.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 1/3/26.
//

import SwiftUI

struct PotatoInfo: View {
    let potato: Potato
    let style: PotatoInfoStyle
    
    enum PotatoInfoStyle {
        case main, detailed
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let potatoType = PotatoCatalog.kind(for: potato.typeID) {
                Text(String(potato.name))
                    .font(style == .detailed ? .title.bold() : .title2)
                Text(String(potatoType.plantType))
                    .font(style == .detailed ? .body.italic() : .caption.italic())
                    .fontWeight(.regular)
                Text(potato.isMaxLevel ? "Max Level" : "Level: \(potato.level) / \(potatoType.maxLevel)")
                    .font(style == .detailed ? .body : .caption)
                    .foregroundStyle(.secondary)
                
                let fertilizerCount = potato.fertilizer
                let fertilizerNeeded = potatoType.fertilizerNeeded(for: potato.level)
                let progress = Double(fertilizerCount) / Double(fertilizerNeeded)
                ProgressView(value: potato.isMaxLevel ? 1.0 : progress)
                    .tint(.accentColor1C)
                Text(potato.isMaxLevel ? "\(fertilizerNeeded) / \(fertilizerNeeded) fertilizer" : "\(fertilizerCount) / \(fertilizerNeeded) fertilizer")
                    .font(style == .detailed ? .caption : .caption2)
            }
        }
    }
}

#Preview {
    PotatoInfo(potato: .preview, style: .main)
}
