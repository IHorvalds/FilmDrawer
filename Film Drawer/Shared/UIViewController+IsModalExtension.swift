//
//  UIViewController+IsModalExtension.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 01/09/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func isModal() -> Bool {
        return self.presentingViewController?.presentedViewController == self
            || (self.navigationController != nil && self.navigationController?.presentingViewController?.presentedViewController == self.navigationController)
            || self.tabBarController?.presentingViewController is UITabBarController
    }
}
