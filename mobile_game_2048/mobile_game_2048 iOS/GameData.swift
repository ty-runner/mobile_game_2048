//
//  GameData.swift
//  mobile_game_2048
//
//  Created by Ty Runner on 3/19/25.
//


import Foundation

class GameData {
    static let shared = GameData() // Singleton instance
    
    var coins: Int = 100 // Coin count shared across scenes
    
    private init() {} // Prevents accidental instantiation
}