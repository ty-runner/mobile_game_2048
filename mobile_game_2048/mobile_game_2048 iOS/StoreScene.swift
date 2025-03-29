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
    var count = 100
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
        coinRegion.name = "CoinRegion"
        addChild(coinRegion)
        let StoreAddCoins = StoreAddCoins(count: count)
        StoreAddCoins.position = CGPoint(x: size.width / 3, y: size.height / 4.8)
        addChild(StoreAddCoins) // need to add on click, update coins
        let StoreSubCoins = StoreSubCoins(count: count)
        StoreSubCoins.position = CGPoint(x: size.width / 3, y: size.height / 10)
        addChild(StoreSubCoins) //need to add on click, update coins
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        let backButton = GlobalSettings.shared.backButton
        if backButton!.contains(location) {
            GlobalSettings.shared.playTransitionAudio() // Play transition sound
            let startScene = StartScene(size: size)
            let transition = SKTransition.fade(withDuration: 1.0)
            view?.presentScene(startScene, transition: transition)

            // Ensure the audio stops when the transition is done
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                GlobalSettings.shared.stopTransitionAudio() // Stop transition audio after 1 second
            }
        }

        if let coinAdd = self.childNode(withName: "StoreAddCoins") as? StoreAddCoins,
           coinAdd.contains(location) {
            GameData.shared.coins += count

            if let coinRegion = self.childNode(withName: "CoinRegion") as? CoinRegion {
                coinRegion.updateCoins(to: GameData.shared.coins)
            }
        }

        if let coinSubtract = self.childNode(withName: "StoreSubCoins") as? StoreSubCoins,
           coinSubtract.contains(location) {
            GameData.shared.coins -= count

            if let coinRegion = self.childNode(withName: "CoinRegion") as? CoinRegion {
                coinRegion.updateCoins(to: GameData.shared.coins)
            }
        }
    }


}
