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
    let CashPile = SKSpriteNode(imageNamed: "CashPile")
    let CashStack = SKSpriteNode(imageNamed: "CashStack")
    let CashChest = SKSpriteNode(imageNamed: "CashChest")
    let CashVault = SKSpriteNode(imageNamed: "CashVault")
    var scrollView: UIScrollView!
    //var backButtonImageView: UIImageView? // Keep a reference to the back button
    // Helper function to add StoreAddCoins nodes
    func addCoinItem(image: String, coins: Int, position: CGPoint, name: String) {
        let item = StoreAddCoins(count: coins)
        item.position = position
        item.name = name
        
        let icon = SKSpriteNode(imageNamed: image)
        icon.zPosition = 1
        icon.setScale(0.1) // scale if needed
        icon.position = .zero // center inside the parent
        item.addChild(icon)
        
        addChild(item)
    }
    override func didMove(to view: SKView) {
        // Add store background
        storeBackground.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        storeBackground.size = CGSize(width: size.width, height: size.height)
        storeBackground.zPosition = 0
        addChild(storeBackground)
        
        // Coin display
        let coinRegion = CoinRegion(coins: GameData.shared.coins)
        coinRegion.position = CGPoint(x: size.width / 2, y: size.height - 100)
        coinRegion.name = "CoinRegion"
        addChild(coinRegion)
        
        // Add coin bundles
        addCoinItem(image: "CashStack",  coins: 100, position: CGPoint(x: size.width / 4, y: size.height / 2.5), name: "CashStack")
        addCoinItem(image: "CashPile",   coins: 500, position: CGPoint(x: size.width / 2, y: size.height / 2.5), name: "CashPile")
        addCoinItem(image: "CashChest",  coins: 1000, position: CGPoint(x: 3 * size.width / 4, y: size.height / 2.5), name: "CashChest")
        addCoinItem(image: "CashVault",  coins: 5000, position: CGPoint(x: size.width / 2, y: size.height / 4), name: "CashVault")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        let backButton = GlobalSettings.shared.backButton
        if backButton!.contains(location) {
            GlobalSettings.shared.playTransitionAudio() // Play transition sound
            let startScene = StartScene(size: size)
            startScene.viewController = self.viewController //NECESSARY TO RESET VIEW CONTROLLER ANYTIME TRANSITIONING FROM SCENES FOR ADS
            let transition = SKTransition.fade(withDuration: 1.0)
            view?.presentScene(startScene, transition: transition)

            // Ensure the audio stops when the transition is done
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                GlobalSettings.shared.stopTransitionAudio() // Stop transition audio after 1 second
            }
        }
        if let storeAdd = touchedNode.parent as? StoreAddCoins {
            let coinsToAdd = storeAdd.count
            GameData.shared.coins += coinsToAdd

            if let coinRegion = self.childNode(withName: "CoinRegion") as? CoinRegion {
                coinRegion.updateCoins(to: GameData.shared.coins)
            }
        }
    }


}
