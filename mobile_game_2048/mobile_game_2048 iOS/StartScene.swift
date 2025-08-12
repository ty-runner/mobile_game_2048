//
//  StartScreen.swift
//  mobile_game_2048
//
//  Created by Cameron McClymont on 3/12/25.
//

import Foundation
import SpriteKit
import AVFoundation
var transitionAudioPlayer: AVAudioPlayer?

class StartScene: SKScene {
    
    weak var viewController: GameViewController?
    
    let homescreen = SKSpriteNode(imageNamed: "StoreScene")
    
    func addDebugBoundingBox(rect: CGRect, color: SKColor, to parent: SKNode) {
        let path = CGPath(rect: rect, transform: nil)
        let box = SKShapeNode(path: path)
        box.strokeColor = color
        box.lineWidth = 2.0
        box.zPosition = 1
        box.fillColor = .clear
        parent.addChild(box)
    }
    
    override func didMove(to view: SKView) {
        GlobalSettings.shared.stopBackgroundAudio()
        
        // Background
        homescreen.position = CGPoint(x: size.width / 2, y: size.height / 2)
        homescreen.size = CGSize(width: size.width, height: size.height)
        homescreen.zPosition = 0
        addChild(homescreen)
        
        // Coin region
        GlobalSettings.shared.setupBackButton(for: size)
        GlobalSettings.shared.setupCoinRegion(for: size)
        let coinRegion = CoinRegion(coins: GameData.shared.coins)
        coinRegion.position = CGPoint(x: size.width * 0.25, y: size.height * 0.9)
        addChild(coinRegion)
        
        // Button layout
        let buttonWidth: CGFloat = size.width / 3
        let buttonHeight: CGFloat = size.height / 15
        let buttonSpacing: CGFloat = size.height * 0.035 // proportional spacing
        
        let totalHeight = (buttonHeight * 3) + (buttonSpacing * 2)
        var currentY = (size.height / 2) + (totalHeight / 2) - buttonHeight
        
        // START button
        GlobalSettings.shared.startbutton1 = CGRect(
            x: (size.width - buttonWidth) / 2,
            y: currentY,
            width: buttonWidth,
            height: buttonHeight
        )
        currentY -= (buttonHeight + buttonSpacing)
        
        // STORE button
        GlobalSettings.shared.storebutton = CGRect(
            x: (size.width - buttonWidth) / 2,
            y: currentY,
            width: buttonWidth,
            height: buttonHeight
        )
        currentY -= (buttonHeight + buttonSpacing)
        
        // OPTIONS button
        GlobalSettings.shared.optionsbutton = CGRect(
            x: (size.width - buttonWidth) / 2,
            y: currentY,
            width: buttonWidth,
            height: buttonHeight
        )
        
        // Title image
        let titleImage = SKSpriteNode(imageNamed: "TitleIcon") // Replace with your asset name
        titleImage.setScale(0.15) // Adjust size to fit (or set width/height directly)
        titleImage.position = CGPoint(x: size.width / 2, y: size.height * 0.75)
        titleImage.zPosition = 6
        addChild(titleImage)

       
        // Create and add buttons
        let startColor = SKColor(red: 0.0, green: 0.1, blue: 0.9, alpha: 0.9) // blue
        let storeColor = SKColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 0.8) // yellow
        let optionsColor = SKColor(red: 0.5, green: 0.0, blue: 0.5, alpha: 0.9) // purple
        
        addChild(createButton(rect: GlobalSettings.shared.startbutton1, backgroundColor: startColor, labelText: "START", labelColor: .white))
        addChild(createButton(rect: GlobalSettings.shared.storebutton, backgroundColor: storeColor, labelText: "STORE", labelColor: .white))
        addChild(createButton(rect: GlobalSettings.shared.optionsbutton, backgroundColor: optionsColor, labelText: "OPTIONS", labelColor: .white))
    }
    
    func createButton(rect: CGRect, backgroundColor: SKColor, labelText: String, labelColor: SKColor) -> SKNode {
        let buttonNode = SKNode()
        buttonNode.position = CGPoint(x: rect.origin.x, y: rect.origin.y)
        
        // Base background
        let background = SKShapeNode(rect: CGRect(origin: .zero, size: rect.size), cornerRadius: 12)
        background.fillColor = backgroundColor
        background.lineWidth = 2
        background.glowWidth = 3
        background.zPosition = 1
        buttonNode.addChild(background)
        
        // Pulse for START
        if labelText == "START" {
            let glow = SKShapeNode(rect: CGRect(origin: .zero, size: rect.size), cornerRadius: 12)
            glow.fillColor = backgroundColor
            glow.strokeColor = backgroundColor
            glow.alpha = 0.6
            glow.zPosition = 0
            glow.glowWidth = 15
            buttonNode.addChild(glow)
            
            let grow = SKAction.scale(to: 1.05, duration: 0.6)
            let fade = SKAction.fadeAlpha(to: 0.95, duration: 0.6)
            let shrink = SKAction.scale(to: 1.0, duration: 0.6)
            let fadeOut = SKAction.fadeAlpha(to: 0.6, duration: 0.6)
            let pulse = SKAction.sequence([
                SKAction.group([grow, fade]),
                SKAction.group([shrink, fadeOut])
            ])
            glow.run(SKAction.repeatForever(pulse))
        }
        
        // Label
        let label = SKLabelNode(text: labelText)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 22
        label.fontColor = labelColor
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: rect.size.width / 2, y: rect.size.height / 2)
        label.zPosition = 2
        
        let maxLabelWidth = rect.size.width - 10
        while label.frame.width > maxLabelWidth && label.fontSize > 10 {
            label.fontSize -= 1
        }
        
        buttonNode.addChild(label)
        
        return buttonNode
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        let startbutton1 = GlobalSettings.shared.startbutton1
        if startbutton1.contains(location) {
            self.viewController?.showInterstitialAdIfAvailable()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                GlobalSettings.shared.playTransitionAudio()
                let gameScene = GameScene(size: self.size)
                gameScene.viewController = self.viewController
                gameScene.scaleMode = self.scaleMode
                self.view?.presentScene(gameScene, transition: .fade(withDuration: 1.0))
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    GlobalSettings.shared.stopTransitionAudio()
                }
            }
        }
        
        let storebutton = GlobalSettings.shared.storebutton
        if storebutton.contains(location) {
            self.viewController?.showInterstitialAdIfAvailable()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                GlobalSettings.shared.playTransitionAudio()
                let storeScene = StoreScene(size: self.size)
                storeScene.viewController = self.viewController
                storeScene.scaleMode = self.scaleMode
                self.view?.presentScene(storeScene, transition: .fade(withDuration: 1.0))
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    GlobalSettings.shared.stopTransitionAudio()
                }
            }
        }
        
        let optionsbutton = GlobalSettings.shared.optionsbutton
        if optionsbutton.contains(location) {
            self.viewController?.showInterstitialAdIfAvailable()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                GlobalSettings.shared.playTransitionAudio()
                let optionScene = OptionsScene(size: self.size)
                optionScene.viewController = self.viewController
                optionScene.scaleMode = self.scaleMode
                self.view?.presentScene(optionScene, transition: .fade(withDuration: 1.0))
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    GlobalSettings.shared.stopTransitionAudio()
                }
            }
        }
    }
}

