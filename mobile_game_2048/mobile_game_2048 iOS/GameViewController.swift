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

/// Main entry controller that shows a loading scene, authenticates Game Center,
/// and preloads ads before handing off to the game.
@MainActor
final class GameViewController: UIViewController, BannerViewDelegate, FullScreenContentDelegate {

    // MARK: - Ads
    private var bannerView: BannerView!
    private var interstitial: InterstitialAd?
    private var rewardedAd: RewardedAd?

    // MARK: - Scenes
    private var loadingScene: LoadingScene?
    private var isTransitioningScene = false
    private var pendingNavigation: (scene: SKScene, duration: TimeInterval)?

    // MARK: - Lifecycle

    override func loadView() {
        super.loadView()
        view.backgroundColor = .black
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Present loading scene
        if let skView = self.view as? SKView {
            skView.backgroundColor = .black
        }
        let loadingScene = LoadingScene(size: view.bounds.size)
        loadingScene.scaleMode = .aspectFill
        loadingScene.viewController = self
        (self.view as! SKView).presentScene(loadingScene)
        self.loadingScene = loadingScene

        // Tell loading scene there are 3 main tasks:
        // 1) Game Center  2) Ads  3) CloudKit stats
        loadingScene.setTotalTasks(3)

        Task { await runInitialLoading() }
    }

    // MARK: - Initial bootstrap

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

