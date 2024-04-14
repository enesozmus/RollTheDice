//
//  Dice.swift
//  RollTheDice
//
//  Created by enesozmus on 14.04.2024.
//

import Foundation

struct Dice: Identifiable, Codable {
    var id = UUID()
    var type: Int
    var number: Int
    // → An Array[] of type Int
    var rolls = [Int]()
    
    init(type: Int, number: Int) {
        self.type = type
        self.number = number
        
        for _ in 0..<number {
            let roll = Int.random(in: 1...type)
            rolls.append(roll)
        }
    }
}
