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
    
    override func didMove(to view: SKView) {
        
        OptionScene.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        
        OptionScene.size = CGSize(width: size.width, height: size.height)
        OptionScene.zPosition = 0
        addChild(OptionScene)
        
        /*
        let debugRect = SKShapeNode(rect: BackButton)
        debugRect.strokeColor = SKColor.red
        debugRect.lineWidth = 2
        debugRect.zPosition = 1
        addChild(debugRect)
        */
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        let backButton = mobile_game_2048.GlobalSettings.shared.backButton
        
        if backButton!.contains(location){
            GlobalSettings.shared.playTransitionAudio() // Play transition sound
            let startScene = StartScene(size: size)
            let transition = SKTransition.fade(withDuration: 1.0)
            view?.presentScene(startScene, transition: transition)
            
            // Ensure the audio stops when the transition is done
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
               GlobalSettings.shared.stopTransitionAudio() // Stop transition audio after 1 second
            }
        }
        
    }
}
