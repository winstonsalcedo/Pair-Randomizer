//
//  NamesController.swift
//  Pair Randomizer-IOS26
//
//  Created by winston salcedo on 6/14/19.
//  Copyright © 2019 Evolve Technologies. All rights reserved.
//

import Foundation

class NamesController {
    
    // MARK: - Singleton
    static let shared = NamesController()
    
    // MARK: - Properties
    var names: [Names] = []
    var groupedNames: [[Names]] = []
    
    // MARK: - Initializer
    private init () {
        self.names = loadFromPersistenceStore()
        groupedNames = groupNames(names: names)
    }
    
    // MARK: - Refreshing data when needed
    func updateData () {
        self.names = loadFromPersistenceStore()
        groupedNames = groupNames(names: names)
    }
    
    // MARK: - Grouping function using extension to Array data type
    func groupNames (names: [Names]) -> [[Names]] {
        return names.PairedNames(into: 2)
    }
    
    // MARK: - Ungroup names to sort and delete
    func ungroupNames (groupedNames: [[Names]]) -> [Names] {
        return groupedNames.flatMap { $0 }
    }
    
    // MARK: - This shuffles the names using my interpretation of the Fisher-Yates shuffle
    func shuffleNames (names: [Names]) -> [Names] {
        var names = names
        var shuffled = [Names]()
        for _ in 0..<names.count {
            let rand = Int(arc4random_uniform(UInt32(names.count)))
            shuffled.append(names[rand])
            names.remove(at: rand)
        }
        return shuffled
    }
    
    // MARK: - CRUD (Actullay just C and R)
    // Adds name to names array
    func addName (name: String) {
        let newName = Names(name: name)
        names.append(newName)
        groupedNames = groupNames(names: names)
        self.saveToPersistentStore()
    }
    
    // ungroups names and removes name based on section and row
    func removeName (groupNames: [[Names]], section: Int, row: Int) {
        names = ungroupNames(groupedNames: groupNames)
        if section == 0 {
            names.remove(at: section + row)
        } else {
            names.remove(at: section + row + 1)
        }
        self.saveToPersistentStore()
        updateData()
    }
    
    // MARK: - Persistence
    func fileURL() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let fileName = "names.json"
        let fullURL = documentsDirectory.appendingPathComponent(fileName)
        
        print(fullURL)
        
        return(fullURL)
    }
    
    func saveToPersistentStore() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self.names)
            try data.write(to: fileURL())
        } catch {
            print("Error: \(#function): \(error) : \(error.localizedDescription)")
        }
    }
    
    func loadFromPersistenceStore() -> [Names] {
        do {
            let data = try Data(contentsOf: fileURL())
            let decoder = JSONDecoder()
            let names = try decoder.decode([Names].self, from: data)
            return names
        } catch  {
            print("Error: \(#function): \(error) : \(error.localizedDescription)")
        }
        
        return []
    }
}

// MARK: - Extension to split the names array into whatever size is needed.
extension Array {
    func PairedNames (into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map { Array(self[$0 ..< Swift.min($0 + size, count)]) }
    }
}
