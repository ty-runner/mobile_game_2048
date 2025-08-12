import Foundation
import SpriteKit
import UIKit
import AVFoundation

// Represents the store scene in the game, where players can purchase coins and unlock features.
class StoreScene: SKScene {

    // A weak reference to the GameViewController instance.
    weak var viewController: GameViewController?
    
    // The UIScrollView used to display the store content.
    var scrollView: UIScrollView!

    // The background image for the store scene.
    private let storeBackground = SKSpriteNode(imageNamed: "StoreScene")

    // Arrays containing the values, costs, and image names for the different coin packs.
    //These arrays all have to be the same size
    private let goldValues = [5000, 10000, 20000, 50000]
    private let goldCosts = ["$0.99", "$4.99", "$9.99", "$49.99"]
    private let goldImageNames = ["CashStack", "CashPile", "CashChest", "CashVault"]
    private let SkinNames = ["DEFAULT","ABSTRACT","8-BIT FOREST","CORAL COVE","TOKYO 2048"]
    private let Skins = ["background", "Abstract", "8bit", "CoralCove", "Cyberpunk"]

    // Arrays containing the labels, prices, and other data for the unlockable features.
    private let unlockLabels = ["DEFAULT", "UNLOCK", "UNLOCK", "UNLOCK", "UNLOCK"]
    private let unlockPrices = [0, 5000, 10000, 20000, 50000]

    // A reference to the back button.
    private var backButton: UIButton?

    // Called when the scene is presented.
    override func didMove(to view: SKView) {
        // Set up the background image.
        storeBackground.position = CGPoint(x: size.width / 2, y: size.height / 2)
        storeBackground.size = CGSize(width: size.width, height: size.height)
        storeBackground.zPosition = 0
        addChild(storeBackground)

        // Create a CoinRegion node to display the player's coin count.
        let coinRegion = CoinRegion(coins: GameData.shared.coins)
        coinRegion.position = CGPoint(x: size.width / 2, y: size.height - 100)
        coinRegion.name = "CoinRegion"
        coinRegion.zPosition = 1000
        addChild(coinRegion)

        // Set up the scroll view and its content.
        setupScrollView(in: view)
        
        // Add a back button to return to the start scene.
        addBackButton(to: view)

        // Ensure the banner view is visible and on top.
        if let banner = viewController?.bannerView {
            if banner.superview == nil {
                view.addSubview(banner)
            }
            view.bringSubviewToFront(banner)
        }
    }

    // Called when the scene is about to be removed.
    override func willMove(from view: SKView) {
        // Remove the scroll view and back button from the view.
        scrollView?.removeFromSuperview()
        backButton?.removeFromSuperview()
    }

