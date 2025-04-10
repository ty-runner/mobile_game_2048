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

class GameViewController: UIViewController, BannerViewDelegate {
    
    var bannerView: BannerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let startscene = StartScene(size: view.bounds.size)
        
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
