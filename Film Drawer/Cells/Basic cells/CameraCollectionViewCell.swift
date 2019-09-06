//
//  CameraCollectionViewCell.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 13/08/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

protocol CameraCellDelegate {
    func favouriteButtonPressed(for cell: CameraCollectionViewCell)
    func didTapDeleteButton(cell: CameraCollectionViewCell)
}

class CameraCollectionViewCell: UICollectionViewCell {
    
    var isEditing: Bool = false {
        didSet {
            deleteButton.isHidden = !isEditing
            if isEditing {
                startAnimating()
            } else {
                stopAnimating()
            }
        }
    }

    @IBOutlet weak var cameraPhoto: UIImageView!
    @IBOutlet weak var cameraNameLabel: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var pictureContainer: UIView!
    
    @IBOutlet weak var favouriteButtonHeight: NSLayoutConstraint!
    
    var delegate: CameraCellDelegate?
    
    @IBAction func pressedFavouriteButton(_ sender: UIButton) {
        delegate?.favouriteButtonPressed(for: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        deleteButton.isHidden = !isEditing
        deleteButton.tintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        deleteButton.addTarget(self, action: #selector(deleteButtonTappedFromCell), for: .touchUpInside)
        
        favouriteButtonHeight.constant = 0.17 * cameraPhoto.frame.height
        setupButtonBackground()
        setupShadow()
    }
    
    fileprivate func setupButtonBackground() {
        
        favouriteButton.layer.shadowColor = UIColor.white.cgColor
        favouriteButton.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        favouriteButton.layer.shadowOpacity = 1
        favouriteButton.layer.shadowRadius = 1.0
        favouriteButton.clipsToBounds = false
        
    }
    
    fileprivate func setupShadow() {
        clipsToBounds = false
        pictureContainer.layer.cornerRadius = 3
        pictureContainer.clipsToBounds = false
        pictureContainer.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        pictureContainer.layer.shadowColor = UIColor.black.cgColor
        pictureContainer.layer.shadowRadius = 4
        pictureContainer.layer.shadowOpacity = 0.7
        
        cameraPhoto.layer.cornerRadius = 3
    }
    
    func startAnimating() {
        UIView.animateKeyframes(withDuration: 0.3,
                                delay: TimeInterval.random(in: 0.0...0.3),
                                options: [.calculationModeLinear, .repeat, .autoreverse],
                                animations: {
                                    
                                    let scale: CGFloat = 0.95
                                    
                                    UIView.addKeyframe(withRelativeStartTime: 0,
                                                       relativeDuration: 1/2,
                                                       animations: { [weak self] in
                                                        self?.cameraPhoto.transform = CGAffineTransform(scaleX: scale + 0.01, y: scale + 0.01)
                                                        self?.pictureContainer.transform = CGAffineTransform(scaleX: scale + 0.01, y: scale + 0.01)
                                    })
                                    UIView.addKeyframe(withRelativeStartTime: 1/2,
                                                       relativeDuration: 1/2,
                                                       animations: {[weak self] in
                                                        self?.cameraPhoto.transform = CGAffineTransform(scaleX: scale, y: scale)
                                                        self?.pictureContainer.transform = CGAffineTransform(scaleX: scale, y: scale)
                                    })
        }, completion: nil)
    }
    
    func stopAnimating() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.cameraPhoto.transform = .identity
            self?.pictureContainer.transform = .identity
        }
    }
    
    //Tell the collectionview which cell had its button pressed
    @objc func deleteButtonTappedFromCell() {
        delegate?.didTapDeleteButton(cell: self)
    }
}
