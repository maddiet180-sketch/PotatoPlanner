//
//  PotatoPlannerStore.swift
//  PotatoPlanner
//
//  Created by Madeline Moody on 3/10/26.
//

import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class PotatoPlannerStore {

    // MARK: - Private storage

    // The container is retained here so it is never deallocated for the
    // lifetime of this store. This prevents ModelContext.reset crashes.
    @ObservationIgnored private let container: ModelContainer
    @ObservationIgnored private var modelContext: ModelContext { container.mainContext }
    @ObservationIgnored private var appStateEntity: AppStateEntity?

    // MARK: - Observable state

    /// All tasks, sorted by scheduled date.
    private(set) var tasks: [TaskEntity] = []

    /// All owned potatoes.
    private(set) var potatoes: [PotatoEntity] = []

    /// Current spud balance.
    private(set) var spuds: Int = 0

    /// ID of the currently equipped potato.
    private(set) var activePotatoID: UUID? = nil

    /// The task currently being focused on, if any.
    private(set) var activeTaskID: UUID? = nil

    // MARK: - Init

    init(container: ModelContainer) {
        self.container = container
        loadFromStore()
        ensureInitialState()
    }

    static func makeContainer() -> ModelContainer {
        let schema = Schema([TaskEntity.self, PotatoEntity.self, AppStateEntity.self])
        return try! ModelContainer(for: schema)
    }

    // MARK: - Load & Persist

    private func loadFromStore() {
        let taskDescriptor = FetchDescriptor<TaskEntity>(
            sortBy: [SortDescriptor(\.scheduledDate)]
        )
        tasks = (try? modelContext.fetch(taskDescriptor)) ?? []
        potatoes = (try? modelContext.fetch(FetchDescriptor<PotatoEntity>())) ?? []

        let existingStates = (try? modelContext.fetch(FetchDescriptor<AppStateEntity>())) ?? []
        if let state = existingStates.first {
            appStateEntity = state
            spuds = state.spuds
            activePotatoID = state.activePotatoID
            activeTaskID = state.activeSessionTaskID
        } else {
            let state = AppStateEntity()
            modelContext.insert(state)
            appStateEntity = state
            // Defer save — ensureInitialState() will save after full setup.
        }
    }

    /// Syncs in-memory scalar state back to `AppStateEntity` and saves.
    /// Call after any mutation.
    private func save() {
        appStateEntity?.spuds = spuds
        appStateEntity?.activePotatoID = activePotatoID
        appStateEntity?.activeSessionTaskID = activeTaskID
        try? modelContext.save()
    }

    /// Re-fetches arrays from the store
    private func refetchArrays() {
        let taskDescriptor = FetchDescriptor<TaskEntity>(
            sortBy: [SortDescriptor(\.scheduledDate)]
        )
        tasks = (try? modelContext.fetch(taskDescriptor)) ?? []
        potatoes = (try? modelContext.fetch(FetchDescriptor<PotatoEntity>())) ?? []
    }

    private func ensureInitialState() {
        guard potatoes.isEmpty else { return }
        let starterKind = PotatoCatalog.starterKind
        let starter = PotatoEntity(
            typeID: starterKind.id,
            name: starterKind.displayName,
            level: 1
        )
        modelContext.insert(starter)
        activePotatoID = starter.id
        save()
        refetchArrays()
    }
}

// MARK: - Computed helpers

extension PotatoPlannerStore {

    var activePotato: PotatoEntity? {
        potatoes.first { $0.id == activePotatoID }
    }

    func ownedPotato(for potatoType: PotatoType) -> PotatoEntity? {
        potatoes.first { $0.typeID == potatoType.id }
    }

    func isEquipped(_ potato: PotatoEntity) -> Bool {
        potato.id == activePotatoID
    }

    func tasks(on day: Date, calendar: Calendar = .current) -> [TaskEntity] {
        tasks.filter { calendar.isDate($0.scheduledDate, inSameDayAs: day) }
    }

    func totalFocusTime(on day: Date) -> Int {
        tasks(on: day).reduce(0) { $0 + $1.allocatedSeconds }
    }

