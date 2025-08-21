//
//  ThemeManager.swift
//  Cleaned & annotated on 2025-08-16 20:11 UTC
//
//  Notes:
//  - This file has been auto-annotated with documentation comments.
//  - Risky constructs (force unwraps, \1
//try! , continuations) are flagged with TODOs.
//  - No public APIs were intentionally changed.
//
import Foundation
import UIKit

// MARK: - ThemeManager


struct ThemeManager {
    private static let selectedColorKey = "classic"
    static let defaultColorPackage = "classic"

    static var selectedPackage: String {
        get {
            return UserDefaults.standard.string(forKey: selectedColorKey) ?? defaultColorPackage
        }
        set {
            UserDefaults.standard.set(newValue, forKey: selectedColorKey)
        }
    }
    
    private static let selectedVideoKey = "selectedVideo"
    static var selectedVideo: String {
        get {
            return UserDefaults.standard.string(forKey: selectedVideoKey) ?? "background"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: selectedVideoKey)
        }
    }

    static func selectTheme(named name: String) {
        if colorPackages.keys.contains(name) {
            selectedPackage = name
            // Get the video file name based on the theme name (e.g., using a dictionary)
            let videoMap = ["classic": "Default", "abstract": "Abstract" ,"retro": "8bit", "oceanic": "CoralCove", "vaporwave": "Cyberpunk"]
            if let videoName = videoMap[name] {
                selectedVideo = videoName
            }
            print("🎨 Theme set to \(name), background video set to \(selectedVideo)")
        } else {
            print("⚠️ Invalid theme name: \(name). No changes made.")
        }
    }

}
