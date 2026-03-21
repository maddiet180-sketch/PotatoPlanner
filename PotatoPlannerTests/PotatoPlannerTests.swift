//
//  PotatoPlannerTests.swift
//  PotatoPlannerTests
//
//  Created by Maddie Moody on 12/9/25.
//

import Testing
@testable import PotatoPlanner
internal import Foundation

@MainActor
  func makeStoreWithActivePotato() -> PotatoPlannerStore {
      let store = PotatoPlannerStore.preview
      guard let starterType = PotatoCatalog.all.first(where: { $0.cost == 0 }) else { return store }
      store.buyPotato(of: starterType)
      if let potato = store.potatoes.first { store.equipPotato(potato) }
      return store
  }

@Suite struct SessionResultTests {
    var store: PotatoPlannerStore
    
    init() async {
        store = await makeStoreWithActivePotato()
    }
    
    
    @MainActor @Test(arguments: [1, 30, 120, 600, 39600])
    func finishSessionIncrementRewards(_ allocatedTime: Int) throws {
        let spudsBefore = store.spuds
        
        store.addTask(title: "Study", description: nil, allocatedSeconds: allocatedTime, scheduledDate: .now)
        let task = try #require(store.tasks.first)
        
        store.startSession(for: task)
        let result = try #require(store.finishSession(with: allocatedTime))
        
        #expect(result.spudsEarned == Int((Double(allocatedTime) * Configs.spudsPerSec).rounded()))
        #expect(result.fertilizerEarned == Int((Double(allocatedTime) * Configs.fertilizerPerSec).rounded()))
        #expect(store.spuds == spudsBefore + result.spudsEarned)
        #expect(store.activeTaskID == nil)
        #expect(task.completedSeconds == allocatedTime)
    }
    
    @MainActor @Test
    func finishSessionNegativeSecondsReturnsNil() throws {
        store.addTask(title: "Study", description: nil, allocatedSeconds: 60, scheduledDate: .now)
        let task = try #require(store.tasks.first)
        store.startSession(for: task)

        #expect(store.finishSession(with: -1) == nil)
    }

    @MainActor @Test
    func finishSessionZeroSecondsEarnsNothing() throws {
        let spudsBefore = store.spuds
        let fertilizerBefore = store.activePotato?.fertilizer

        store.addTask(title: "Study", description: nil, allocatedSeconds: 60, scheduledDate: .now)
        let task = try #require(store.tasks.first)
        let completedSecondsBefore = task.completedSeconds
        store.startSession(for: task)

        let result = try #require(store.finishSession(with: 0))
        #expect(result.spudsEarned == 0)
        #expect(result.fertilizerEarned == 0)
        #expect(store.spuds == spudsBefore)
        #expect(store.activePotato?.fertilizer == fertilizerBefore)
        #expect(store.activeTaskID == nil)
        #expect(task.completedSeconds == completedSecondsBefore)
    }
}

@Suite struct PotatoSpecificTests {
    var store: PotatoPlannerStore
    
    init() async {
        store = await makeStoreWithActivePotato()
    }
    
    @MainActor @Test
    func sessionCausesSingleLvlUpWithExactFertilizer() throws {
        let potato = try #require(store.activePotato)
        let potatoType = try #require(PotatoCatalog.kind(for: potato.typeID))
        let prevLevel = potato.level
        
        potato.fertilizer = potatoType.fertilizerNeeded(for: potato.level) - 1
        
        store.addTask(title: "Fake Task", description: nil, allocatedSeconds: 10, scheduledDate: .now)
        let task = try #require(store.tasks.first)
        store.startSession(for: task)
        
        let result = try #require(store.finishSession(with: 1))
        #expect(result.levelsGained)
        #expect(potato.level == prevLevel + 1)
    }
    
    @MainActor @Test
    func sessionCausesSingleLvlUpWithExcessFertilizer() throws {
        let potato = try #require(store.activePotato)
        let potatoType = try #require(PotatoCatalog.kind(for: potato.typeID))
        let prevLevel = potato.level
        
        potato.fertilizer = potatoType.fertilizerNeeded(for: potato.level) - 1
        
        store.addTask(title: "Fake Task", description: nil, allocatedSeconds: 10, scheduledDate: .now)
        let task = try #require(store.tasks.first)
        store.startSession(for: task)
        
        let result = try #require(store.finishSession(with: 2))
        #expect(result.levelsGained)
        #expect(potato.level == prevLevel + 1)
    }
    
