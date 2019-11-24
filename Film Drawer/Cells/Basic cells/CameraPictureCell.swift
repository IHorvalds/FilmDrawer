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
        captureButton.addTarget(self, action: #selector(animateButtonTap), for: .touchUpInside)
    }
    
    @objc func animateButtonTap() {
        UIView.animateKeyframes(withDuration: 0.2,
                                delay: 0,
                                options: [.calculationModeLinear],
                                animations: {
                                    UIView.addKeyframe(withRelativeStartTime: 0.0,
                                                       relativeDuration: 1/2) { [weak self] in
                                                        guard let self = self else { return }
                                                        self.captureButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                                    }
                                    
                                    UIView.addKeyframe(withRelativeStartTime: 1/2,
                                                       relativeDuration: 1/2) { [weak self] in
                                                        guard let self = self else { return }
                                                        self.captureButton.transform = .identity
                                    }
        }, completion: nil)
    }

}
