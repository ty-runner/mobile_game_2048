//
//  StoreAddCoins.swift
//  mobile_game_2048
//
//  Clean, documented version
//

import SpriteKit

/// A small UI node that displays a “+ coins” value in the store.
final class StoreAddCoins: SKNode {

    private let background: SKShapeNode
    private let valLabel: SKLabelNode
    let count: Int

    /// Creates a “+coins” badge.
    /// - Parameter count: Number of coins this badge represents.
    init(count: Int) {
        self.count = count

        // Background with rounded corners (transparent)
        let rect = CGRect(x: -75, y: -25, width: 300, height: 90)
        self.background = SKShapeNode(rect: rect, cornerRadius: 20)
        background.fillColor = .clear
        background.strokeColor = .clear
        background.zPosition = 1

        // Label
        self.valLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        valLabel.text = "+\(count)"
        valLabel.fontSize = 20
        valLabel.fontColor = .white
        valLabel.position = CGPoint(x: 0, y: 10)
        valLabel.zPosition = 2

        super.init()
        isUserInteractionEnabled = false   // this view is display-only

        addChild(background)
        addChild(valLabel)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
