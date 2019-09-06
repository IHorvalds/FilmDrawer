//
//  PhotoCollectionViewCell.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 13/08/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

protocol PhotoCellDelegate {
    func didTapDeleteButton(cell: PhotoCollectionViewCell)
}

class PhotoCollectionViewCell: UICollectionViewCell {
  
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
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
    
    var delegate: PhotoCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        deleteButton.isHidden = !isEditing
        deleteButton.addTarget(self, action: #selector(deleteButtonTappedFromCell), for: .touchUpInside)
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
                                                        self?.image.transform = CGAffineTransform(scaleX: scale + 0.01, y: scale + 0.01)
                                    })
                                    UIView.addKeyframe(withRelativeStartTime: 1/2,
                                                       relativeDuration: 1/2,
                                                       animations: {[weak self] in
                                                        self?.image.transform = CGAffineTransform(scaleX: scale, y: scale)
                                    })
        }, completion: nil)
    }
    
    func stopAnimating() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.image.transform = .identity
        }
    }
    
    //Tell the collectionview which cell had its button pressed
    @objc func deleteButtonTappedFromCell() {
        delegate?.didTapDeleteButton(cell: self)
    }
}
