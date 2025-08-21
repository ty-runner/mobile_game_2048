//
//  GlobalVariables.swift
//  mobile_game_2048
//
//  Created by Cameron McClymont on 3/12/25.
//

import Foundation
import SpriteKit
import AVFoundation
import CoreGraphics
import UIKit   // ⬅️ add this

class GlobalSettings {
    static let shared = GlobalSettings()

    // OLD SpriteKit back button (remove if no longer used)
    // var backButton: SKSpriteNode!

    // ✅ New overlay back button (UIKit) and handler
    private(set) weak var overlayBackButton: UIButton?
    private var overlayBackHandler: (() -> Void)?

    // Keep your existing vars...
    var coinIcon: SKSpriteNode!
    var startbutton1: CGRect = .zero
    var startbutton2: CGRect = .zero
    var storebutton: CGRect = .zero
    var optionsbutton: CGRect = .zero
    var isLightTheme: Bool = false {
        didSet { UserDefaults.standard.set(isLightTheme, forKey: "isLightTheme") }
    }

    var isSoundMuted: Bool = false {
        didSet { transitionAudioPlayer?.volume = isSoundMuted ? 0 : 0.2 }
    }
    var isMusicMuted: Bool = false {
        didSet { backgroundMusicPlayer?.volume = isMusicMuted ? 0 : 0.2 }
    }

    var transitionAudioPlayer: AVAudioPlayer?
    var backgroundMusicPlayer: AVAudioPlayer?

    private init() {}

    // ===== AUDIO (unchanged) =====
    func playTransitionAudio() { /* ... keep if you still use ... */ }
    func stopTransitionAudio() { transitionAudioPlayer?.stop() }
    func stopBackgroundAudio() { backgroundMusicPlayer?.stop() }
    func setupAudio() { /* ... */ }

    // ===== COIN ICON (unchanged) =====
    func setupCoinRegion(for screenSize: CGSize) {
        let buttonWidth: CGFloat = 200
        let buttonHeight: CGFloat = 50
        let iconX = screenSize.width - buttonWidth
        let iconY = screenSize.height - buttonHeight - 10
        coinIcon = SKSpriteNode(imageNamed: "CoinIcon")
        coinIcon.size = CGSize(width: buttonWidth, height: buttonHeight)
        coinIcon.position = CGPoint(x: iconX, y: iconY)
    }

    // ===== NEW: Overlay Back Button (UIKit) =====

    /// Show one shared back button, anchored below the status bar, reusable across scenes.
    /// Call from any scene: GlobalSettings.shared.showOverlayBackButton(in: vc) { ... }
    func showOverlayBackButton(in viewController: UIViewController,
                               title: String = "Back",
                               onTap: @escaping () -> Void) {
        overlayBackHandler = onTap

        guard let skView = viewController.view as? SKView else { return }

        if overlayBackButton == nil {
            let btn = UIButton(type: .system)
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.setTitle(title, for: .normal)
            btn.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 17)
            btn.setTitleColor(.white, for: .normal)
            btn.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            btn.layer.cornerRadius = 10
            btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            btn.addTarget(self, action: #selector(handleOverlayBackTap), for: .touchUpInside)

            skView.addSubview(btn)
            NSLayoutConstraint.activate([
                btn.topAnchor.constraint(equalTo: skView.safeAreaLayoutGuide.topAnchor, constant: 12), // ⬅️ below status bar
                btn.leadingAnchor.constraint(equalTo: skView.leadingAnchor, constant: 16)
            ])
            overlayBackButton = btn
        }

        overlayBackButton?.setTitle(title, for: .normal)
        overlayBackButton?.isHidden = false
        overlayBackButton.map { $0.superview?.bringSubviewToFront($0) }
    }

    @objc private func handleOverlayBackTap() {
        overlayBackHandler?()
    }

    /// Hide the shared back button (e.g., on StartScene)
    func hideOverlayBackButton() {
        overlayBackHandler = nil
        overlayBackButton?.isHidden = true
    }
}
