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
    }
}
