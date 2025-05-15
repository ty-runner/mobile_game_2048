//
//  GameViewController.swift
//  mobile_game_2048 iOS
//
//  Created by Ty Runner on 3/12/25.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds

class GameViewController: UIViewController, BannerViewDelegate, FullScreenContentDelegate {
    
    var bannerView: BannerView!
    
    var interstitial: InterstitialAd?
    
    private var pendingStartScene: SKScene?
    
    private var rewardedAd: RewardedAd?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let startscene = StartScene(size: view.bounds.size)
        startscene.viewController = self
        
        // Present the scene
        let skView = self.view as! SKView
        
        skView.presentScene(startscene)
        
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        let viewWidth = view.frame.inset(by: view.safeAreaInsets).width
        
        // Here the current interface orientation is used. Use
        // landscapeAnchoredAdaptiveBanner or
        // portraitAnchoredAdaptiveBanner if you prefer to load an ad of a
        // particular orientation,
        let adaptiveSize = currentOrientationAnchoredAdaptiveBanner(width: viewWidth)
        bannerView = BannerView(adSize: adaptiveSize)
        
        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2435281174"
        bannerView.rootViewController = self
        bannerView.load(Request())
        bannerView.delegate = self
        
        Task {
            await self.loadInterstitial()
        }
        
        
    }
    
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
      // Add banner to view and add constraints.
      addBannerViewToView(bannerView)
    }

func addBannerViewToView(_ bannerView: BannerView) {
    bannerView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(bannerView)
    // This example doesn't give width or height constraints, as the provided
    // ad size gives the banner an intrinsic content size to size the view.
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
    
    //Rewarded Ad Test Ad unit and load function
    func loadRewardedAd() async {
        do {
          rewardedAd = try await RewardedAd.load(
            with: "ca-app-pub-3940256099942544/1712485313", request: Request())
            rewardedAd?.fullScreenContentDelegate = self
        } catch {
          print("Rewarded ad failed to load with error: \(error.localizedDescription)")
        }
      }
    
    // Function to present the rewarded ad
    func showRewardedAd(completion: @escaping () -> Void) {
        if let ad = rewardedAd {
            ad.present(from: self) {
                let reward = ad.adReward
                print("User earned reward: \(reward.amount) \(reward.type)")
                
                completion()
                // Handle reward logic here, like giving user in-game currency
            }
        } else {
            print("Rewarded ad wasn't ready")
        }
    }

    //Main function to load Interstitial ads
    func loadInterstitial() async {
      do {
        interstitial = try await InterstitialAd.load(
          with: "ca-app-pub-3940256099942544/4411468910", request: Request()) //replace this with actual Ad tag
          interstitial?.fullScreenContentDelegate = self
          print("Interstitial loaded and assigned")
      } catch {
        print("Failed to load interstitial ad with error: \(error.localizedDescription)")
      }
    }
    
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
      print("\(#function) called")
    }

    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
      print("\(#function) called")
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
      print("\(#function) called with error: \(error.localizedDescription)")
      // Clear the interstitial ad.
      interstitial = nil
    }

    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
      print("\(#function) called")
    }

    func adWillDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
      print("\(#function) called")
    }
    
    func showInterstitialAdIfAvailable() {
        if let interstitial = interstitial {
            print("Showing interstitial now")
            DispatchQueue.main.async {
                interstitial.present(from: self)
            }
        } else {
            print("Interstitial ad wasn't ready")
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
      print("\(#function) called")
      // Clear the interstitial ad.
      interstitial = nil
        rewardedAd = nil
        
        //Reloads Ad after being dismissed
        Task {
            await self.loadRewardedAd()
            await self.loadInterstitial()
        }
    }
    
    


    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
