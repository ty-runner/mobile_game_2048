import SpriteKit

class StoreAddCoins: SKNode {
    private var background: SKShapeNode!
    private var valLabel: SKLabelNode!
    private var count: Int
    
    init(count: Int) {
        self.count = count
        super.init()
        
        // Enable interaction
        isUserInteractionEnabled = true

        // Background with Rounded Corners (Transparent)
        let rect = CGRect(x: -75, y: -25, width: 300, height: 90)
        background = SKShapeNode(rect: rect, cornerRadius: 20) // Rounded corners
        background.fillColor = .clear // Transparent fill
        background.strokeColor = .clear // No border
        background.zPosition = 1
        addChild(background)


        // Coin Count Label
        valLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        valLabel.text = "+ \(count)"
        valLabel.fontSize = 20
        valLabel.fontColor = .white
        valLabel.position = CGPoint(x: 60, y: 10)
        valLabel.zPosition = 2
        addChild(valLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Handle taps on this node
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        GameData.shared.coins += count  // Update coin count
        if let coinRegion = parent?.childNode(withName: "CoinRegion") as? CoinRegion {
            coinRegion.updateCoins(to: GameData.shared.coins)  // Update UI
        }
    }
}