        // --- TASK 3: Load CloudKit stats ---
        do {
            try await CloudKitManager.shared.loadStatsIntoGameData()
            print("✅ Cloud: loaded PlayerStats")
        } catch {
            print("❌ Cloud load failed: \(error)")
        }
    }

    // MARK: - Game Center

    /// Authenticates the local player with safe continuation handling.
    private func authenticateGameCenter() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            var didResume = false
            func resumeOnce() {
                if didResume { return }
                didResume = true
                continuation.resume()
            }

            GKLocalPlayer.local.authenticateHandler = { vc, error in
                if let error = error {
                    print("Game Center authentication failed: \(error.localizedDescription)")
                    resumeOnce()
                    return
                }
                if let vc = vc {
                    // Present login UI; do NOT resume yet. Handler fires again after user action.
                    DispatchQueue.main.async { [weak self] in
                        self?.present(vc, animated: true)
                    }
                    return
                }
                // Authenticated successfully
                print("Game Center authentication successful")
                resumeOnce()
            }
        }
    }

    // MARK: - Ad Loading (batch)

    /// Loads banner, interstitial, and rewarded ads; resumes once when all are done (or on terminal error).
    private func loadAllAds() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            var didResume = false
            func resumeOnce() {
                if didResume { return }
                didResume = true
                continuation.resume()
            }

            // --- Load Banner (immediately add to view so placement is stable) ---
            let viewWidth = view.frame.inset(by: view.safeAreaInsets).width
            let adaptiveSize = adaptiveBannerSize(forWidth: viewWidth)
            let banner = BannerView(adSize: adaptiveSize)
            banner.adUnitID = "ca-app-pub-3940256099942544/2435281174"
            banner.rootViewController = self
            banner.delegate = self
            self.bannerView = banner
            self.addBannerViewToView(banner)
            banner.load(Request())

            // --- Load Interstitial, then Rewarded in the interstitial callback ---
            InterstitialAd.load(
                with: "ca-app-pub-3940256099942544/4411468910",
                request: Request()
            ) { [weak self] ad, error in
                guard let self = self else { return }

                if let error = error {
                    print("Failed to load interstitial: \(error.localizedDescription)")
                    // Depending on your app flow, either treat as terminal or continue to rewarded:
                    // Here we continue to try rewarded, but still resume at the end.
                } else {
                    self.interstitial = ad
                    self.interstitial?.fullScreenContentDelegate = self
                    print("Interstitial ad loaded")
                }

                // --- Now try to load Rewarded (regardless of interstitial result) ---
                RewardedAd.load(
                    with: "ca-app-pub-3940256099942544/1712485313",
                    request: Request()
                ) { [weak self] ad, error in
                    guard let self = self else { return }

                    if let error = error {
                        print("Failed to load rewarded ad: \(error.localizedDescription)")
                    } else {
                        self.rewardedAd = ad
                        self.rewardedAd?.fullScreenContentDelegate = self
                        print("Rewarded ad loaded")
                    }

                    // ✅ Mark ads load flow complete exactly once
                    resumeOnce()
                    
                    Task { await self.loadRewardedAd() }
                    ensureInterstitialReady()
                }
            }
        }
    }

    // MARK: - Individual Ad Helpers (optional use)

    /// Loads a banner and returns true if it (eventually) loaded.
    private func loadBannerAd() async -> Bool {
        // If you prefer a separate awaitable banner load, wire your delegate to call `resumeOnce(true)` on success.
        return await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
            var didResume = false
            func resumeOnce(_ value: Bool) {
                if didResume { return }
                didResume = true
                continuation.resume(returning: value)
            }

            let viewWidth = view.frame.inset(by: view.safeAreaInsets).width
            let adaptiveSize = adaptiveBannerSize(forWidth: viewWidth)
            let banner = BannerView(adSize: adaptiveSize)
            banner.adUnitID = "ca-app-pub-3940256099942544/2435281174"
            banner.rootViewController = self
            banner.delegate = self
            self.bannerView = banner
            self.addBannerViewToView(banner)
            banner.load(Request())

            // If your BannerViewDelegate exposes success/failure callbacks, call resumeOnce(true/false) there.
            // Here we simulate a small delay for demo:
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                resumeOnce(true)
            }
        }
    }

    /// Loads an interstitial using async/await wrapper.
    private func loadInterstitial() async {
        do {
            interstitial = try await InterstitialAd.load(
                with: "ca-app-pub-3940256099942544/4411468910",
                request: Request()
            )
            interstitial?.fullScreenContentDelegate = self
            print("Interstitial loaded and assigned")
        } catch {
            print("Failed to load interstitial ad with error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Interstitial management (Step 2)
    private var isLoadingInterstitial = false   // <-- already added in props

    func ensureInterstitialReady() {
        guard interstitial == nil, !isLoadingInterstitial else { return }
        isLoadingInterstitial = true
        Task { [weak self] in
            guard let self else { return }
            await self.loadInterstitial()
            self.isLoadingInterstitial = false
        }
    }
    
    private func cleanupTransientSubviews() {
        guard let skView = self.view as? SKView else { return }
        for sub in skView.subviews {
            // Keep banner AND the global overlay back button
            if sub === bannerView || sub === GlobalSettings.shared.overlayBackButton {
                continue
            }
            sub.removeFromSuperview()
        }
    }

    /// Loads a rewarded ad using async/await wrapper.
    func loadRewardedAd() async {
        do {
            rewardedAd = try await RewardedAd.load(
                with: "ca-app-pub-3940256099942544/1712485313",
                request: Request()
            )
            rewardedAd?.fullScreenContentDelegate = self
            print("Rewarded ad loaded")
        } catch {
            print("Rewarded ad failed to load with error: \(error.localizedDescription)")
        }
    }

    // MARK: - BannerViewDelegate

    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        addBannerViewToView(bannerView)
    }

    private func addBannerViewToView(_ bannerView: BannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        if bannerView.superview == nil {
            view.addSubview(bannerView)
        }
        view.bringSubviewToFront(bannerView)
        view.addConstraints([
            NSLayoutConstraint(item: bannerView,
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

    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        print(#function, "called")
    }

    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        print(#function, "called")
    }

    func ad(_ ad: FullScreenPresentingAd,
            didFailToPresentFullScreenContentWithError error: Error) {
        print(#function, "error:", error.localizedDescription)
        if ad === interstitial { interstitial = nil }
        if ad === rewardedAd { rewardedAd = nil }
    }

    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print(#function, "called")
    }

    func adWillDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print(#function, "called")
        
        if let pending = pendingNavigation {
            presentScene(pending.scene, transition: nil, transitionDuration: 0)
            pendingNavigation = nil
        }
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print(#function, "called")
        if ad === interstitial { interstitial = nil }
        if ad === rewardedAd { rewardedAd = nil }

        // Immediately top off ads for the next time
        Task { await self.loadRewardedAd() }
        ensureInterstitialReady()
    }


    // MARK: - Showing Ads

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

    // MARK: - Orientation / Status Bar
    
    override var shouldAutorotate: Bool { false }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Helpers
    

    /// Returns the adaptive banner size for the given width.
    func adaptiveBannerSize(forWidth width: CGFloat) -> AdSize {
        // Uses your SDK helper; this preserves your original API surface.
        if let windowScene = view.window?.windowScene {
            _ = windowScene.interfaceOrientation // (available if you need per-orientation logic)
        }
        return currentOrientationAnchoredAdaptiveBanner(width: width)
    }
    
    // MARK: - Ad helpers used by scenes
    func adsEnsureBannerVisibleAndOnTop() {
        guard let banner = bannerView else { return }
        addBannerViewToView(banner)        // keep constraints + on top
        // If you hide ads via IAP:
        // banner.isHidden = GameData.shared.hasNoAds
    }

    func adsSetBannerHidden(_ hidden: Bool) {
        bannerView?.isHidden = hidden
    }

    func adsCurrentBannerHeight() -> CGFloat {
        // If your SDK exposes size via adSize.size.height
        guard let banner = bannerView, !banner.isHidden else { return 0 }
        return banner.adSize.size.height
    }
    
    // MARK: - Navigation with Interstitial (Step 3)
    func navigateWithInterstitialIfReady(makeScene: () -> SKScene,
                                         transitionDuration: TimeInterval) {
        let next = makeScene() // build now

        if let ad = interstitial {
            pendingNavigation = (next, transitionDuration)  // <-- you already added this tuple prop
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                ad.present(from: self)
            }
        } else {
            let t = SKTransition.fade(withDuration: transitionDuration)
            presentScene(next, transition: t, transitionDuration: transitionDuration)
        }
    }

    // MARK: - Scene presentation helper
    func presentScene(_ scene: SKScene,
                      transition: SKTransition? = nil,
                      transitionDuration: TimeInterval? = nil) {
        guard !isTransitioningScene else { return }
        isTransitioningScene = true

        // Wire scenes back to VC
        if let s = scene as? StartScene { s.viewController = self }
        if let s = scene as? StoreScene { s.viewController = self }
        if let s = scene as? OptionsScene { s.viewController = self }

        // Get SKView
        let skView: SKView
        if let v = self.view as? SKView {
            skView = v
        } else {
            let v = SKView(frame: view.bounds)
            self.view = v
            skView = v
        }

        // 🚿 Remove any leftover UIKit subviews except the banner
        cleanupTransientSubviews()

        // Present
        if let t = transition {
            skView.presentScene(scene, transition: t)
        } else {
            skView.presentScene(scene)
        }

        // Release gate after a short debounce (or provided dur)
        let releaseAfter: TimeInterval = transitionDuration ?? (transition != nil ? 0.5 : 0.35)
        DispatchQueue.main.asyncAfter(deadline: .now() + releaseAfter) { [weak self] in
            self?.isTransitioningScene = false
        }
    }
}
