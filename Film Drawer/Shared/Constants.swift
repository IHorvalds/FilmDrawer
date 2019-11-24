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
