//
//  ScoreRegion.swift
//  mobile_game_2048
//
//  Created by Ty Runner on 4/6/25.
//


import SpriteKit

class ScoreRegion: SKNode {
    private var background: SKShapeNode!
    //private var scoreIcon: SKSpriteNode!
    private var scoreLabel: SKLabelNode!
    
    init(score: Int) {
        super.init()
        
        // Background with Rounded Corners
        let rect = CGRect(x: -75, y: -25, width: 150, height: 50)
        background = SKShapeNode(rect: rect, cornerRadius: 20) // Rounded corners
        background.fillColor = .clear
        background.strokeColor = .clear
        background.zPosition = 1
        addChild(background)

        // Score Icon
        /*scoreIcon = SKSpriteNode(imageNamed: "scoreIcon")
        scoreIcon.size = CGSize(width: 30, height: 30)
        scoreIcon.position = CGPoint(x: -40, y: 0)
        scoreIcon.zPosition = 2
        addChild(scoreIcon)*/

        // Coin Count Label
        scoreLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        if scoreLabel.fontName == nil { // Fallback if font is unavailable
            scoreLabel.fontName = "Helvetica-Bold"
        }
        scoreLabel.text = "\(score)"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 20, y: -5)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // Function to update coin count
    func updateScore(to newCount: Int) {
        let clampedCount = max(0, newCount) // Prevent negative coin count
        scoreLabel.text = "\(clampedCount)"
        GameData.shared.score = clampedCount
    }
}
