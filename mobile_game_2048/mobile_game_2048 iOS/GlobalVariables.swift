//
//  GlobalVariables.swift
//  mobile_game_2048
//
//  Created by Cameron McClymont on 3/12/25.
//

import Foundation
import SpriteKit
import AVFoundation
import CoreGraphics

class GlobalSettings {
    static let shared = GlobalSettings()
    
    var backButton: SKSpriteNode!
    
    var startbutton: CGRect = .zero
    
    var storebutton: CGRect = .zero
    
    var optionsbutton: CGRect = .zero
    
    var transitionAudioPlayer: AVAudioPlayer?
    
    private init() {} // This prevents others from creating instances of this class
    
    func playTransitionAudio() {
            if let transitionAudioURL = Bundle.main.url(forResource: "TransitionBubbles", withExtension: "mp3") {
                do {
                    transitionAudioPlayer = try AVAudioPlayer(contentsOf: transitionAudioURL)
                    transitionAudioPlayer?.volume = 0.3
                    transitionAudioPlayer?.prepareToPlay()  // Prepare audio before playing
                    transitionAudioPlayer?.play()
                } catch {
                    print("Error loading transition audio: \(error)")
                }
            }
        }
    
    func stopTransitionAudio() {
        transitionAudioPlayer?.stop()
    }
    
    func setupBackButton(for screenSize: CGSize) { //red X back button, CURRENTLY PRESENT ON OPEN - SHOULDNT BE
        let buttonWidth: CGFloat = 35
        let buttonHeight: CGFloat = 35
        let buttonX = screenSize.width - buttonWidth - 10 // 20 points from the right edge
        let buttonY = screenSize.height - buttonHeight - 10 // 20 points from the top edge
        
        // Create the back button as an SKSpriteNode using your image "BackButton.png"
        backButton = SKSpriteNode(imageNamed: "BackButton.png")
        backButton.size = CGSize(width: buttonWidth, height: buttonHeight)
        backButton.position = CGPoint(x: buttonX, y: buttonY)
        backButton.zPosition = 1 // Ensure it's on top of other content
    }
}
