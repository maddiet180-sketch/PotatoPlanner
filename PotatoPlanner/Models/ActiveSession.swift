//
//  ActiveSession.swift
//  PotatoPlanner
//
//  Created by Madeline Moody on 3/10/26.
//

import Foundation

// MARK: ActiveSession
struct ActiveSession: Codable{
    let taskID: UUID
    let startedAt: Date
}
