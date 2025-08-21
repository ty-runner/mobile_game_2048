//
//  StoreSubCoins.swift
//  mobile_game_2048
//
//  Clean, documented version
//

import SpriteKit

/// A tappable UI node that subtracts coins in the store.
final class StoreSubCoins: SKNode {

    private let background: SKShapeNode
    private let valLabel: SKLabelNode
    private let count: Int

    /// Creates a “-coins” badge that responds to taps.
    /// - Parameter count: Number of coins to subtract when tapped.
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
        valLabel.text = "-\(count)"
        valLabel.fontSize = 20
        valLabel.fontColor = .white
        valLabel.position = CGPoint(x: 0, y: 10)
        valLabel.zPosition = 2

        super.init()
        isUserInteractionEnabled = true

        addChild(background)
        addChild(valLabel)
        self.name = "StoreSubCoins"
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Safeguard: ensure GameData exists and subtraction won’t underflow
        let newValue = max(0, GameData.shared.coins - count)
        GameData.shared.coins = newValue

        // Update any on-screen coin region if present
        if let coinRegion = parent?.childNode(withName: "CoinRegion") as? CoinRegion {
            coinRegion.updateCoins(to: GameData.shared.coins)
        }
    }
}
