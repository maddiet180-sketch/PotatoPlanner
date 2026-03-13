//
//  Task.swift
//  PotatoPlanner
//
//  Created by Madeline Moody on 3/10/26.
//

import Foundation
import SwiftData

@Model
final class TaskEntity: Identifiable {
    var id: UUID
    var title: String
    var taskDescription: String?
    var allocatedSeconds: Int
    var completedSeconds: Int
    var scheduledDate: Date
    
    init(id: UUID, title: String, taskDescription: String? = nil, allocatedSeconds: Int, completedSeconds: Int, scheduledDate: Date) {
        self.id = id
        self.title = title
        self.taskDescription = taskDescription
        self.allocatedSeconds = allocatedSeconds
        self.completedSeconds = completedSeconds
        self.scheduledDate = scheduledDate
    }
}

// Calculated vars
extension TaskEntity {
    var isComplete: Bool {
        completedSeconds >= allocatedSeconds
    }
    var allocatedMinutes: Int { allocatedSeconds / 60 }
    var completedMinutes: Int { completedSeconds / 60 }
    
    var clampedCompletedSeconds: Int {
        min((max(0, completedSeconds)), allocatedSeconds)
    }
}

// Conversion helpers
extension TaskEntity {
    func totalSeconds(including currentSessionSeconds: Int) -> Int {
        completedSeconds + currentSessionSeconds
    }
    
    func totalRemainingSeconds(including currentSessionSeconds: Int) -> Int {
        allocatedSeconds - (completedSeconds + currentSessionSeconds)
    }
}

extension TaskEntity {
    static let preview = TaskEntity(
        id: UUID(),
        title: "Test Task",
        taskDescription: "This is a test task",
        allocatedSeconds: 1800,
        completedSeconds: 0,
        scheduledDate: Date()
    )
}


