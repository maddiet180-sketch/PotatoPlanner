//
//  PlannerStateStorage.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/12/25.
//

import Foundation

final class PlannerStateStorage {
    static let shared = PlannerStateStorage()
    private let fileURL: URL
    
    init(fileName: String = "plannerstate.json") {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = dir.appendingPathComponent(fileName)
    }
    
    func load() -> PlannerState {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(PlannerState.self, from: data)
        } catch {
            return PlannerState()
        }
    }
    
    func save(_ state: PlannerState) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            let data = try encoder.encode(state)
            try data.write(to: fileURL, options: .atomic)
            
        } catch {
            print("Unable to save data")
        }
    }
}
