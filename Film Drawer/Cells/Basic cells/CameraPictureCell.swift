//
//  CameraPictureCell.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 27/08/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

class CameraPictureCell: UITableViewCell {
    
    @IBOutlet weak var cameraPicture: UIImageView!
    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var takeOrChooseNewPicture: RoundedButton!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var galleryButton: RoundedButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        galleryButton.imageView?.contentMode = .scaleAspectFit
    }

}
