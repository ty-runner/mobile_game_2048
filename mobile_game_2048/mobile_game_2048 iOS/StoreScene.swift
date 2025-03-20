//
//  StoreScene.swift
//  test
//
//  Created by Cameron McClymont on 3/5/25.
//

import Foundation
import SpriteKit
import UIKit
import AVFoundation

class StoreScene: SKScene {
    
    weak var viewController: GameViewController?  // Add this property
    
    let storeBackground = SKSpriteNode(imageNamed: "StoreScene")
    var scrollView: UIScrollView!
    //var backButtonImageView: UIImageView? // Keep a reference to the back button
    
    override func didMove(to view: SKView) {
        
        // Add store background
        storeBackground.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        storeBackground.size = CGSize(width: size.width, height: size.height)
        storeBackground.zPosition = 0
        addChild(storeBackground)
        let coinRegion = CoinRegion(coins: GameData.shared.coins)
        coinRegion.position = CGPoint(x: 100, y: size.height - 50)
        addChild(coinRegion)
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
