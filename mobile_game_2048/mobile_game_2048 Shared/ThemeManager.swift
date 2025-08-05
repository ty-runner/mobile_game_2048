import Foundation

struct ThemeManager {
    static var selectedPackage: String {
        get {
            return UserDefaults.standard.string(forKey: "selectedColorPackage") ?? "classic"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "selectedColorPackage")
        }
    }
    static func setTheme(to name: String) {
        if colorPackages.keys.contains(name) {
            selectedPackage = name
        } else {
            print("⚠️ Theme '\(name)' not found. Falling back to classic.")
            selectedPackage = "classic"
        }
    }
}
