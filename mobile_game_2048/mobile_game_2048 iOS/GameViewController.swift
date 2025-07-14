//
// GameViewController.swift
// mobile_game_2048 iOS
//
// Created by Ty Runner on 3/12/25.
//

import UIKit
import SpriteKit
import GameplayKit
import GameKit
import GoogleMobileAds

/**
 The main view controller for the game, responsible for handling game center authentication,
 loading and displaying ads, and presenting the game scenes.
 */
class GameViewController: UIViewController, BannerViewDelegate, FullScreenContentDelegate {
    
    // MARK: - Ad Properties
    
    /// The banner view to display ads at the bottom of the screen.
    var bannerView: BannerView!
    
    /// The interstitial ad to display between game scenes.
    var interstitial: InterstitialAd?
    
    /// The rewarded ad to display when the user wants to earn a reward.
    private var rewardedAd: RewardedAd?
    
    /// The loading scene to display while the game is initializing.
    private var loadingScene: LoadingScene?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Present the loading scene first to display a progress bar.
        let skView = self.view as! SKView
        let loadingScene = LoadingScene(size: view.bounds.size)
        loadingScene.scaleMode = .aspectFill
        skView.presentScene(loadingScene)
        self.loadingScene = loadingScene
        
        // Run the initial loading tasks asynchronously.
        Task {
            await runInitialLoading()
        }
    }
    
    // MARK: - Initial Loading
    
    /**
     Runs the initial loading tasks, including:
     1. Authenticating Game Center
     2. Loading the banner ad
     3. Loading the interstitial ad
     4. Loading the rewarded ad
     */
    private func runInitialLoading() async {
        let totalTasks = 4
        var completedTasks = 0
        
        // Updates the progress bar in the loading scene.
        func updateProgress() {
            completedTasks += 1
            DispatchQueue.main.async {
                self.loadingScene?.progress = CGFloat(completedTasks) / CGFloat(totalTasks)
            }
        }
        
        // 1. Authenticate Game Center
        await withCheckedContinuation { continuation in
            let localPlayer = GKLocalPlayer.local
            localPlayer.authenticateHandler = { vc, error in
                DispatchQueue.main.async {
                    if let vc = vc {
                        // Present the Game Center authentication view controller.
                        self.present(vc, animated: true)
                    } else if localPlayer.isAuthenticated {
                        print("✅ Game Center Authenticated as \(localPlayer.alias)")
                    } else {
                        print("❌ Game Center Not Authenticated")
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                    updateProgress()
                    continuation.resume()
                }
            }
        }
        
        // 2. Load Banner Ad
        let bannerLoaded = await loadBannerAd()
        print("Banner loaded: \(bannerLoaded)")
        updateProgress()
        
        // 3 & 4 Load Interstitial and Rewarded ads concurrently
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadInterstitial() }
            group.addTask { await self.loadRewardedAd() }
        }
        updateProgress()
        
        // All done, present the StartScene.
        DispatchQueue.main.async {
            self.presentStartScene()
        }
    }
    
    // MARK: - Ad Loading
    
    /**
     Loads the banner ad and adds it to the view hierarchy.
     - Returns: A boolean indicating whether the banner ad was loaded successfully.
     */
    private func loadBannerAd() async -> Bool {
        let viewWidth = view.frame.inset(by: view.safeAreaInsets).width
        let adaptiveSize = adaptiveBannerSize(forWidth: viewWidth)
        bannerView = BannerView(adSize: adaptiveSize)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2435281174"
        bannerView.rootViewController = self
        bannerView.delegate = self
        
        // Add banner to view hierarchy
        addBannerViewToView(bannerView)
        
        // Simulate async loading with completion handler + delegate.
        return await withCheckedContinuation { continuation in
            bannerView.load(Request())
            // In real case, delegate method bannerViewDidReceiveAd will be called when loaded.
            // To keep it simple here, simulate delay:
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                continuation.resume(returning: true)
            }
        }
    }
    
    /**
     Loads the interstitial ad.
     */
    private func loadInterstitial() async {
        do {
            interstitial = try await InterstitialAd.load(
                with: "ca-app-pub-3940256099942544/4411468910", request: Request())
            interstitial?.fullScreenContentDelegate = self
            print("Interstitial loaded and assigned")
        } catch {
            print("Failed to load interstitial ad with error: \(error.localizedDescription)")
        }
    }
    
    /**
     Loads the rewarded ad.
     */
    func loadRewardedAd() async {
        do {
            rewardedAd = try await RewardedAd.load(
                with: "ca-app-pub-3940256099942544/1712485313", request: Request())
            rewardedAd?.fullScreenContentDelegate = self
            print("Rewarded ad loaded")
        } catch {
            print("Rewarded ad failed to load with error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Scene Presentation
    
    /**
     Presents the StartScene.
     */
    private func presentStartScene() {
        let skView = self.view as! SKView
        let startScene = StartScene(size: view.bounds.size)
        startScene.viewController = self
        startScene.scaleMode = .aspectFill
        skView.presentScene(startScene, transition: SKTransition.fade(withDuration: 0.5))
    }
    
    // MARK: - BannerViewDelegate
    
    /**
     Called when the banner ad is received.
     - Parameter bannerView: The banner view that received the ad.
     */
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        addBannerViewToView(bannerView)
    }
    
    /**
     Adds the banner view to the view hierarchy.
     - Parameter bannerView: The banner view to add.
     */
    func addBannerViewToView(_ bannerView: BannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        if bannerView.superview == nil {
            view.addSubview(bannerView)
        }
        view.bringSubviewToFront(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: view.safeAreaLayoutGuide,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    // MARK: - FullScreenContentDelegate
    
    /**
     Called when the ad is displayed.
     - Parameter ad: The ad that was displayed.
     */
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        print("\(#function) called")
    }
    
    /**
     Called when the ad is clicked.
     - Parameter ad: The ad that was clicked.
     */
    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        print("\(#function) called")
    }
    
    /**
     Called when the ad fails to present.
     - Parameter ad: The ad that failed to present.
     - Parameter error: The error that occurred.
     */
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("\(#function) called with error: \(error.localizedDescription)")
        if ad === interstitial {
            interstitial = nil
        }
        if ad === rewardedAd {
            rewardedAd = nil
        }
    }
    
    /**
     Called when the ad is about to be presented.
     - Parameter ad: The ad that is about to be presented.
     */
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("\(#function) called")
    }
    
    /**
     Called when the ad is about to be dismissed.
     - Parameter ad: The ad that is about to be dismissed.
     */
    func adWillDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("\(#function) called")
    }
    
    /**
     Called when the ad is dismissed.
     - Parameter ad: The ad that was dismissed.
     */
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("\(#function) called")
        if ad === interstitial {
            interstitial = nil
        }
        if ad === rewardedAd {
            rewardedAd = nil
        }
        Task {
            await self.loadRewardedAd()
            await self.loadInterstitial()
        }
    }
    
    // MARK: - Rewarded Ad
    
    /**
     Shows the rewarded ad.
     - Parameter completion: A closure to call when the ad is dismissed.
     */
    func showRewardedAd(completion: @escaping () -> Void) {
        if let ad = rewardedAd {
            ad.present(from: self) {
                let reward = ad.adReward
                print("User earned reward: \(reward.amount) \(reward.type)")
                completion()
            }
        } else {
            print("Rewarded ad wasn't ready")
        }
    }
    
    // MARK: - Interstitial
    
    /**
     Shows the interstitial ad if it is available.
     */
    func showInterstitialAdIfAvailable() {
        if let interstitial = interstitial {
            DispatchQueue.main.async {
                interstitial.present(from: self)
            }
        } else {
            print("Interstitial ad wasn't ready")
        }
    }
    
    // MARK: - Orientation & Status Bar
    
    /**
     Returns the supported interface orientations.
     */
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    /**
     Returns whether the status bar should be hidden.
     */
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Helper
    
    /**
     Returns the adaptive banner size for the given width.
     - Parameter width: The width of the banner.
     */
    func adaptiveBannerSize(forWidth width: CGFloat) -> AdSize {
        // Use the SDK's function directly, no naming conflict here
        guard let windowScene = view.window?.windowScene else {
            return currentOrientationAnchoredAdaptiveBanner(width: width)
        }
        // You can use the interfaceOrientation if you want to do orientation-specific logic, but
        // the SDK's function automatically adapts for the current orientation.
        _ = windowScene.interfaceOrientation
        return currentOrientationAnchoredAdaptiveBanner(width: width)
    }
}
