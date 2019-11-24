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
    
    public var isEditing: Bool = false {
        didSet {
            deleteButton.isHidden = !isEditing
            if isEditing {
                startAnimating()
            } else {
                stopAnimating()
            }
        }
    }

    @IBOutlet public weak var cameraPhoto: UIImageView!
    @IBOutlet public weak var cameraNameLabel: UILabel!
    @IBOutlet public weak var favouriteButton: UIButton!
    @IBOutlet public weak var deleteButton: UIButton!
    
    @IBOutlet weak var favouriteButtonHeight: NSLayoutConstraint!
    
    var delegate: CameraCellDelegate?
    
    @IBAction func pressedFavouriteButton(_ sender: UIButton) {
        delegate?.favouriteButtonPressed(for: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        deleteButton.isHidden = !isEditing
        deleteButton.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        deleteButton.addTarget(self, action: #selector(deleteButtonTappedFromCell), for: .touchUpInside)
        
        favouriteButtonHeight.constant = 0.17 * cameraPhoto.frame.height
        setupButtonBackground(favouriteButton)
        setupButtonBackground(deleteButton)
        setupShadow()
    }
    
    fileprivate func setupButtonBackground(_ button: UIButton) {
        
        button.layer.shadowColor = UIColor.white.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 1.0
        button.clipsToBounds = false
        
    }
    
    fileprivate func setupShadow() {
//        clipsToBounds = false
//        cameraPhoto.layer.masksToBounds = false
        cameraPhoto.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        cameraPhoto.layer.shadowColor = UIColor.black.cgColor
        cameraPhoto.layer.shadowRadius = 4
        cameraPhoto.layer.shadowOpacity = 0.7
    }
    
    fileprivate func startAnimating() {
        UIView.animateKeyframes(withDuration: 0.3,
                                delay: TimeInterval.random(in: 0.0...0.3),
                                options: [.calculationModeLinear, .repeat, .autoreverse],
                                animations: {
                                    
                                    let scale: CGFloat = 0.95
                                    
                                    UIView.addKeyframe(withRelativeStartTime: 0,
                                                       relativeDuration: 1/2,
                                                       animations: { [weak self] in
                                                        self?.cameraPhoto.transform = CGAffineTransform(scaleX: scale + 0.01, y: scale + 0.01)
                                    })
                                    UIView.addKeyframe(withRelativeStartTime: 1/2,
                                                       relativeDuration: 1/2,
                                                       animations: {[weak self] in
                                                        self?.cameraPhoto.transform = CGAffineTransform(scaleX: scale, y: scale)
                                    })
        }, completion: nil)
    }
    
    fileprivate func stopAnimating() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.cameraPhoto.transform = .identity
        }
    }
    
    //Tell the collectionview which cell had its button pressed
    @objc private func deleteButtonTappedFromCell() {
        delegate?.didTapDeleteButton(cell: self)
    }
}
