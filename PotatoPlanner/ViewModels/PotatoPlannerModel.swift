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
        self.store = store
        self.state = Self.makeInitialState(using: store)
    }
    
    private static func makeInitialState(using store: PlannerStateStorage) -> PlannerState {
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
        
        return loaded
    }
    
    // MARK: Private helpers to save state
    private func persist() {
        store.save(state)
    }
    
    private func update(_ change: (inout PlannerState) -> (Void)) {
        change(&state)
        persist()
    }
}

// MARK: computed properties
extension PotatoPlannerModel {
    var activePotato: Potato? {
        state.potatoes.first {$0.id == state.activePotatoID}
    }
    
    func ownedPotato(for potatoType: PotatoType) -> Potato? {
        state.potatoes.first { $0.typeID == potatoType.id }
    }
    
    func isPotatoEquiped(potato: Potato) -> Bool{
        potato.id == state.activePotatoID
    }
}
    
// MARK: Public mutation funcs
extension PotatoPlannerModel {
    func addTask(title: String, description: String?, allocatedSeconds: Int, scheduledDate: Date) {
        update{state in
            state.appendTask(
                title: title,
                description: description,
                allocatedSeconds: allocatedSeconds,
                scheduledDate: scheduledDate,
            )
        }
    }
    
    func editTask(task: Task, title: String, description: String?, allocatedSeconds: Int, scheduledDate: Date) {
        update{ state in
            state.updateTask(
                id: task.id,
                title: title,
                description: description,
                allocatedSeconds: allocatedSeconds,
                scheduledDate: scheduledDate,
            )
        }
    }
    
    func deleteTask(task: Task) {
        update{state in state.delTask(id: task.id)}
    }
    
}


// MARK: Session funcs
extension PotatoPlannerModel {
    func startSession(task: Task) {
        update{state in state.startSession(for: task.id)}
    }
    
    func finishSession() {
        update{state in state.finishSession()}
    }
}

// MARK: Scheduler funcs
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
    
    func completedDailyFocusTime(on day: Date) -> Int {
        let scheduledTasks = isScheduled(on: day)
        return scheduledTasks.reduce(0) { $0 + $1.completedSeconds }
    }
}


// MARK: potato funcs
extension PotatoPlannerModel {
    
    func equipPotato(potato: Potato) {
        update{state in state.activePotatoID = potato.id}
    }
    
    func buyPotato(of potatoType: PotatoType) {
        update{state in state.buyPotato(of: potatoType)}
    }

}
