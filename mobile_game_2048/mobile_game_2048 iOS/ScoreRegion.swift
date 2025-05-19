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
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 20, y: -5)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateScore(to newCount: Int) {
        let clampedCount = max(0, newCount) // Prevent negative score
        
        // Calculate the difference for the +X animation
        let diff = clampedCount - (Int(scoreLabel.text ?? "0") ?? 0)
        
        if diff > 0 {
            showScoreIncrement(diff)
        }
        
        scoreLabel.text = "\(clampedCount)"
        GameData.shared.score = clampedCount
    }
    private var activeIncrementsCount = 0

    private func showScoreIncrement(_ increment: Int) {
        let incrementLabel = SKLabelNode(fontNamed: scoreLabel.fontName)
        incrementLabel.text = "+\(increment)"
        incrementLabel.fontSize = 30
        incrementLabel.fontColor = .yellow

        // Position horizontally same as before, but offset vertically by count * 20 points
        let verticalOffset = CGFloat(activeIncrementsCount * 20)
        incrementLabel.position = CGPoint(x: scoreLabel.position.x + 50, y: scoreLabel.position.y + verticalOffset)
        incrementLabel.zPosition = 3
        addChild(incrementLabel)
        
        activeIncrementsCount += 1

        // Animate: move up by 30 points, fade out over 1 second
        let moveUp = SKAction.moveBy(x: 0, y: 30, duration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let group = SKAction.group([moveUp, fadeOut])
        let remove = SKAction.run { [weak self] in
            incrementLabel.removeFromParent()
            self?.activeIncrementsCount -= 1
        }
        let sequence = SKAction.sequence([group, remove])
        
        incrementLabel.run(sequence)
    }


}
