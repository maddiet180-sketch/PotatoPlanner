//
//  SessionResult.swift
//  PotatoPlanner
//
//  Created by Madeline Moody on 3/11/26.
//

import Foundation

struct SessionResult: Identifiable {
    let id = UUID()
    let spudsEarned: Int
    let fertilizerEarned: Int
    let levelsGained: Bool
}
