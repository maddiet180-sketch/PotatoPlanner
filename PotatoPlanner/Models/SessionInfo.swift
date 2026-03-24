//
//  SessionInfo.swift
//  PotatoPlanner
//
//  Created by Madeline Moody on 3/24/26.
//

import Foundation

/// In-memory timing state for the active focus session.
/// Not persisted — lives on the store so it survives view recreation.
struct SessionInfo {
    var elapsedSeconds: Int = 0
    var isPaused: Bool = false
    var enterBackgroundDate: Date? = nil
}
