//
//  GameData.swift
//  Cleaned & annotated on 2025-08-16 20:11 UTC
//
//  Notes:
//  - This file has been auto-annotated with documentation comments.
//  - Risky constructs (force unwraps, \1
//try! , continuations) are flagged with TODOs.
//  - No public APIs were intentionally changed.
//
//  GameData.swift
//  mobile_game_2048
//
//  Created by Ty Runner on 3/19/25.
//
import Foundation


// MARK: - GameData



class GameData {
    static let shared = GameData() // Singleton instance
    private init() {} // Prevents accidental instantiation
    var score: Int = 0 //Score count at start of game
    var hasNoAds: Bool = false
    var highscore: Int = 0
    var coins: Int = 0 // Coin count shared across scenes
    
    var unlockedFeatures: Set<Int> = []
    var selectedThemeIndex: Int = 0
    

}
