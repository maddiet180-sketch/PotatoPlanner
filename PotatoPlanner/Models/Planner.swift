//
//  Planner.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/9/25.
//

import Foundation

// MARK: Task
struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String?
    var allocatedSeconds: Int
    var completedSeconds: Int
    var scheduledDate: Date
}

extension Task {
    var isComplete: Bool {
        completedSeconds >= allocatedSeconds
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

// Conversion
extension Task {
    var allocatedMinutes: Int { allocatedSeconds / 60 }
    var completedMinutes: Int { completedSeconds / 60 }
    
    func totalSeconds(including currentSessionSeconds: Int) -> Int {
        completedSeconds + currentSessionSeconds
    }
    
    func totalRemainingSeconds(including currentSessionSeconds: Int) -> Int {
        allocatedSeconds - (completedSeconds + currentSessionSeconds)
    }
}

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

// MARK: Potato
struct Potato: Identifiable, Codable {
    let id: UUID
    let typeID: String
    let name: String
    var level: Int
    var fertilizer: Int = 0
}

extension Potato {
    static let preview = Potato(
            id: UUID(),
            typeID: "stephania",
            name: "Stephany",
            level: 1,
            fertilizer: 12
    )
}

extension Potato {
    var isMaxLevel: Bool {
        guard let potatoType = PotatoCatalog.kind(for: self.typeID) else { return false }
        
        return potatoType.maxLevel <= self.level
    }
}

// MARK: ActiveSession
struct ActiveSession: Codable{
    let taskID: UUID
    let startedAt: Date
}

// MARK: PlannerState
struct PlannerState: Codable {
    var tasks: [Task] = []
    var potatoes: [Potato] = []
    var spuds: Int = 0
    var activePotatoID: UUID?
    var activeSession: ActiveSession?
}

// Session control
extension PlannerState {
    mutating func startSession(for taskID: UUID, at date: Date = .now) {
        activeSession = ActiveSession(taskID: taskID, startedAt: date)
    }
    
    mutating func finishSession(at date: Date = .now) {
        guard let session = activeSession else { return }
        let elapsedSeconds = Int(date.timeIntervalSince(session.startedAt))
        
        // Update task and active potato
        if let index = tasks.firstIndex(where: { $0.id == session.taskID }) {
            tasks[index].completedSeconds += elapsedSeconds
            updateSpudsAndPotato(add: elapsedSeconds, for: tasks[index])
        }
        
        activeSession = nil
    }
    
    mutating func updateSpudsAndPotato(add seconds: Int, for task: Task) {
        let secondsPerSpud = 1
        let secondsPerFertilizer = 1
        
        // Update spuds
        spuds += seconds / secondsPerSpud
        
        // Update potato specific features (level, fertilizer, etc.)
        guard let activePotatoID = activePotatoID else { return }
        
        if let index = potatoes.firstIndex(where: { $0.id == activePotatoID }) {
            potatoes[index].fertilizer += seconds / secondsPerFertilizer
            
            let activePotatoTypeID = potatoes[index].typeID
            if let activePotatoType = PotatoCatalog.kind(for: activePotatoTypeID) {
                let fertilizerNeeded = activePotatoType.fertilizerNeeded(for: potatoes[index].level)
                
                if potatoes[index].fertilizer >= fertilizerNeeded {
                    if !potatoes[index].isMaxLevel { // Don't add fertilizer if maxed
                        potatoes[index].level += 1
                        potatoes[index].fertilizer = abs(fertilizerNeeded - potatoes[index].fertilizer)
                    }
                }
            }
        }
    }
}

// Adding, editing, removing tasks
extension PlannerState {
    mutating func appendTask(
        title: String,
        description: String?,
        allocatedSeconds: Int,
        scheduledDate: Date,
    ) {
        let newTask = Task(
            fromInputTitle: title,
            description: description,
            allocatedSeconds: allocatedSeconds,
            scheduledDate: scheduledDate
        )
        tasks.append(newTask)
    }

    mutating func updateTask(
        id taskID: UUID,
        title: String,
        description: String?,
        allocatedSeconds: Int,
        scheduledDate: Date,
    ) {
        guard let index = tasks.firstIndex(where: { $0.id == taskID }) else {
            return
        }

        let updated = Task(
            fromInputTitle: title,
            description: description,
            allocatedSeconds: allocatedSeconds,
            id: tasks[index].id,
            completedSeconds: tasks[index].completedSeconds,
            scheduledDate: scheduledDate
        )

        tasks[index] = updated
    }
    
    mutating func delTask(id taskID: UUID) {
        if activeSession?.taskID == taskID {
            activeSession = nil
        }
        tasks.removeAll { $0.id == taskID }
    }
}

// buying new potatos
extension PlannerState {
    mutating func buyPotato(of type: PotatoType) {
        // create and save new potato
        let newPotato = Potato (
            id: UUID(),
            typeID: type.id,
            name: type.displayName,
            level: 1,
            fertilizer: 0,
        )
        
        potatoes.append(newPotato)
        
        // reduce spud count
        spuds -= type.cost
    }
}

extension Int { 
    private var hms: (h: Int, m: Int, s: Int) {
        guard self >= 0 else { return (0, 0, 0)}
        let h = self / 3600
        let m = ( self % 3600) / 60
        let s = self % 60
        return (h, m, s)
    }

    // "MM:SS" or "HH:MM:SS" (only shows hours if > 0)
    var asHHMMSS: String {
        let (h, m, s) = hms
        if h > 0 {
            return String(format: "%02d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%02d:%02d", m, s)
        }
    }

    // "1h 5m", "2h", "12m", or "—"
    var asHMS: String {
        guard self >= 60 else { return "—" }
        return Self.hmFormatter.string(from: Double(self)) ?? "—"
    }

    var asHours: Int { hms.h }
    var asRemainingMinutes: Int { hms.m }
    
    private static let hmFormatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.hour, .minute]
        f.unitsStyle = .abbreviated
        f.zeroFormattingBehavior = [.dropAll] // avoids 0h
        return f
    }()
}

extension Date {
    func ttyOrMediumDate(calendar: Calendar = .current) -> String {
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else if calendar.isDateInTomorrow(self) {
            return "Tomorrow"
        } else {
            return Date.mediumFormatter.string(from: self)
        }
    }

    var mediumDate: String {
        Date.mediumFormatter.string(from: self)
    }
    
    private static let mediumFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
