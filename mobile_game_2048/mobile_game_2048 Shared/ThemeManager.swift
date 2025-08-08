import Foundation
import UIKit

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

    static func selectTheme(named name: String) {
        if colorPackages.keys.contains(name) {
            selectedPackage = name
            print("🎨 Theme set to \(name)")
        } else {
            print("⚠️ Invalid theme name: \(name). No changes made.")
        }
    }
}