    // Sets up the scroll view and its content.
    private func setupScrollView(in view: SKView) {
        // Calculate the height of the coin region.
        let coinRegionHeight: CGFloat = view.frame.size.height * 0.155
        
        let bannerHeight = viewController?.bannerView?.frame.height ?? 60
        // Create a frame for the scroll view.
        let scrollFrame = CGRect(x: 0, y: coinRegionHeight, width: view.frame.size.width, height: view.frame.size.height - coinRegionHeight - bannerHeight)
        
        // Initialize the scroll view.
        scrollView = UIScrollView(frame: scrollFrame)
        scrollView.showsVerticalScrollIndicator = true
        scrollView.delaysContentTouches = false
        scrollView.backgroundColor = .clear

        // Create a content view for the scroll view.
        let contentHeight: CGFloat = scrollFrame.height * 3
        let storeContentView = UIView(frame: CGRect(x: 0, y: 0, width: scrollFrame.width, height: contentHeight))
        scrollView.addSubview(storeContentView)
        view.addSubview(scrollView)

        // Initialize a variable to track the current y offset.
        var currentYOffset: CGFloat = 20

        // Add unlock containers to the content view.
        for (i, label) in unlockLabels.enumerated() {
            currentYOffset = addUnlockContainer(to: storeContentView, at: i, labelText: label, yOffset: currentYOffset)
        }

        // Add coin pack containers to the content view.
        let spacing: CGFloat = 40
        let containerHeight: CGFloat = size.height * 0.3
        let containerWidth: CGFloat = size.width * 0.35

        for i in 0..<goldImageNames.count {
            if i % 2 == 0 && i != 0 {
                currentYOffset += containerHeight + spacing
            }

            let xPos: CGFloat = (i % 2 == 0) ? scrollFrame.width * 0.1 : scrollFrame.width * 0.55
            let containerFrame = CGRect(x: xPos, y: currentYOffset, width: containerWidth, height: containerHeight)

            let containerView = UIView(frame: containerFrame)
            containerView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            containerView.layer.cornerRadius = 20
            containerView.layer.borderWidth = 2
            containerView.layer.borderColor = UIColor.white.cgColor
            containerView.clipsToBounds = true
            storeContentView.addSubview(containerView)

            // Add a gold image view to the container.
            let goldImageView = UIImageView(image: UIImage(named: goldImageNames[i]))
            goldImageView.frame = CGRect(
                x: (containerView.bounds.width - size.width * 0.2) / 2,
                y: 20,
                width: size.width * 0.2,
                height: size.height * 0.2
            )
            goldImageView.contentMode = .scaleAspectFit
            containerView.addSubview(goldImageView)

            // Add labels to display the coin value and cost.
            let goldValueLabel = UILabel(frame: CGRect(x: 0, y: goldImageView.frame.maxY + 10, width: containerView.bounds.width, height: 24))
            goldValueLabel.text = "\(goldValues[i].formattedWithSeparator())"
            goldValueLabel.textAlignment = .center
            goldValueLabel.textColor = .white
            goldValueLabel.font = UIFont(name: "AvenirNext-Bold", size: 20)
            containerView.addSubview(goldValueLabel)

            let costLabel = UILabel(frame: CGRect(x: 0, y: goldValueLabel.frame.maxY + 5, width: containerView.bounds.width, height: 20))
            costLabel.text = goldCosts[i]
            costLabel.textAlignment = .center
            costLabel.textColor = .white
            costLabel.font = UIFont(name: "AvenirNext-Bold", size: 16)
            containerView.addSubview(costLabel)

            // Add a buy button to the container.
            addBuyButton(to: containerView, frame: containerView.bounds, tag: i + 1)
            
        }
        
        // Set the content size of the scroll view.
        let maxY = storeContentView.subviews.map { $0.frame.maxY }.max() ?? scrollFrame.height

        // Add a final container for the "No Ads" purchase
        let noAdsContainerHeight: CGFloat = 80
        let noAdsContainerY: CGFloat = maxY + 20

        let noAdsContainer = UIView(frame: CGRect(
            x: 20,
            y: noAdsContainerY,
            width: scrollFrame.width - 40,
            height: noAdsContainerHeight
        ))
        noAdsContainer.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        noAdsContainer.layer.cornerRadius = 15
        noAdsContainer.layer.borderWidth = 2
        noAdsContainer.layer.borderColor = UIColor.white.cgColor
        noAdsContainer.clipsToBounds = true
        storeContentView.addSubview(noAdsContainer)

        // Add label or button inside the container
        let noAdsButton = UIButton(type: .system)
        noAdsButton.frame = CGRect(x: 0, y: 0, width: noAdsContainer.bounds.width, height: noAdsContainer.bounds.height)
        noAdsButton.setTitle("Buy No-Ads Version - $9.99", for: .normal)
        noAdsButton.setTitleColor(.white, for: .normal)
        noAdsButton.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 20)
        noAdsButton.backgroundColor = .clear
        noAdsButton.addTarget(self, action: #selector(buyNoAdsTapped), for: .touchUpInside)
        noAdsContainer.addSubview(noAdsButton)

        storeContentView.frame.size.height = maxY + 140
        scrollView.contentSize = CGSize(width: scrollFrame.width, height: maxY + 140)
    }

