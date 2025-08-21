//
//  VideoHelper.swift
//  Cleaned & annotated on 2025-08-16 20:11 UTC
//
//  Notes:
//  - This file has been auto-annotated with documentation comments.
//  - Risky constructs (force unwraps, \1
//try! , continuations) are flagged with TODOs.
//  - No public APIs were intentionally changed.
//
import SpriteKit
import AVFoundation

class VideoHelper {
    static func playBackgroundVideo(on scene: SKScene, named filename: String = "background") -> SKVideoNode? {
        guard let videoURL = Bundle.main.url(forResource: filename, withExtension: "mp4") else {
            print("Video file not found.")
            return nil
        }

        let player = AVPlayer(url: videoURL)
        player.isMuted = true

        let videoNode = SKVideoNode(avPlayer: player)
        videoNode.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        videoNode.size = scene.size
        videoNode.zPosition = -1
        scene.addChild(videoNode)
        videoNode.play()

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            player.seek(to: .zero)
            player.play()
        }

        return videoNode
    }
}
