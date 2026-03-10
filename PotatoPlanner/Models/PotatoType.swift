//
//  PotatoType.swift
//  PotatoPlanner
//
//  Created by Madeline Moody on 3/10/26.
//

import Foundation

struct PotatoType: Identifiable, Codable {
    let id: String
    let displayName: String
    let plantType: String
    let plantInfo: String
    let maxLevel: Int
    let baseFertilizerPerLevel: Int
    let fertilizerMultiplier: Double
    let cost: Int
}

extension PotatoType {
    
    // Returns name of asset image corresponding to
    func imageName(for level: Int) -> String {
        let clampedLevel = min((max(1, level)), maxLevel)
        return "\(id)_level\(clampedLevel)"
    }
    
    // How much fertilizer to get from curretn level to the next
    func fertilizerNeeded(for level: Int) -> Int {
        let factor = pow((1 + fertilizerMultiplier), Double(level - 1))
        return Int((Double(baseFertilizerPerLevel)*factor))
    }
}