    // Adds a buy button to the specified view.
    private func addBuyButton(to view: UIView, frame: CGRect, tag: Int) {
        let buyButton = UIButton(frame: frame)
        buyButton.backgroundColor = .clear
        buyButton.tag = tag
        buyButton.addTarget(self, action: #selector(buyButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(buyButton)
    }

    // Adds an unlock container to the specified parent view.
    private func addUnlockContainer(to parentView: UIView, at index: Int, labelText: String, yOffset: CGFloat) -> CGFloat {
        // Calculate the size and position of the container.
        let containerHeight: CGFloat = size.height * 0.5
        let containerWidth: CGFloat = size.width * 0.85
        let containerX = (parentView.frame.width - containerWidth) / 2

        let containerView = UIView(frame: CGRect(x: containerX, y: yOffset, width: containerWidth, height: containerHeight))
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        containerView.layer.cornerRadius = 20
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.white.cgColor
        containerView.clipsToBounds = true
        parentView.addSubview(containerView)
        
        // 👉 Add background image from Skins array if available
        if index < Skins.count {
            let backgroundImageView = UIImageView(frame: containerView.bounds)
            backgroundImageView.image = UIImage(named: Skins[index])
            backgroundImageView.contentMode = .scaleAspectFill
            backgroundImageView.clipsToBounds = true
            containerView.addSubview(backgroundImageView)
            containerView.sendSubviewToBack(backgroundImageView)
        }

        // Get the price of the unlockable feature.
        let price = unlockPrices[index]

        // Add a label to display the price.
        let priceLabel = UILabel(frame: CGRect(x: 0, y: 50, width: containerView.bounds.width, height: 30))
        priceLabel.text = "Cost: \(price.formattedWithSeparator()) coins"
        priceLabel.textAlignment = .center
        priceLabel.textColor = .white
        priceLabel.font = UIFont(name: "AvenirNext-Bold", size: 18)
        containerView.addSubview(priceLabel)

        // Calculate the position and size of the unlock button.
        let buttonHeight: CGFloat = 50
        let buttonWidth: CGFloat = 200
        let buttonX = (containerView.frame.width - buttonWidth) / 2
        let buttonY = containerView.frame.height - buttonHeight - 20
        
        let Skintitles = SkinNames[index]
        
        let BackgroundLabel = UILabel(frame: CGRect(x: 0, y: 20, width: containerView.bounds.width, height: 30))
        BackgroundLabel.text = Skintitles
        BackgroundLabel.textAlignment = .center
        BackgroundLabel.textColor = .white
        BackgroundLabel.font = UIFont(name: "AvenirNext-Bold", size: 24)
        containerView.addSubview(BackgroundLabel)
        

        // Create the unlock button.
        // Create the unlock button.
        let unlockButton = UIButton(frame: CGRect(x: buttonX, y: buttonY, width: buttonWidth, height: buttonHeight))
        unlockButton.layer.cornerRadius = 10
        unlockButton.clipsToBounds = true
        unlockButton.tag = 1000 + index

        // Check if this feature is already unlocked
        if GameData.shared.unlockedFeatures.contains(index) {
            unlockButton.setTitle("UNLOCKED", for: .normal)
            unlockButton.backgroundColor = .gray
            unlockButton.isEnabled = false
        } else {
            unlockButton.setTitle(labelText, for: .normal)
            unlockButton.backgroundColor = (index == 0) ? .gray : .red
            unlockButton.isEnabled = index != 0
            if index != 0 {
                unlockButton.addTarget(self, action: #selector(unlockButtonTapped(_:)), for: .touchUpInside)
            }
        }

        containerView.addSubview(unlockButton)


        // Return the maximum y value of the container view plus some padding.
        return containerView.frame.maxY + 30
    }

    // Called when an unlock button is tapped.
    @objc private func unlockButtonTapped(_ sender: UIButton) {
        // Get the index of the unlockable feature.
        let index = sender.tag - 1000
        let cost = unlockPrices[index]

        // Check if the player has enough coins to unlock the feature.
        if GameData.shared.coins >= cost {
            // Deduct the cost from the player's coins.
            GameData.shared.coins -= cost

            // Update the coin count display.
            if let coinRegion = self.childNode(withName: "CoinRegion") as? CoinRegion {
                coinRegion.updateCoins(to: GameData.shared.coins)
            }

            // Mark the feature as unlocked.
            
            GameData.shared.unlockedFeatures.insert(index)
            print(GameData.shared.unlockedFeatures)
            // Update the unlock button's appearance.
            sender.setTitle("UNLOCKED", for: .normal)
            sender.backgroundColor = .gray
            sender.isEnabled = false
            print("Unlocked feature at index \(index) for \(cost) coins.")
            let themeName = indexToTheme[index]!
            ThemeManager.selectTheme(named: themeName) // This call now updates the video name as well.
        } else {
            // Display an alert if the player doesn't have enough coins.
            let alert = UIAlertController(title: "Not Enough Coins", message: "You need \(cost - GameData.shared.coins) more coins to unlock this.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            viewController?.present(alert, animated: true)
        }
    }

    // Called when a buy button is tapped.
    @objc private func buyButtonTapped(_ sender: UIButton) {
        // Get the tag of the buy button.
        let tag = sender.tag
        guard tag >= 1 && tag <= goldValues.count else { return }
        print("Buy button tapped!")
        // Display a confirmation alert.
        let alert = UIAlertController(title: "Purchase", message: "Are you sure you want to buy \(goldValues[tag - 1].formattedWithSeparator()) coins?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { _ in
            // Add the purchased coins to the player's total.
            GameData.shared.coins += self.goldValues[tag - 1]
            if let coinRegion = self.childNode(withName: "CoinRegion") as? CoinRegion {
                coinRegion.updateCoins(to: GameData.shared.coins)
            }
        }))

        viewController?.present(alert, animated: true)
    }

    // Adds a back button to the specified view.
    private func addBackButton(to view: SKView) {
        let buttonFrame = CGRect(x: 20, y: 40, width: 100, height: 40)
        let backBtn = UIButton(frame: buttonFrame)
        backBtn.setTitle("Back", for: .normal)
        backBtn.backgroundColor = .black
        backBtn.layer.cornerRadius = 10
        backBtn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        view.addSubview(backBtn)
        backButton = backBtn
    }

    // Called when the back button is tapped.
    @objc private func backTapped() {
        // Remove the scroll view and back button from the view.
        scrollView?.removeFromSuperview()
        backButton?.removeFromSuperview()

        // Transition back to the start scene.
        if let view = self.view {
            let transition = SKTransition.fade(withDuration: 0.5)
            let startScene = StartScene(size: view.bounds.size)
            startScene.viewController = self.viewController
            view.presentScene(startScene, transition: transition)
        }
    }
    
    @objc private func buyNoAdsTapped() {
        let alert = UIAlertController(
            title: "Buy No-Ads",
            message: "Would you like to purchase the No-Ads version for $9.99?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { _ in
            // Handle purchase logic here
            GameData.shared.hasNoAds = true
            print("User purchased No-Ads version.")
            
            // You can also hide ads now:
            self.viewController?.bannerView?.isHidden = true
        }))
        viewController?.present(alert, animated: true)
    }
}

// MARK: - Formatting helper
extension Int {
    // Formats the integer with a decimal separator.
    func formattedWithSeparator() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}




