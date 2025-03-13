//
//  GameScene.swift
//  mobile_game_2048 Shared
//
//  Created by Ty Runner on 3/12/25.
//

import SpriteKit

class GameScene: SKScene {
    
    weak var viewController: GameViewController?
    
    let background = SKSpriteNode(imageNamed: "background")
    
    override func didMove(to view: SKView) {
        
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        
        background.size = CGSize(width: size.width, height: size.height)
        background.zPosition = 0
        addChild(background)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
   
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {

    override func mouseDown(with event: NSEvent) {
        
    }
    
    override func mouseDragged(with event: NSEvent) {
        
    }
    
    override func mouseUp(with event: NSEvent) {
        
    }

}
#endif

