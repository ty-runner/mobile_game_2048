//
//  GameViewController.swift
//  mobile_game_2048 iOS
//
//  Created by Ty Runner on 3/12/25.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let startscene = StartScene(size: view.bounds.size)

        // Present the scene
        let skView = self.view as! SKView
        
        skView.presentScene(startscene)
        
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
