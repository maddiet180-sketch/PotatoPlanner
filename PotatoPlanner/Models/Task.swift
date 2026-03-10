//
//  Task.swift
//  PotatoPlanner
//
//  Created by Madeline Moody on 3/10/26.
//

import Foundation

struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String?
    var allocatedSeconds: Int
    var completedSeconds: Int
    var scheduledDate: Date
}

// Custom init
extension Task {
    init(
        fromInputTitle rawTitle: String,
        description rawDescription: String?,
        allocatedSeconds: Int,
        id: UUID = UUID(),
        completedSeconds: Int = 0,
        scheduledDate:Date,
    ) {
        let trimmedTitle = rawTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = rawDescription?.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalDescription = (trimmedDescription?.isEmpty == true) ? nil : trimmedDescription

        self.id = id
        self.title = trimmedTitle
        self.description = finalDescription
        self.allocatedSeconds = allocatedSeconds
        self.completedSeconds = completedSeconds
        self.scheduledDate = scheduledDate
    }
}

// Calculated vars
extension Task {
    var isComplete: Bool {
        completedSeconds >= allocatedSeconds
    }
    var allocatedMinutes: Int { allocatedSeconds / 60 }
    var completedMinutes: Int { completedSeconds / 60 }
}

// Conversion helpers
extension Task {
    func totalSeconds(including currentSessionSeconds: Int) -> Int {
        completedSeconds + currentSessionSeconds
    }
    
    func totalRemainingSeconds(including currentSessionSeconds: Int) -> Int {
        allocatedSeconds - (completedSeconds + currentSessionSeconds)
    }
}

// Preview
extension Task {
    static let preview = Task(
        id: UUID(),
        title: "Study Swift",
        description: "Work on lecture",
        allocatedSeconds: 1500,
        completedSeconds: 0,
        scheduledDate: .now
    )
}



