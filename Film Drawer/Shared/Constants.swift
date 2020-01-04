//
//  Constants.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 25/09/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import Foundation
import UIKit

var secondaryLabelColor: UIColor = {
    if #available(iOS 13.0, *) {
        return .secondaryLabel
    } else {
        return #colorLiteral(red: 0.4235294118, green: 0.4235294118, blue: 0.4235294118, alpha: 1)
    }
}()

//var accentColor: UIColor = {
//    if #available(iOS 13.0, *) {
//        return #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
//    } else {
//        return #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
//    }
//}()
