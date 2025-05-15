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
    
    let homescreen = SKSpriteNode(imageNamed: "StartScene")
    let videoNode = SKVideoNode(fileNamed: "StartSceneVideo.mp4")
    

    func addDebugBoundingBox(rect: CGRect, color: SKColor, to parent: SKNode) {
        let path = CGPath(rect: rect, transform: nil)
        let box = SKShapeNode(path: path)
        box.strokeColor = color
        box.lineWidth = 2.0
        box.zPosition = 9999 // Make sure it's on top of other nodes
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

        let startButton2X = size.width * 0.15
        let startButton2Y = size.height * 0.51
        GlobalSettings.shared.startbutton2 = CGRect(x: startButton2X, y: startButton2Y, width: buttonWidth * 4, height: buttonHeight)

        // Store button in the middle
        let storeButtonX = (size.width - buttonWidth) / 2.05
        let storeButtonY = size.height * 0.30
        GlobalSettings.shared.storebutton = CGRect(x: storeButtonX, y: storeButtonY, width: buttonWidth, height: buttonHeight)

        // Options button more to the right
        let optionsButtonX = (size.width - buttonWidth) / 1.35
        let optionsButtonY = size.height * 0.30
        GlobalSettings.shared.optionsbutton = CGRect(x: optionsButtonX, y: optionsButtonY, width: buttonWidth, height: buttonHeight)


        /*// Add visible debug boxes for layout verification
        addDebugBoundingBox(rect: GlobalSettings.shared.startbutton1, color: .red, to: self)
        addDebugBoundingBox(rect: GlobalSettings.shared.startbutton2, color: .orange, to: self)

        addDebugBoundingBox(rect: GlobalSettings.shared.storebutton, color: .green, to: self)
        addDebugBoundingBox(rect: GlobalSettings.shared.optionsbutton, color: .blue, to: self)*/


        //addChild(GlobalSettings.shared.backButton)
        
        /*
         //debugging for Startbuttons Area
         let debugRect = SKShapeNode(rect: storebutton)
         debugRect.strokeColor = SKColor.red
         debugRect.lineWidth = 2
         debugRect.zPosition = 1
         addChild(debugRect)
         */
        
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
            print("Store CLICKED")
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
            print("Option CLICKED")
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
