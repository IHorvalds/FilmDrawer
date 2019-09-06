//
//  ArchiveCollectionViewCell.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 13/08/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

@IBDesignable
class ArchiveCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var archiveIconBackground: UIView!
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var fileDate: UILabel!
    
    override func awakeFromNib() {
        layer.cornerRadius = 5
    }
    
}
