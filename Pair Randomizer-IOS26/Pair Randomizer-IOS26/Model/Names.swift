//
//  Names.swift
//  Pair Randomizer-IOS26
//
//  Created by winston salcedo on 6/14/19.
//  Copyright © 2019 Evolve Technologies. All rights reserved.
//

import Foundation

class Names: Equatable, Codable {
    
    // MARK: - Properties
    var name: String
    
    // MARK: - Initializer
    init(name: String) {
        self.name = name
    }
    
    // MARK: - Equatable
    static func == (lhs: Names, rhs: Names) -> Bool {
        if lhs.name == rhs.name {
            return true
        } else {
            return false
        }
    }
}
