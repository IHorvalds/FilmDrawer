//
//  HeroViewController.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 23/11/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

class HeroViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let initVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! UITabBarController
        UIApplication.shared.keyWindow?.rootViewController = initVC
    }

}
