//
//  LoadScene.swift
//  mobile_game_2048
//
//  Created by Cameron McClymont on 7/12/25.
//

import SpriteKit

class LoadingScene: SKScene {
    
    private var progressBar: SKShapeNode!
    private var progressBackground: SKShapeNode!
    private var companyNameNode: SKSpriteNode!
    
    private var hasMovedToStartScene = false
    
    private var totalTasks: Int = 0
    private var completedTasks: Int = 0
    
    private var currentProgress: CGFloat = 0.0
    private var targetProgress: CGFloat = 0.0
    
    // These are set when background tasks finish
    var adsLoaded = false
    var gameCenterLoaded = false
    
    weak var viewController: GameViewController? // 
    
    // MARK: - Setup
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        // Company name
        companyNameNode = SKSpriteNode(imageNamed: "CompanyName")
        companyNameNode.position = CGPoint(x: size.width/2, y: size.height/2 + 70)
        companyNameNode.zPosition = 1
        companyNameNode.setScale(0.15)
        companyNameNode.alpha = 0.0
        addChild(companyNameNode)
        
        // Progress background
        let barWidth = size.width * 0.6
        let barHeight: CGFloat = 20
        progressBackground = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 5)
        progressBackground.position = CGPoint(x: size.width/2, y: size.height/2)
        progressBackground.fillColor = .darkGray
        progressBackground.strokeColor = .clear
        progressBackground.alpha = 0.0
        addChild(progressBackground)
        
        // Progress bar
        let initialRect = CGRect(x: -barWidth/2, y: -barHeight/2 + 2, width: 0, height: barHeight - 4)
        progressBar = SKShapeNode(rect: initialRect, cornerRadius: 5)
        progressBar.fillColor = .green
        progressBar.strokeColor = .clear
        progressBar.position = CGPoint(x: size.width/2, y: size.height/2)
        progressBar.alpha = 0.0
        addChild(progressBar)
        
        // Fade in
        let fadeIn = SKAction.fadeIn(withDuration: 1.0)
        companyNameNode.run(fadeIn)
        progressBackground.run(fadeIn)
        progressBar.run(fadeIn)
    }
    
    // MARK: - Task Management
    
    func setTotalTasks(_ count: Int) {
        totalTasks = count
        completedTasks = 0
        targetProgress = 0
        currentProgress = 0
    }
    
    func markTaskComplete() {
        completedTasks += 1
        targetProgress = CGFloat(Float(completedTasks) / Float(totalTasks))
    }
    
    // MARK: - Frame Update
    
    override func update(_ currentTime: TimeInterval) {
        let smoothSpeed: CGFloat = 0.06 // faster ease for smoothness
        let creepRate: CGFloat = 0.004  // progress per frame while waiting
        let maxWhileWaiting: CGFloat = 0.95
        
        var target: CGFloat
        if adsLoaded && gameCenterLoaded {
            // Final stretch → head for 100%
            target = 1.0
        } else {
            // While waiting → creep toward 95% steadily
            target = min(currentProgress + creepRate, maxWhileWaiting)
        }
        
        currentProgress += (target - currentProgress) * smoothSpeed
        updateProgressBar()
        
        // Transition when both ready and progress full
        if adsLoaded && gameCenterLoaded && !hasMovedToStartScene && currentProgress >= 0.999 {
            hasMovedToStartScene = true
            fadeOutAndMoveToStart()
        }
    }
    
    // MARK: - UI Helpers
    
    private func updateProgressBar() {
        let barWidth = size.width * 0.6
        let barHeight: CGFloat = 20
        let maxWidth = barWidth - 4
        let newWidth = max(0, min(currentProgress, 1)) * maxWidth
        let newRect = CGRect(x: -barWidth/2, y: -barHeight/2 + 2, width: newWidth, height: barHeight - 4)
        progressBar.path = CGPath(roundedRect: newRect, cornerWidth: 5, cornerHeight: 5, transform: nil)
    }
    
    private func fadeOutAndMoveToStart() {
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        companyNameNode.run(fadeOut)
        progressBar.run(fadeOut)
        progressBackground.run(fadeOut)
        
        run(SKAction.wait(forDuration: 1.0)) {
            let startScene = StartScene(size: self.size)
            startScene.viewController = self.viewController // ✅ Pass controller to StartScene
            let transition = SKTransition.fade(withDuration: 1.0)
            self.view?.presentScene(startScene, transition: transition)
        }
    }
}





//class LoadingScene: SKScene {
//    
//    var progressBar: SKShapeNode!
//    var progressBackground: SKShapeNode!
//    
//    var progress: CGFloat = 0 {
//        didSet {
//            updateProgressBar()
//        }
//    }
//    
//    override func didMove(to view: SKView) {
//        backgroundColor = .black
//        
//        let CompanyName = SKSpriteNode(imageNamed: "CompanyName")
//        CompanyName.position = CGPoint(x: size.width/2, y: size.height/2 + 70)
//        CompanyName.zPosition = 1
//        
//        // Scale the company name to be smaller
//        CompanyName.xScale = 0.15
//        CompanyName.yScale = 0.15
//        
//        // Start with the company name invisible
//        CompanyName.alpha = 0.0
//        addChild(CompanyName)
//        // Create a fade-in action and run it on the company name node
//        let fadeIn = SKAction.fadeIn(withDuration: 0.75)
//        CompanyName.run(fadeIn)
//
//        // Background bar
//        let barWidth = size.width * 0.6
//        let barHeight: CGFloat = 20
//        
//        progressBackground = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 5)
//        progressBackground.position = CGPoint(x: size.width/2, y: size.height/2)
//        progressBackground.fillColor = .darkGray
//        progressBackground.strokeColor = .clear
//        addChild(progressBackground)
//        
//        // Progress bar (green), start at zero width
//       let initialRect = CGRect(x: -barWidth/2, y: -barHeight/2 + 2, width: 0, height: barHeight - 4)
//       progressBar = SKShapeNode(rect: initialRect, cornerRadius: 5)
//       progressBar.fillColor = .green
//       progressBar.strokeColor = .clear
//       progressBar.position = CGPoint(x: size.width/2, y: size.height/2)
//       addChild(progressBar)
//   }
//    
//    func updateProgressBar() {
//        let barWidth = size.width * 0.6
//        let barHeight: CGFloat = 20
//        let maxWidth = barWidth - 4
//        let newWidth = max(0, min(progress, 1)) * maxWidth
//        
//        // Update path with new width, anchored at left edge of the bar
//        let newRect = CGRect(x: -barWidth/2, y: -barHeight/2 + 2, width: newWidth, height: barHeight - 4)
//        progressBar.path = CGPath(roundedRect: newRect, cornerWidth: 5, cornerHeight: 5, transform: nil)
//    }
//}
