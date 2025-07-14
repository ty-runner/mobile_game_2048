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

class StartScene: SKScene{
    
    weak var viewController: GameViewController?  // Add this property
    
    let homescreen = SKSpriteNode(imageNamed: "StoreScene")
    //let videoNode = SKVideoNode(fileNamed: "StartSceneVideo.mp4")
    

    func addDebugBoundingBox(rect: CGRect, color: SKColor, to parent: SKNode) {
        let path = CGPath(rect: rect, transform: nil)
        let box = SKShapeNode(path: path)
        box.strokeColor = color
        box.lineWidth = 2.0
        box.zPosition = 1 // Make sure it's on top of other nodes
        box.fillColor = .clear
        parent.addChild(box)
    }

    override func didMove(to view: SKView){
        GlobalSettings.shared.stopBackgroundAudio()
        homescreen.position = CGPoint(x: size.width/2, y: size.height/2) //was self.size.width, self.size.height
        
        
        /*
        homescreen.position = CGPoint(x: size.width / 2, y: size.height / 2)
            
            let imageAspect = homescreen.texture!.size().width / homescreen.texture!.size().height
            let screenAspect = size.width / size.height
            
            if imageAspect > screenAspect {
                // Image is wider than screen: fit by height
                let scale = size.height / homescreen.texture!.size().height
                homescreen.size = CGSize(width: homescreen.texture!.size().width * scale,
                                         height: size.height)
            } else {
                // Image is taller than screen: fit by width
                let scale = size.width / homescreen.texture!.size().width
                homescreen.size = CGSize(width: size.width,
                                         height: homescreen.texture!.size().height * scale)
            }
            
            homescreen.zPosition = 0
            addChild(homescreen)
        */
        homescreen.position = CGPoint(x: size.width/2, y: size.height/2)
        homescreen.size = CGSize(width: size.width, height: size.height)
        homescreen.zPosition = 0
        addChild(homescreen)
        
        /*
        videoNode.position = CGPoint(x: size.width/2, y: size.height/2)
        videoNode.size = CGSize(width: size.width, height: size.height)
        videoNode.zPosition = 1
        addChild(videoNode)
         
        
        videoNode.play()
        */
        
        //let coin_iconX = (size.width)
        //coin_icon.position = CGPoint(x:
        
        GlobalSettings.shared.setupBackButton(for: size) //Initializing backbutton on screen load to be used globally
        GlobalSettings.shared.setupCoinRegion(for: size) //Initializing coin region on screen load to be used globally
        let coinRegion = CoinRegion(coins: GameData.shared.coins)
        coinRegion.position = CGPoint(x: 100, y: size.height - 50)
        addChild(coinRegion)
        let buttonWidth: CGFloat = size.width / 6
        let buttonHeight: CGFloat = size.height / 15

        // Define two start buttons using CGRect, placed left and right
        let startButton1X = size.width * 0.2
        let startButton1Y = size.height * 0.30
        GlobalSettings.shared.startbutton1 = CGRect(x: startButton1X, y: startButton1Y, width: buttonWidth, height: buttonHeight)

        let startButton2X = size.width * 0.155
        let startButton2Y = size.height * 0.6
        GlobalSettings.shared.startbutton2 = CGRect(x: startButton2X, y: startButton2Y, width: buttonWidth * 4, height: buttonHeight)

        // Store button in the middle
        let storeButtonX = (size.width - buttonWidth) / 2.05
        let storeButtonY = size.height * 0.30
        GlobalSettings.shared.storebutton = CGRect(x: storeButtonX, y: storeButtonY, width: buttonWidth, height: buttonHeight)

        // Options button more to the right
        let optionsButtonX = (size.width - buttonWidth) / 1.35
        let optionsButtonY = size.height * 0.30
        GlobalSettings.shared.optionsbutton = CGRect(x: optionsButtonX, y: optionsButtonY, width: buttonWidth, height: buttonHeight)
        // Add visible buttons
        // BLOCK CASCADE Title Box
        let titleRect = GlobalSettings.shared.startbutton2

        let optionsColor = SKColor(red: 0.5, green: 0.0, blue: 0.5, alpha: 0.9) //purple
        let startColor = SKColor(red: 0.0, green: 0.1, blue: 0.9, alpha: 0.9) //blue
        let storeColor = SKColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 0.8) //yellow
        let titleColor = SKColor(red: 0.9, green: 0.3, blue: 0.1, alpha: 1.0) //orange
        
        let titleBackground = SKShapeNode(rect: titleRect, cornerRadius: 12)
        titleBackground.fillColor = titleColor
        titleBackground.strokeColor = .white
        titleBackground.lineWidth = 2
        titleBackground.zPosition = 5
        addChild(titleBackground)

