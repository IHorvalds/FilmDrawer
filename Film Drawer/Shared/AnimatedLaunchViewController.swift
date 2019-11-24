//
//  AnimatedLaunchViewController.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 31/08/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit
import Lottie

class AnimatedLaunchViewController: UIViewController {

    @IBOutlet weak var animationView: AnimationView!

    override func viewDidLoad() {
        super.viewDidLoad()

        animationView.animation = Animation.named("35-loader")
        animationView.animationSpeed = 2
        animationView.play(fromFrame: 0, toFrame: Animation.named("35-loader")!.endFrame/2, loopMode: .playOnce) { [weak self] (_) in
            self?.animationView.stop()
            let initVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! UITabBarController

            if  let window = UIApplication.shared.keyWindow,
                let _ = window.rootViewController {

                UIView.transition(with: window,
                                  duration: 0.3,
                                  options: .transitionCrossDissolve,
                                  animations: {
                                    window.rootViewController = initVC
                }, completion: nil)

            } else {
                UIApplication.shared.keyWindow?.rootViewController = initVC
            }
        }
    }

}