    func completedFocusTime(on day: Date) -> Int {
        tasks(on: day).reduce(0) { $0 + $1.completedSeconds }
    }
}

// MARK: - Task CRUD

extension PotatoPlannerStore {

    func addTask(
        title: String,
        description: String?,
        allocatedSeconds: Int,
        scheduledDate: Date
    ) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDesc = description?.trimmingCharacters(in: .whitespacesAndNewlines)
        let task = TaskEntity(
            id: UUID(),
            title: trimmedTitle,
            taskDescription: (trimmedDesc?.isEmpty == true) ? nil : trimmedDesc,
            allocatedSeconds: allocatedSeconds,
            completedSeconds: 0,
            scheduledDate: scheduledDate
        )
        modelContext.insert(task)
        save()
        refetchArrays()
    }

    func updateTask(
        _ task: TaskEntity,
        title: String,
        description: String?,
        allocatedSeconds: Int,
        scheduledDate: Date
    ) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDesc = description?.trimmingCharacters(in: .whitespacesAndNewlines)
        task.title = trimmedTitle
        task.taskDescription = (trimmedDesc?.isEmpty == true) ? nil : trimmedDesc
        task.allocatedSeconds = allocatedSeconds
        task.scheduledDate = scheduledDate
        save()
    }
    
    func finishTaskEarly(_ task: TaskEntity) {
        if activeTaskID == task.id {
            activeTaskID = nil
        }
        task.allocatedSeconds = task.completedSeconds
        save()
    }

    func deleteTask(_ task: TaskEntity) {
        if activeTaskID == task.id {
            activeTaskID = nil
        }
        modelContext.delete(task)
        save()
        refetchArrays()
    }
}

// MARK: - Session Control

extension PotatoPlannerStore {

    func startSession(for task: TaskEntity) {
        activeTaskID = task.id
        save()
    }

    @discardableResult
    func finishSession(with elapsedSeconds: Int) -> SessionResult? {
        guard activeTaskID != nil else { return nil }
        
        guard let task = tasks.first(where: { $0.id == activeTaskID }) else { return nil }
        task.completedSeconds += elapsedSeconds
        
        let result = applySpudsAndFertilizer(for: elapsedSeconds)
        activeTaskID = nil
        save()
        return result
    }

    @discardableResult
    private func applySpudsAndFertilizer(for seconds: Int) -> SessionResult {
        spuds += seconds

        guard let activePotatoID,
              let potato = potatoes.first(where: { $0.id == activePotatoID }),
              !potato.isMaxLevel,
              let potatoType = PotatoCatalog.kind(for: potato.typeID) else {
            return SessionResult(spudsEarned: seconds, fertilizerEarned: 0, levelsGained: false)
        }

        potato.fertilizer += seconds
        let levelBefore = potato.level

        while !potato.isMaxLevel {
            let needed = potatoType.fertilizerNeeded(for: potato.level)
            if potato.fertilizer >= needed {
                potato.level += 1
                potato.fertilizer -= needed
            } else {
                break
            }
        }

        return SessionResult(
            spudsEarned: seconds,
            fertilizerEarned: seconds,
            levelsGained: true ? (potato.level - levelBefore) > 0 : false
        )
    }
}

// MARK: - Potatoes

extension PotatoPlannerStore {

    func equipPotato(_ potato: PotatoEntity) {
        activePotatoID = potato.id
        save()
    }

    func buyPotato(of type: PotatoType) {
        guard spuds >= type.cost else { return }
        let potato = PotatoEntity(typeID: type.id, name: type.displayName)
        modelContext.insert(potato)
        spuds -= type.cost
        save()
        refetchArrays()
    }
}

// MARK: - Preview

extension PotatoPlannerStore {
    /// In-memory store for SwiftUI previews.
    /// The container is retained by the store itself, preventing deallocation.
    static let preview: PotatoPlannerStore = {
        let schema = Schema([TaskEntity.self, PotatoEntity.self, AppStateEntity.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: config)
        return PotatoPlannerStore(container: container)
    }()
}
