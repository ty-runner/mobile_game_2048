//
//  OptionsSceen.swift
//  mobile_game_2048
//
//  Created by Cameron McClymont on 3/12/25.
//

import Foundation
import SpriteKit
import AVFoundation

class OptionsScene: SKScene {
    
    let OptionScene = SKSpriteNode(imageNamed: "OptionsScene")
    //Variables
    var MuteSound: SKSpriteNode!
    var MuteMusic: SKSpriteNode!
    var isSoundMuted: Bool = false
    var isMusicMuted: Bool = false
    
    override func didMove(to view: SKView) {
        
        //Sets Initial Scene
        OptionScene.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        OptionScene.size = CGSize(width: size.width, height: size.height)
        OptionScene.zPosition = 0
        addChild(OptionScene)
        let coinRegion = CoinRegion(coins: GameData.shared.coins)
        coinRegion.position = CGPoint(x: 100, y: size.height - 50)
        addChild(coinRegion)
        
        
        /*
        let debugRect = SKShapeNode(rect: BackButton)
        debugRect.strokeColor = SKColor.red
        debugRect.lineWidth = 2
        debugRect.zPosition = 1
        addChild(debugRect)
        */
        
        //Sets Size and Position of buttons
        let buttonWidth: CGFloat = 45
        let buttonHeight: CGFloat = 60
        let buttonX = (size.width)/2// 20 points from the right edge
        let buttonY = size.height * 0.50 // 20 points from the top edge

        //Image, Size, and Position of MuteSoundButton
        MuteSound = SKSpriteNode(imageNamed: "MuteSound.png")
        MuteSound.size = CGSize(width: buttonWidth, height: buttonHeight)
        MuteSound.position = CGPoint(x: buttonX * 1.30, y: buttonY)
        MuteSound.zPosition = 1
        addChild(MuteSound)
        
        //Image, Size, and Position of MuteMusicButton
        MuteMusic = SKSpriteNode(imageNamed: "MuteMusic.png")
        MuteMusic.size = CGSize(width: buttonWidth, height: buttonHeight)
        MuteMusic.position = CGPoint(x: buttonX * 0.70, y: buttonY)
        MuteMusic.zPosition = 1
        addChild(MuteMusic)
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        //Calls global backbutton
        let backButton = mobile_game_2048.GlobalSettings.shared.backButton
        
        //BackButton Pressed transition scene and play sound
        //let plusButton = plusButton
        //let minusButton = minusButton
        if backButton!.contains(location){
            GlobalSettings.shared.transitionAudioPlayer?.volume = isSoundMuted ? 0 : 0.5
            GlobalSettings.shared.playTransitionAudio() // Play transition sound
            let startScene = StartScene(size: size)
            let transition = SKTransition.fade(withDuration: 1.0)
            view?.presentScene(startScene, transition: transition)
            
            // Ensure the audio stops when the transition is done
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
               GlobalSettings.shared.stopTransitionAudio() // Stop transition audio after 1 second
            }
        }
        
        
        // Toggle sound mute
        if MuteSound.contains(location) {
            isSoundMuted.toggle()
            GlobalSettings.shared.isSoundMuted = isSoundMuted
            print("Sound muted: \(isSoundMuted)")
        }

        // Toggle music mute
        if MuteMusic.contains(location) {
            isMusicMuted.toggle()
            GlobalSettings.shared.isMusicMuted = isMusicMuted
            print("Music muted: \(isMusicMuted)")
        }
    }
    
}