        let titleLabel = SKLabelNode(text: "BLOCK CASCADE")
        titleLabel.fontName = "DINCondensed-Bold"
        titleLabel.fontSize = 40
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: titleRect.midX, y: titleRect.midY - 15)
        titleLabel.zPosition = 6
        addChild(titleLabel)
        

        // START (Blue background)
        let startButtonNode = createButton(
            rect: GlobalSettings.shared.startbutton1,
            backgroundColor: startColor,
            labelText: "START",
            labelColor: .white
        )
        addChild(startButtonNode)

        // STORE (Yellow background)
        let storeButtonNode = createButton(
            rect: GlobalSettings.shared.storebutton,
            backgroundColor: storeColor,
            labelText: "STORE",
            labelColor: .white
        )
        addChild(storeButtonNode)

        // OPTIONS (Purple background)
        let optionsButtonNode = createButton(
            rect: GlobalSettings.shared.optionsbutton,
            backgroundColor: optionsColor,
            labelText: "OPTIONS",
            labelColor: .white
        )
        addChild(optionsButtonNode)

        // Add visible debug boxes for layout verification
        /*addDebugBoundingBox(rect: GlobalSettings.shared.startbutton1, color: .red, to: self)
        addDebugBoundingBox(rect: GlobalSettings.shared.startbutton2, color: .orange, to: self)

        addDebugBoundingBox(rect: GlobalSettings.shared.storebutton, color: .green, to: self)
        addDebugBoundingBox(rect: GlobalSettings.shared.optionsbutton, color: .blue, to: self)*/


        //addChild(GlobalSettings.shared.backButton)
        
    }

    func createButton(rect: CGRect, backgroundColor: SKColor, labelText: String, labelColor: SKColor) -> SKNode {
        let buttonNode = SKNode()
        buttonNode.position = CGPoint(x: rect.origin.x, y: rect.origin.y)

        // Base button background
        let background = SKShapeNode(rect: CGRect(origin: .zero, size: rect.size), cornerRadius: 12)
        background.fillColor = backgroundColor
        background.lineWidth = 2
        background.glowWidth = 3
        background.zPosition = 1
        buttonNode.addChild(background)

        // OPTIONAL: Glowing layer behind for pulse effect
        if labelText == "START" {
            let glow = SKShapeNode(rect: CGRect(origin: .zero, size: rect.size), cornerRadius: 12)
            glow.fillColor = backgroundColor
            glow.strokeColor = backgroundColor
            glow.alpha = 0.6
            glow.setScale(1.0)
            glow.zPosition = 1  // Behind the main button
            glow.glowWidth = 15
            buttonNode.addChild(glow)

            let grow = SKAction.scale(to: 1.05, duration: 0.6)
            let fade = SKAction.fadeAlpha(to: 0.95, duration: 0.6)
            let shrink = SKAction.scale(to: 1.0, duration: 0.6)
            let fadeOut = SKAction.fadeAlpha(to: 0.6, duration: 0.6)
            let pulse = SKAction.sequence([SKAction.group([grow, fade]),
                                           SKAction.group([shrink, fadeOut])])
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
        
        let startbutton1 = mobile_game_2048.GlobalSettings.shared.startbutton1
        let startbutton2 = mobile_game_2048.GlobalSettings.shared.startbutton2
        if startbutton1.contains(location) || startbutton2.contains(location){
            print("Start button Clicked - Transitioning to GameScene")
            
            print("Attempting to show interstitial. ViewController is: \(String(describing: viewController) )")
            
            //shows ad first GET RID OF IF NO WANT ADS DURING TESTING
            self.viewController?.showInterstitialAdIfAvailable()
            
            //Delay for transitions and sound
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                GlobalSettings.shared.playTransitionAudio() // Play transition sound
                let gameScene = GameScene(size: self.size)
                gameScene.viewController = self.viewController
                gameScene.scaleMode = self.scaleMode
                
                let transition = SKTransition.fade(withDuration: 1.0)
                self.view?.presentScene(gameScene, transition: transition)
                
                // Ensure the audio stops when the transition is done
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    GlobalSettings.shared.stopTransitionAudio() // Stop transition audio after 1 second
                }
            }
            
        }
        
        let storebutton = mobile_game_2048.GlobalSettings.shared.storebutton
        if storebutton.contains(location) {
            self.viewController?.showInterstitialAdIfAvailable()
        
            //Delay for transitions and sound
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                GlobalSettings.shared.playTransitionAudio() // Play transition sound
                
                let storeScene = StoreScene(size: self.size)
                storeScene.viewController = self.viewController //ANY SCENE TRANSITION NECESSARY FOR ADS
                storeScene.scaleMode = self.scaleMode
                
                let transition = SKTransition.fade(withDuration: 1.0)
                self.view?.presentScene(storeScene, transition: transition)
            }
        
            
            // Ensure the audio stops when the transition is done
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                GlobalSettings.shared.stopTransitionAudio() // Stop transition audio after 1 second
            }
        }
        
        let optionsbutton = mobile_game_2048.GlobalSettings.shared.optionsbutton
        if optionsbutton.contains(location) {
            self.viewController?.showInterstitialAdIfAvailable()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                GlobalSettings.shared.playTransitionAudio() // Play transition sound
                
                let OptionScene = OptionsScene(size: self.size)
                OptionScene.viewController = self.viewController //ANY SCENE TRANSITION NECESSARY FOR ADS
                OptionScene.scaleMode = self.scaleMode
                
                let transition = SKTransition.fade(withDuration: 1.0)
                self.view?.presentScene(OptionScene, transition: transition)
            }
            
            // Ensure the audio stops when the transition is done
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                GlobalSettings.shared.stopTransitionAudio() // Stop transition audio after 1 second
            }
        }
    }
}
