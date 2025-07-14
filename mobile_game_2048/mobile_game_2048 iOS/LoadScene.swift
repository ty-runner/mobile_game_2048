//
//  LoadScene.swift
//  mobile_game_2048
//
//  Created by Cameron McClymont on 7/12/25.
//

import SpriteKit

class LoadingScene: SKScene {
    
    var progressBar: SKShapeNode!
    var progressBackground: SKShapeNode!
    
    var progress: CGFloat = 0 {
        didSet {
            updateProgressBar()
        }
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        // Background bar
        let barWidth = size.width * 0.6
        let barHeight: CGFloat = 20
        
        progressBackground = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 5)
        progressBackground.position = CGPoint(x: size.width/2, y: size.height/2)
        progressBackground.fillColor = .darkGray
        progressBackground.strokeColor = .clear
        addChild(progressBackground)
        
        // Progress bar (green), start at zero width
       let initialRect = CGRect(x: -barWidth/2, y: -barHeight/2 + 2, width: 0, height: barHeight - 4)
       progressBar = SKShapeNode(rect: initialRect, cornerRadius: 5)
       progressBar.fillColor = .green
       progressBar.strokeColor = .clear
       progressBar.position = CGPoint(x: size.width/2, y: size.height/2)
       addChild(progressBar)
   }
    
    func updateProgressBar() {
        let barWidth = size.width * 0.6
        let barHeight: CGFloat = 20
        let maxWidth = barWidth - 4
        let newWidth = max(0, min(progress, 1)) * maxWidth
        
        // Update path with new width, anchored at left edge of the bar
        let newRect = CGRect(x: -barWidth/2, y: -barHeight/2 + 2, width: newWidth, height: barHeight - 4)
        progressBar.path = CGPath(roundedRect: newRect, cornerWidth: 5, cornerHeight: 5, transform: nil)
    }
}
