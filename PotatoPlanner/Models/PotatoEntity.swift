//
//  PotatoEntity.swift
//  PotatoPlanner
//
//  Created by Madeline Moody on 3/10/26.
//

import Foundation
import SwiftData

@Model
final class PotatoEntity: Identifiable {
    var id: UUID
    var typeID: String
    var name: String
    var level: Int
    var fertilizer: Int

    init(
        id: UUID = UUID(),
        typeID: String,
        name: String,
        level: Int = 1,
        fertilizer: Int = 0
    ) {
        self.id = id
        self.typeID = typeID
        self.name = name
        self.level = level
        self.fertilizer = fertilizer
    }
}

extension PotatoEntity {
    var isMaxLevel: Bool {
        guard let potatoType = PotatoCatalog.kind(for: typeID) else { return false }
        return potatoType.maxLevel <= level
    }
}

extension PotatoEntity {
    static let preview = PotatoEntity(
        typeID: "stephania",
        name: "Stephany",
        level: 1,
        fertilizer: 12
    )
}