    @MainActor @Test
    func sessionCausesMultipleLvlUps() throws {
        let potato = try #require(store.activePotato)
        let potatoType = try #require(PotatoCatalog.kind(for: potato.typeID))
        let prevLevel = potato.level
        
        potato.fertilizer = potatoType.fertilizerNeeded(for: potato.level) - 1
        let fertilizerForTwoLevels = potatoType.fertilizerNeeded(for: (potato.level + 1)) + 1
        let secondsNeeded = Int(ceil(Double(fertilizerForTwoLevels) / Configs.fertilizerPerSec))
        
        store.addTask(title: "Task", description: nil, allocatedSeconds: 10, scheduledDate: .now)
        let task = try #require(store.tasks.first)
        store.startSession(for: task)
        
        let result = try #require(store.finishSession(with: secondsNeeded))
        #expect(result.levelsGained)
        #expect(potato.level == prevLevel + 2)
    }
    
    @MainActor @Test
    func maxLvlPotatoNoFertilizerEarned() throws {
        let potato = try #require(store.activePotato)
        let potatoType = try #require(PotatoCatalog.kind(for: potato.typeID))
        
        potato.level = potatoType.maxLevel
        let prevLevel = potato.level
        let prevFertilizer = potato.fertilizer
        
        store.addTask(title: "Task", description: nil, allocatedSeconds: 600, scheduledDate: .now)
        let task = try #require(store.tasks.first)
        store.startSession(for: task)
        
        let result = try #require(store.finishSession(with: 600))
        #expect(result.fertilizerEarned == 0)
        #expect(result.spudsEarned > 0)
        #expect(!result.levelsGained)
        #expect(potato.level == prevLevel)
    }

}

@Suite struct PotatoPurchaseTests {
    var store: PotatoPlannerStore

    init() async {
        store = await makeStoreWithActivePotato()
    }

    @MainActor
    func earnSpuds(_ amount: Int) throws {
        store.addTask(title: "Task", description: nil, allocatedSeconds: amount, scheduledDate: .now)
        let task = try #require(store.tasks.first)
        store.startSession(for: task)
        store.finishSession(with: amount)
        store.tasks.forEach { store.deleteTask($0) }
    }

    @MainActor @Test
    func buyPotatoDeductsSpuds() throws {
        let cephara = try #require(PotatoCatalog.kind(for: "cephara"))
        try earnSpuds(cephara.cost)
        let spudsBefore = store.spuds

        store.buyPotato(of: cephara)

        #expect(store.spuds == spudsBefore - cephara.cost)
    }

    @MainActor @Test
    func buyPotatoAddsToCollection() throws {
        let cephara = try #require(PotatoCatalog.kind(for: "cephara"))
        let countBefore = store.potatoes.count
        try earnSpuds(cephara.cost)

        store.buyPotato(of: cephara)

        #expect(store.potatoes.count == countBefore + 1)
        #expect(store.potatoes.contains { $0.typeID == cephara.id })
    }


    @MainActor @Test
    func buyPotatoWithInsufficientSpuds() throws {
        let cephara = try #require(PotatoCatalog.kind(for: "cephara"))
        #expect(store.spuds < cephara.cost)
        let countBefore = store.potatoes.count

        store.buyPotato(of: cephara)

        #expect(store.potatoes.count == countBefore)
        #expect(store.spuds == 0)
    }

    @MainActor @Test
    func equipPotatoSetsActivePotato() throws {
        let cephara = try #require(PotatoCatalog.kind(for: "cephara"))
        try earnSpuds(cephara.cost)
        store.buyPotato(of: cephara)

        let newPotato = try #require(store.potatoes.first { $0.typeID == cephara.id })
        store.equipPotato(newPotato)

        #expect(store.activePotatoID == newPotato.id)
        #expect(store.isEquipped(newPotato))
    }

    @MainActor @Test
    func equipDifferentPotatoSwitchesActive() throws {
        let originalPotato = try #require(store.activePotato)
        let cephara = try #require(PotatoCatalog.kind(for: "cephara"))
        try earnSpuds(cephara.cost)
        store.buyPotato(of: cephara)

        let newPotato = try #require(store.potatoes.first { $0.typeID == cephara.id })
        store.equipPotato(newPotato)

        #expect(store.isEquipped(newPotato))
        #expect(!store.isEquipped(originalPotato))
    }
}

@Suite struct NullPotatoTests {
    var store: PotatoPlannerStore
    
    init() async {
        store = await PotatoPlannerStore.preview
    }
    
    @MainActor @Test
    func noPotatoNoFertilizerEarned() throws {
        store.addTask(title: "Task", description: nil, allocatedSeconds: 1000, scheduledDate: .now)
        let task = try #require(store.tasks.first)
        
        store.startSession(for: task)
        
        let result = try #require(store.finishSession(with: 1000))
        #expect(result.fertilizerEarned == 0)
        #expect(result.spudsEarned > 0)
        #expect(!result.levelsGained)
    }
}
