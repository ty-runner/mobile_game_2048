import SpriteKit

class StoreAddCoins: SKNode {
    private var background: SKShapeNode!
    private var valLabel: SKLabelNode!
    var count: Int
    
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
        valLabel.text = "\(count)"
        valLabel.fontSize = 20
        valLabel.fontColor = .white
        valLabel.position = CGPoint(x: 0, y: 55)
        valLabel.zPosition = 2
        addChild(valLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
