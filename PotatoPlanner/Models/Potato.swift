//
//  Potato.swift
//  PotatoPlanner
//
//  Created by Madeline Moody on 3/10/26.
//

import Foundation

// MARK: Potato
struct Potato: Identifiable, Codable {
    let id: UUID
    let typeID: String
    let name: String
    var level: Int
    var fertilizer: Int = 0
}

// Calculated properties
extension Potato {
    var isMaxLevel: Bool {
        guard let potatoType = PotatoCatalog.kind(for: self.typeID) else { return false }
        
        return potatoType.maxLevel <= self.level
    }
}

// Preview
extension Potato {
    static let preview = Potato(
            id: UUID(),
            typeID: "stephania",
            name: "Stephany",
            level: 1,
            fertilizer: 12
    )
}
