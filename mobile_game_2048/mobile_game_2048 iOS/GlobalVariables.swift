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
    
    var coinIcon: SKSpriteNode!
    var startbutton: CGRect = .zero
    var storebutton: CGRect = .zero
    var optionsbutton: CGRect = .zero
    
    var isSoundMuted: Bool = false {
        didSet {
            //Update sound volume when mute value changes
            transitionAudioPlayer?.volume = isSoundMuted ? 0 : 0.2
        }
    }
    
    var isMusicMuted: Bool = false {
        didSet {
            //Update background music volume when the mute value changes
            backgroundMusicPlayer?.volume = isMusicMuted ? 0 : 0.2
        }
    }
    
    var transitionAudioPlayer: AVAudioPlayer?
    var backgroundMusicPlayer: AVAudioPlayer?
    
    private init() {} // This prevents others from creating instances of this class
    
    
    //Sets up transition/button press audio change music file
    func playTransitionAudio() {
            if let transitionAudioURL = Bundle.main.url(forResource: "glasshit", withExtension: "mp3") {
                do {
                    transitionAudioPlayer = try AVAudioPlayer(contentsOf: transitionAudioURL)
                    transitionAudioPlayer?.volume = isSoundMuted ? 0 : 0.2
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
    
    //Sets up background Music Just Change musicfile
    func setupAudio() {
        if let backgroundMusicURL = Bundle.main.url(forResource: "backgroundMusic", withExtension: "mp3") {
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: backgroundMusicURL)
                backgroundMusicPlayer?.numberOfLoops = -1
                backgroundMusicPlayer?.volume = isMusicMuted ? 0 : 0.2
                backgroundMusicPlayer?.play()
            } catch {
                print("Error loading background music: \(error)")
            }
        }
    }
    
    func setupBackButton(for screenSize: CGSize) { //red X back button, CURRENTLY PRESENT ON OPEN - SHOULDNT BE
        let buttonWidth: CGFloat = 60
        let buttonHeight: CGFloat = 60
        let buttonX = screenSize.width - buttonWidth + 10// 20 points from the right edge
        let buttonY = screenSize.height - buttonHeight - 10 // 20 points from the top edge
        
        // Create the back button as an SKSpriteNode using your image "BackButton.png"
        backButton = SKSpriteNode(imageNamed: "BackButton.png")
        backButton.size = CGSize(width: buttonWidth, height: buttonHeight)
        backButton.position = CGPoint(x: buttonX, y: buttonY)
        backButton.zPosition = 1 // Ensure it's on top of other content
    }
    func setupCoinRegion(for screenSize: CGSize) { //red X back button, CURRENTLY PRESENT ON OPEN - SHOULDNT BE
        let buttonWidth: CGFloat = 200
        let buttonHeight: CGFloat = 50
        let iconX = screenSize.width - buttonWidth // 20 points from the right edge
        let iconY = screenSize.height - buttonHeight - 10 // 20 points from the top edge
        
        // Create the back button as an SKSpriteNode using your image "BackButton.png"
        coinIcon = SKSpriteNode(imageNamed: "CoinIcon")
        coinIcon.size = CGSize(width: buttonWidth, height: buttonHeight)
        coinIcon.position = CGPoint(x: iconX, y: iconY)
         // Ensure it's on top of other content

    }
}
