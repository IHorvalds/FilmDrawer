//
//  PictureTableViewCell.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 08/09/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

protocol PhotoDetailControllerDelegate {
    var shouldTakeNewPicture: Bool { get set }
    func savePicture(cell: PictureTableViewCell, picture: CGImage)
    func generateTags(cell: PictureTableViewCell, for image: CGImage)
}

class PictureTableViewCell: UITableViewCell { //we're gonna be treating this as a view controller from the AV stuff's perspective and a view from the PhotoDetailVC's perspective

    enum ButtonStatus {
        case Active
        case Chosen
    }
    
    //Outlets
    @IBOutlet weak var previewButton: RoundedButton!
    
    @IBOutlet weak var takePhotoButton: UIButton!
    
    @IBOutlet weak var choosePhotoButton: RoundedButton!
    
    @IBOutlet weak var newImageButton: RoundedButton!
    
    @IBOutlet weak var pictureView: UIImageView!
    
    @IBOutlet weak var previewView: UIView!
    
    let buttonColors = [ButtonStatus.Chosen: UIColor.darkGray,
                        ButtonStatus.Active: UIColor(named: "AccentColor")]
    
    var shouldCaptureNewImage: Bool = true {
        didSet {
            showOrHideImagePreview()
            
            delegate?.shouldTakeNewPicture = shouldCaptureNewImage
        }
    }
    
    //image picker
    let imagePicker = UIImagePickerController()
    
    //delegate
    var delegate: (UIViewController & PhotoDetailControllerDelegate & UIImagePickerControllerDelegate & UINavigationControllerDelegate)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupButtons()
    }
    
}

extension PictureTableViewCell { // Helper functions
    
    fileprivate func showOrHideImagePreview() {
        self.newImageButton.isHidden = self.shouldCaptureNewImage
        self.choosePhotoButton.isHidden = !self.shouldCaptureNewImage
        self.previewButton.isHidden = !self.shouldCaptureNewImage
        self.takePhotoButton.isHidden = !self.shouldCaptureNewImage
        self.pictureView.isHidden = self.shouldCaptureNewImage
        self.previewView.isHidden = !self.shouldCaptureNewImage
    }
    
    fileprivate func setupButtons() {
        takePhotoButton.addTarget(self, action: #selector(animateButtonTap), for: .touchUpInside)
        newImageButton.addTarget(self, action: #selector(newImage(sender:)), for: .touchUpInside)
    }
    
    @objc fileprivate func newImage(sender: RoundedButton) {
        shouldCaptureNewImage = true
        showOrHideImagePreview()
    }
    
    @objc func animateButtonTap() {
        UIView.animateKeyframes(withDuration: 0.2,
                                delay: 0,
                                options: [.calculationModeLinear],
                                animations: {
                                    UIView.addKeyframe(withRelativeStartTime: 0.0,
                                                       relativeDuration: 1/2) { [weak self] in
                                                        guard let self = self else { return }
                                                        self.takePhotoButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                                    }
                                    
                                    UIView.addKeyframe(withRelativeStartTime: 1/2,
                                                       relativeDuration: 1/2) { [weak self] in
                                                        guard let self = self else { return }
                                                        self.takePhotoButton.transform = .identity
                                    }
        }, completion: nil)
    }
}
