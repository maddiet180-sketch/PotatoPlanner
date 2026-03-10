//
//  Planner.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/9/25.
//

import Foundation

struct PlannerState: Codable {
    var tasks: [Task] = []
    var potatoes: [Potato] = []
    var spuds: Int = 0
    var activePotatoID: UUID?
    var activeSession: ActiveSession?
}

// MARK: Session control
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
        guard let activePotatoID,
              let index = potatoes.firstIndex(where: {$0.id == activePotatoID}) else {return}
        
        // Update potato level to reflect fertilizer gained
        guard !potatoes[index].isMaxLevel else {return}
        
        potatoes[index].fertilizer += seconds / secondsPerFertilizer
        
        guard let activePotatoType = PotatoCatalog.kind(for: potatoes[index].typeID) else {return}
        
        while !potatoes[index].isMaxLevel {
            let neededFertilizer = activePotatoType.fertilizerNeeded(for: potatoes[index].level)
            if potatoes[index].fertilizer >= neededFertilizer {
                potatoes[index].level += 1
                potatoes[index].fertilizer -= neededFertilizer
            } else {
                break
            }
        }
    }
}

// MARK: Adding, editing, removing tasks
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

// MARK: buying new potatos
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
