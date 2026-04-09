//
//  AppStateEntity.swift
//  PotatoPlanner
//
//  Created by Madeline Moody on 3/10/26.
//

import Foundation
import SwiftData

/// SINGLETON SwiftData record that holds global app state (spuds, active potato, active session).
@Model
final class AppStateEntity {
    var spuds: Int
    var activePotatoID: UUID?
    var activeSessionTaskID: UUID?
    var isBGMOn: Bool = true
    var isRainOn: Bool = true
    var bgmVolume: Float = 0.05
    var rainVolume: Float = 0.28

    init(spuds: Int = 0, activePotatoID: UUID? = nil) {
        self.spuds = spuds
        self.activePotatoID = activePotatoID
        self.activeSessionTaskID = nil
    }
}
