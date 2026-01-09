//
//  PotatoPlannerModel.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/9/25.
//

import SwiftUI
internal import Combine

final class PotatoPlannerModel: ObservableObject {
    @Published private(set) var state: PlannerState
    private let store: PlannerStateStorage
    
    init (store: PlannerStateStorage = .shared) {
//        // Uncomment below to reset storage
//        try? FileManager.default.removeItem(
//                    at: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//                        .appendingPathComponent("plannerstate.json")
//                )
        
        self.store = store
        
        var loaded = store.load()
        
        if loaded.potatoes.isEmpty {
            let starterKind = PotatoCatalog.starterKind
            let starterPotato = Potato (
                id: UUID(),
                typeID: starterKind.id,
                name: starterKind.displayName,
                level: 7,
                fertilizer: 0,
            )
            
            loaded.potatoes = [starterPotato]
            loaded.activePotatoID = starterPotato.id
        }
        
        self.state = loaded
    }
    
    // MARK: Private helper to save state
    private func persist() {
        store.save(state)
    }
    
    var activePotato: Potato? {
        state.potatoes.first {$0.id == state.activePotatoID}
    }
    
    func ownedPotato(for potatoType: PotatoType) -> Potato? {
        state.potatoes.first { $0.typeID == potatoType.id }
    }
    
    // MARK: Public mutation funcs
    func addTask(title: String, description: String?, allocatedSeconds: Int, scheduledDate: Date) {
        state.appendTask(
            title: title,
            description: description,
            allocatedSeconds: allocatedSeconds,
            scheduledDate: scheduledDate,
        )
        persist()
    }
    
    func editTask(task: Task, title: String, description: String?, allocatedSeconds: Int, scheduledDate: Date) {
        state.updateTask(
            id: task.id,
            title: title,
            description: description,
            allocatedSeconds: allocatedSeconds,
            scheduledDate: scheduledDate,
        )
        persist()
    }
    
    func deleteTask(task: Task) {
        state.delTask(id: task.id)
        persist()
    }
    
    func startSession(task: Task) {
        state.startSession(for: task.id)
        persist()
    }
    
    func finishSession() {
        state.finishSession()
        persist()
    }
}

extension PotatoPlannerModel {
    func isScheduled(on day: Date, calendar: Calendar = .current) -> [Task] {
        state.tasks.filter { task in
            calendar.isDate(task.scheduledDate, inSameDayAs: day)
        }
    }
    
    func totalDailyFocusTime(on day: Date) -> Int {
        let scheduledTasks = isScheduled(on: day)
        return scheduledTasks.reduce(0) { $0 + $1.allocatedSeconds }
    }
}

extension PotatoPlannerModel {
    func isPotatoEquiped(potato: Potato) -> Bool{
        potato.id == state.activePotatoID
    }
    
    func equipPotato(potato: Potato) {
        state.activePotatoID = potato.id
        persist()
    }
}

extension PotatoPlannerModel {
    func buyPotato(of potatoType: PotatoType) {
        state.buyPotato(of: potatoType)
        persist()
    }
}
