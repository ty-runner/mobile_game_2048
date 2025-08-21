import Foundation
import SpriteKit
import UIKit
import AVFoundation
import StoreKit

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
    
    // ✅ Product IDs must match App Store Connect
    private let goldProductIDs = [
        "10kcoin_Purchase",
        "20k_Coins",
        "5kcoin_purchase",
        "50k_Coins"
    ]
    
    private let noAdsProductID = "NoAdsPurchase"


    private var storeProducts: [Product] = []  // ✅ StoreKit products cache

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

        // Load CloudKit stats, then build UI
        Task { [weak self] in
            do { try await CloudKitManager.shared.loadStatsIntoGameData() } catch { print(error) }

            await MainActor.run { [weak self] in
                guard let self, let view = self.view, let vc = self.viewController else { return }

                self.setupScrollView(in: view)

                // ✅ Use the global overlay back button (safe-area aware, consistent)
                GlobalSettings.shared.showOverlayBackButton(in: vc, title: "Back") { [weak self] in
                    guard let self, let vc = self.viewController, let skView = self.view else { return }
                    // Clean up Store-owned UIKit before leaving
                    self.scrollView?.removeFromSuperview()

                    let start = StartScene(size: skView.bounds.size)
                    start.viewController = vc
                    start.scaleMode = self.scaleMode
                    let t = SKTransition.fade(withDuration: 0.5)
                    vc.presentScene(start, transition: t, transitionDuration: 0.5)
                }

                self.updateUnlockButtons()
                vc.adsEnsureBannerVisibleAndOnTop()
            }
        }

        // Ensure the banner view is visible and on top.
        viewController?.adsEnsureBannerVisibleAndOnTop()
        
        
        // ✅ Load StoreKit products
        Task {
            await loadStoreProducts()
        }
    }

    // Called when the scene is about to be removed.
    override func willMove(from view: SKView) {
        // Remove the scroll view and back button from the view.
        scrollView?.removeFromSuperview()
        scrollView = nil
    }
    
    // MARK: - StoreKit Helpers
    @MainActor
    private func loadStoreProducts() async {
        let allIDs = goldProductIDs + [noAdsProductID]
        do {
            storeProducts = try await Product.products(for: allIDs)
            if storeProducts.isEmpty {
                print("❌ No products loaded. Check App Store Connect IDs and sandbox account.")
            } else {
                print("✅ Loaded products: \(storeProducts.map { $0.id })")
            }
        } catch {
            print("❌ Failed to load products: \(error)")
        }
    }

    @objc private func buyNoAdsTapped() {
        guard let product = storeProducts.first(where: { $0.id == noAdsProductID }) else {
            print("❌ No Ads product not loaded yet. Retrying in 2 seconds...")
            // Retry after short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.buyNoAdsTapped()
            }
            return
        }

        Task {
            await purchase(product: product, noAds: true)
        }
    }

    @objc private func buyButtonTapped(_ sender: UIButton) {
        let index = sender.tag - 1
        guard index >= 0 && index < goldProductIDs.count else { return }
        
        let productID = goldProductIDs[index]
        
        guard let product = storeProducts.first(where: { $0.id == productID }) else {
            print("❌ Coin product \(productID) not loaded yet. Retrying in 2 seconds...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.buyButtonTapped(sender)
            }
            return
        }

        Task {
            await purchase(product: product, coinsToAdd: goldValues[index])
        }
    }

    // MARK: - Purchase Handler
    @MainActor
    private func purchase(product: Product, coinsToAdd: Int? = nil, noAds: Bool = false) async {
        do {
            print("💰 Attempting purchase: \(product.id)")
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    print("✅ Transaction verified: \(transaction.productID)")
                    
                    if let coins = coinsToAdd {
                        GameData.shared.coins += coins
                        if let coinRegion = self.childNode(withName: "CoinRegion") as? CoinRegion {
                            coinRegion.updateCoins(to: GameData.shared.coins)
                        }
                        // NEW: save to CloudKit
                        Task { await CloudKitManager.shared.saveAllFromGameData() }
                    }

                    if noAds {
                        GameData.shared.hasNoAds = true
                        self.viewController?.adsSetBannerHidden(true)
                        // Optional: Task { await CloudKitManager.shared.setNoAds(true) }
                    }

                    await transaction.finish()
                    print("🎉 Purchase complete: \(transaction.productID)")

                } else {
                    print("❌ Transaction unverified for \(product.id)")
                }

            case .userCancelled:
                print("⚠️ User cancelled purchase: \(product.id)")
            default:
                print("⚠️ Purchase result: \(result)")
            }
        } catch {
            print("❌ Purchase failed: \(error)")
        }
    }
    // ✅ Backend verification
    private func verifyWithBackend(transactionID: UInt64) async -> Bool {
        guard let url = URL(string: "http://localhost:3000/verify") else { return false }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["transactionId": transactionID]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return json?["valid"] as? Bool ?? false
        } catch {
            print("❌ Backend verification error: \(error)")
            return false
        }
    }

    // ✅ Restore purchases
    @MainActor
    func restorePurchases() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                print("🔄 Restored: \(transaction.productID)")
                if goldProductIDs.contains(transaction.productID) {
                    // Restore coins? Usually not done for consumables
                } else if transaction.productID == noAdsProductID {
                    GameData.shared.hasNoAds = true
                    self.viewController?.adsSetBannerHidden(true)
                }
            }
        }
        
        print("✅ Loaded products: \(storeProducts.map { $0.id })")

    }
    
    


    // Sets up the scroll view and its content.
    private func setupScrollView(in view: SKView) {
        // Calculate the height of the coin region.
        let coinRegionHeight: CGFloat = view.frame.size.height * 0.155
        
        let bannerHeight = viewController?.adsCurrentBannerHeight() ?? 60
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
        
        // Keep banner above scroll content and reserve space so it isn't covered
        viewController?.adsEnsureBannerVisibleAndOnTop()

        let inset = viewController?.adsCurrentBannerHeight() ?? 60
        // Content area shouldn’t be obscured by the banner
        scrollView.contentInset.bottom = inset

        // Indicators: prefer modern API, fall back for iOS 12 and earlier
        if #available(iOS 13.0, *) {
            scrollView.verticalScrollIndicatorInsets.bottom = inset
        } else {
            scrollView.scrollIndicatorInsets.bottom = inset
        }
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
        containerView.addSubview(unlockButton)
        
        // Immediately configure the correct state
        configureUnlockButton(unlockButton, index: index)
        
        

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
    
    private func configureUnlockButton(_ button: UIButton, index: Int) {
        // Reset any previous targets/state
        button.removeTarget(nil, action: nil, for: .allEvents)

        // Helper to clear glow for non-selected
        func clearGlow(_ button: UIButton) {
            button.layer.borderWidth = 0
            button.layer.borderColor = nil
            button.layer.shadowOpacity = 0
        }

        // ✅ DEFAULT THEME (index 0) is always unlocked
        if index == 0 {
            let isSelected = GameData.shared.selectedThemeIndex == 0
            if isSelected {
                button.setTitle("ACTIVE", for: .normal)
                button.backgroundColor = .gray
                button.isEnabled = false

                // ✨ Add glow effect
                button.layer.borderWidth = 3
                button.layer.borderColor = UIColor.white.cgColor
                button.layer.shadowColor = UIColor.white.cgColor
                button.layer.shadowRadius = 10
                button.layer.shadowOpacity = 1
                button.layer.shadowOffset = .zero
            } else {
                button.setTitle("SELECT", for: .normal)
                button.backgroundColor = .gray
                button.isEnabled = true
                button.addTarget(self, action: #selector(selectBackgroundTapped(_:)), for: .touchUpInside)
                clearGlow(button)
            }
            return
        }

        // For all other themes, use unlock state + selection
        let isUnlocked = GameData.shared.unlockedFeatures.contains(index)
        let isSelected = GameData.shared.selectedThemeIndex == index

        if isSelected {
            button.setTitle("ACTIVE", for: .normal)
            button.backgroundColor = .gray
            button.isEnabled = false

            // ✨ Add glow effect
            button.layer.borderWidth = 3
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.shadowColor = UIColor.white.cgColor
            button.layer.shadowRadius = 10
            button.layer.shadowOpacity = 1
            button.layer.shadowOffset = .zero
        } else if isUnlocked {
            button.setTitle("SELECT", for: .normal)
            button.backgroundColor = .gray
            button.isEnabled = true
            button.addTarget(self, action: #selector(selectBackgroundTapped(_:)), for: .touchUpInside)
            clearGlow(button)
        } else {
            button.setTitle("LOCKED", for: .normal)
            button.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
            button.isEnabled = false
            button.addTarget(self, action: #selector(unlockButtonTapped(_:)), for: .touchUpInside)
            button.setTitle("UNLOCK", for: .normal)
            button.isEnabled = true
            clearGlow(button)
        }
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
            
            // ✅ Persist to CloudKit after local updates
            Task {
                await CloudKitManager.shared.addUnlocked(index: index)
                await CloudKitManager.shared.saveAllFromGameData()
            }
            
            // Set as selected immediately
            GameData.shared.selectedThemeIndex = index
            // unlockButtonTapped
            ThemeManager.selectTheme(named: themeKey(for: index))
            updateUnlockButtons() // refresh all buttons
        
        } else {
            // Display an alert if the player doesn't have enough coins.
            let alert = UIAlertController(title: "Not Enough Coins", message: "You need \(cost - GameData.shared.coins) more coins to unlock this.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            viewController?.present(alert, animated: true)
        }
    }
    
    private func themeKey(for index: Int) -> String {
        switch index {
        case 0: return "classic"
        case 1: return "abstract"
        case 2: return "retro"
        case 3: return "oceanic"
        case 4: return "vaporwave"
        default: return "classic"
        }
    }
    
    func updateUnlockButtons() {
        func walk(_ view: UIView) {
            for v in view.subviews {
                if let button = v as? UIButton, button.tag >= 1000 {
                    let index = button.tag - 1000
                    configureUnlockButton(button, index: index)
                }
                walk(v) // keep walking down the tree
            }
        }
        walk(scrollView)
    }

    @objc private func selectBackgroundTapped(_ sender: UIButton) {
        let index = sender.tag - 1000
        GameData.shared.selectedThemeIndex = index
        // selectBackgroundTapped
        ThemeManager.selectTheme(named: themeKey(for: index))
        updateUnlockButtons() // refresh the buttons
        Task {
            await CloudKitManager.shared.saveAllFromGameData()
        }
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




