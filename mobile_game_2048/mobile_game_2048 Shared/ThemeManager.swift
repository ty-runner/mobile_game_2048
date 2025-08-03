import Foundation

struct ThemeManager {
    static var selectedPackage: String {
        get {
            return UserDefaults.standard.string(forKey: "selectedColorPackage") ?? "vaporwave"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "selectedColorPackage")
        }
    }
}
