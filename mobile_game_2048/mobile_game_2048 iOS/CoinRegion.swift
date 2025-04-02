//
//  CoinRegion.swift
//  mobile_game_2048
//
//  Created by Ty Runner on 3/19/25.
//


import SpriteKit

class CoinRegion: SKNode {
    private var background: SKShapeNode!
    private var coinIcon: SKSpriteNode!
    private var coinLabel: SKLabelNode!
    
    init(coins: Int) {
        super.init()
        
        // Background with Rounded Corners
        let rect = CGRect(x: -75, y: -25, width: 150, height: 50)
        background = SKShapeNode(rect: rect, cornerRadius: 20) // Rounded corners
        background.fillColor = .brown
        background.strokeColor = .clear
        background.zPosition = 1
        addChild(background)

        // Coin Icon
        coinIcon = SKSpriteNode(imageNamed: "CoinIcon")
        coinIcon.size = CGSize(width: 30, height: 30)
        coinIcon.position = CGPoint(x: -40, y: 0)
        coinIcon.zPosition = 2
        addChild(coinIcon)

        // Coin Count Label
        coinLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        if coinLabel.fontName == nil { // Fallback if font is unavailable
            coinLabel.fontName = "Helvetica-Bold"
        }
        coinLabel.text = "\(coins)"
        coinLabel.fontSize = 20
        coinLabel.fontColor = .white
        coinLabel.position = CGPoint(x: 20, y: -5)
        coinLabel.zPosition = 2
        addChild(coinLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // Function to update coin count
    func updateCoins(to newCount: Int) {
        let clampedCount = max(0, newCount) // Prevent negative coin count
        coinLabel.text = "\(clampedCount)"
        GameData.shared.coins = clampedCount
    }
}
