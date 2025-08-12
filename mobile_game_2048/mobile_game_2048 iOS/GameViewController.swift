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

class GameViewController: UIViewController, BannerViewDelegate, FullScreenContentDelegate {
    
    var bannerView: BannerView!
    var interstitial: InterstitialAd?
    private var rewardedAd: RewardedAd?
    private var loadingScene: LoadingScene?
    
    override func loadView() {
            super.loadView()
            view.backgroundColor = .black
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Present loading scene
        if let skView = self.view as? SKView {
            skView.backgroundColor = .black  // ✅ instant black background
        }
        let loadingScene = LoadingScene(size: view.bounds.size)
        loadingScene.scaleMode = .aspectFill
        loadingScene.viewController = self // ✅ Pass self to LoadingScene
        (self.view as! SKView).presentScene(loadingScene)
        self.loadingScene = loadingScene
        
        // Tell loading scene there are 2 main tasks: Game Center + Ads
        loadingScene.setTotalTasks(2)
        
        Task {
            await runInitialLoading()
        }
    }
    
    private func runInitialLoading() async {
        // --- TASK 1: Authenticate Game Center ---
        await authenticateGameCenter()
        DispatchQueue.main.async {
            self.loadingScene?.gameCenterLoaded = true
            self.loadingScene?.markTaskComplete()
        }
        
        // --- TASK 2: Load Ads ---
        await loadAllAds()
        DispatchQueue.main.async {
            self.loadingScene?.adsLoaded = true
            self.loadingScene?.markTaskComplete()
        }
    }
    
    // MARK: - Game Center Authentication
    private func authenticateGameCenter() async {
        await withCheckedContinuation { continuation in
            GKLocalPlayer.local.authenticateHandler = { vc, error in
                if let vc = vc {
                    self.present(vc, animated: true)
                } else if error != nil {
                    print("Game Center authentication failed: \(error!.localizedDescription)")
                } else {
                    print("Game Center authentication successful")
                }
                continuation.resume()
            }
        }
    }
    
    private func loadAllAds() async {
        await withCheckedContinuation { continuation in
            
            // --- Load Banner ---
            bannerView = BannerView(adSize: AdSizeBanner)
            bannerView.adUnitID = "ca-app-pub-3940256099942544/2435281174"
            bannerView.rootViewController = self
            bannerView.delegate = self
            bannerView.load(Request())

            // --- Load Interstitial ---
            InterstitialAd.load(
                with: "ca-app-pub-3940256099942544/4411468910",
                request: Request()
            ) { ad, error in
                
                if let error = error {
                    print("Failed to load interstitial: \(error.localizedDescription)")
                    // ❌ Don't mark ads loaded yet if you need interstitial before start
                    continuation.resume()
                    return
                }
                
                self.interstitial = ad
                self.interstitial?.fullScreenContentDelegate = self
                print("Interstitial ad loaded")
                
                // --- Load Rewarded ---
                RewardedAd.load(
                    with: "ca-app-pub-3940256099942544/1712485313",
                    request: Request()
                ) { ad, error in
                    
                    if let error = error {
                        print("Failed to load rewarded ad: \(error.localizedDescription)")
                    } else {
                        self.rewardedAd = ad
                        self.rewardedAd?.fullScreenContentDelegate = self
                        print("Rewarded ad loaded")
                    }
                    
                    // ✅ Now mark ads as fully loaded
                    continuation.resume()
                }
            }
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
        guard let interstitial = interstitial else {
            print("Interstitial ad wasn't ready, loading now...")
            Task { await self.loadInterstitial() }
            return
        }
        
        DispatchQueue.main.async {
            interstitial.present(from: self)
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
