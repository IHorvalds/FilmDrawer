//
//  LaunchScreenViewController.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 20/11/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit
import Hero

class LaunchScreenViewController: UIViewController {

    @IBOutlet weak var octopuiImage: UIImageView!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Thread.sleep(forTimeInterval: 1)
        performSegue(withIdentifier: "splashsegue", sender: nil)
    }
}
