//
//  PotatoCatalog.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/18/25.
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

enum PotatoCatalog {
    static let all: [PotatoType] = [
        PotatoType(
            id: "stephania",
            displayName: "Stephan",
            plantType: "Stephania Erecta",
            plantInfo: "likes to paint and ride bikes.",
            maxLevel: 7,
            baseFertilizerPerLevel: 1,
            fertilizerMultiplier: 1.0,
            cost: 0
        ),
        
        PotatoType(
            id: "cephara",
            displayName: "Cecil",
            plantType: "Stephania Cepharantha",
            plantInfo: "is a very pretty flower.",
            maxLevel: 9,
            baseFertilizerPerLevel: 2,
            fertilizerMultiplier: 1.5,
            cost: 100
        ),
        
//        PotatoType(
//            id: "tato",
//            displayName: "Channing Tato",
//            plantType: "Just a Potato",
//            plantInfo: "is a prickly plant.",
//            maxLevel: 3,
//            baseFertilizerPerLevel: 10,
//            fertilizerMultiplier: 1.2,
//            cost: 175
//        ),
    ]
    
    static let byID: [String: PotatoType] = {
        Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
    }()

    static func kind(for id: String) -> PotatoType? {
        byID[id]
    }

    static var starterKind: PotatoType {
        byID["stephania"]!
    }
}
