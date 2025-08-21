import Foundation
import SpriteKit
import AVFoundation
import UIKit

class OptionsScene: SKScene {

    weak var viewController: GameViewController?

    var OptionScene: SKSpriteNode!

    var soundToggleButton: SKShapeNode!
    var musicToggleButton: SKShapeNode!
    var themeToggleButton: SKShapeNode!
    var activePopupLabel: SKLabelNode?
    var isSoundMuted: Bool = false
    var isMusicMuted: Bool = false
    var isLightTheme: Bool = false

    override func didMove(to view: SKView) {
        // Background
        let backgroundName = GlobalSettings.shared.isLightTheme ? "lightBackground" : "StoreScene"
        OptionScene = SKSpriteNode(imageNamed: backgroundName)
        OptionScene.position = CGPoint(x: size.width / 2, y: size.height / 2)
        OptionScene.size = size
        OptionScene.zPosition = 0
        addChild(OptionScene)

        // 🔙 Global overlay back button (safe-area aware, consistent across scenes)
        if let vc = viewController {
            GlobalSettings.shared.showOverlayBackButton(in: vc, title: "Back") { [weak self] in
                guard let self, let vc = self.viewController else { return }
                let start = StartScene(size: self.size)
                start.viewController = vc
                start.scaleMode = self.scaleMode
                let t = SKTransition.fade(withDuration: 0.5)
                vc.presentScene(start, transition: t, transitionDuration: 0.5)
            }
        }

        // Title
        let titleLabel = SKLabelNode(text: "OPTIONS")
        titleLabel.fontName = "AvenirNext-UltraLight"
        titleLabel.fontSize = 48
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - 150)
        titleLabel.zPosition = 2
        addChild(titleLabel)

        // Coin display
        let coinRegion = CoinRegion(coins: GameData.shared.coins)
        coinRegion.zPosition = 2
        coinRegion.position = CGPoint(x: size.width - 100, y: size.height - 50)
        addChild(coinRegion)

        // Toggle buttons
        let musicColor  = SKColor(red: 0.0,   green: 0.1,  blue: 0.9,  alpha: 0.9)   // blue
        let soundColor  = SKColor(red: 1.0,   green: 0.84, blue: 0.0,  alpha: 0.8)   // yellow
        let themeColor  = SKColor(red: 0.5,   green: 0.0,  blue: 0.5,  alpha: 0.9)   // purple

        musicToggleButton = createToggleButton(
            text: "Toggle Music",
            name: "toggleMusic",
            yPos: size.height * 0.60,
            fillColor: musicColor,
            strokeColor: .white
        )

        soundToggleButton = createToggleButton(
            text: "Toggle Sound FX",
            name: "toggleSound",
            yPos: size.height * 0.48,
            fillColor: soundColor,
            strokeColor: .white
        )

        // If you want theme toggle back, uncomment:
        /*
        themeToggleButton = createToggleButton(

            text: "Toggle Theme",
            name: "toggleTheme",
            yPos: size.height * 0.36,
            fillColor: themeColor,
            strokeColor: .white
        )
        */

        addChild(musicToggleButton)
        addChild(soundToggleButton)

        // Logout button
        let logoutButton = SKLabelNode(text: "Log Out of Game Center")
        logoutButton.name = "logoutGC"
        logoutButton.fontName = "AvenirNext-Bold"
        logoutButton.fontSize = 24
        logoutButton.fontColor = .white
        logoutButton.position = CGPoint(x: size.width / 2, y: size.height * 0.30)
        logoutButton.zPosition = 10
        addChild(logoutButton)

        // Load saved toggle states
        isSoundMuted  = GlobalSettings.shared.isSoundMuted
        isMusicMuted  = GlobalSettings.shared.isMusicMuted
        isLightTheme  = GlobalSettings.shared.isLightTheme
    }

    func showTogglePopup(text: String) {
        activePopupLabel?.removeAllActions()
        activePopupLabel?.removeFromParent()

        let popupLabel = SKLabelNode(text: text)
        popupLabel.fontName = "AvenirNext-Bold"
        popupLabel.fontSize = 22
        popupLabel.fontColor = .white
        popupLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.75)
        popupLabel.zPosition = 100
        popupLabel.alpha = 0
        activePopupLabel = popupLabel
        addChild(popupLabel)

        let fadeIn  = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
        let wait    = SKAction.wait(forDuration: 2.0)
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.3)
        let remove  = SKAction.run { [weak self] in
            popupLabel.removeFromParent()
            if self?.activePopupLabel === popupLabel {
                self?.activePopupLabel = nil
            }
        }
        popupLabel.run(.sequence([fadeIn, wait, fadeOut, remove]))
    }

    func createToggleButton(
        text: String,
        name: String,
        yPos: CGFloat,
        fillColor: SKColor,
        strokeColor: SKColor
    ) -> SKShapeNode {
        let button = SKShapeNode(rectOf: CGSize(width: 250, height: 50), cornerRadius: 12)
        button.fillColor = fillColor
        button.strokeColor = strokeColor
        button.glowWidth = 2         // white glow halo
        button.lineWidth = 2
        button.name = name
        button.position = CGPoint(x: size.width / 2, y: yPos)
        button.zPosition = 2

        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Medium"
        label.fontSize = 22
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.name = name
        button.addChild(label)

        return button
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNode = atPoint(location)

        if let labelNode = tappedNode as? SKLabelNode {
            labelNode.run(.scale(to: 0.9, duration: 0.1))
        }

        switch tappedNode.name {
        case "toggleMusic":
            isMusicMuted.toggle()
            GlobalSettings.shared.isMusicMuted = isMusicMuted
            GlobalSettings.shared.backgroundMusicPlayer?.volume = isMusicMuted ? 0 : 0.5
            showTogglePopup(text: isMusicMuted ? "Music Muted" : "Music Unmuted")

        case "toggleSound":
            isSoundMuted.toggle()
            GlobalSettings.shared.isSoundMuted = isSoundMuted
            if isSoundMuted {
                GlobalSettings.shared.transitionAudioPlayer?.stop()
            }
            showTogglePopup(text: isSoundMuted ? "Sound FX Muted" : "Sound FX Unmuted")

        case "toggleTheme":
            isLightTheme.toggle()
            GlobalSettings.shared.isLightTheme = isLightTheme
            OptionScene.removeFromParent()
            let newBackgroundName = isLightTheme ? "lightBackground" : "StoreScene"
            OptionScene = SKSpriteNode(imageNamed: newBackgroundName)
            OptionScene.position = CGPoint(x: size.width / 2, y: size.height / 2)
            OptionScene.size = size
            OptionScene.zPosition = 0
            addChild(OptionScene)

        case "logoutGC":
            if let vc = self.view?.window?.rootViewController {
                let alert = UIAlertController(
                    title: "Log Out of Game Center",
                    message: "To log out, you'll be taken to iOS Settings.",
                    preferredStyle: .alert
                )
                alert.addAction(.init(title: "Cancel", style: .cancel))
                alert.addAction(.init(title: "Go to Settings", style: .default) { _ in
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                })
                vc.present(alert, animated: true)
            }

        default:
            break
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        for node in nodes(at: location) {
            if let labelNode = node as? SKLabelNode {
                labelNode.run(.scale(to: 1.0, duration: 0.1))
            }
        }
    }
}
