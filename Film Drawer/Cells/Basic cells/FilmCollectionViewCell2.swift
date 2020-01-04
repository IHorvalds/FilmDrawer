//
//  FilmCollectionViewCell2.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 13/11/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

protocol FilmCellDelegate2: class {
    func didTapDeleteButton(cell: FilmCollectionViewCell2)
}

class FilmCollectionViewCell2: UICollectionViewCell {
    
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
    
    public weak var delegate: FilmCellDelegate2?
    @IBOutlet private weak var deleteButton: UIButton!
    
    @IBOutlet public weak var topImg: UIImageView!
    @IBOutlet public weak var backImg: UIImageView!
    
    @IBOutlet private weak var filmName: UILabel!
    @IBOutlet private weak var lastShotLabel: UILabel!
    @IBOutlet private weak var frameCountLabel: UILabel!
//    @IBOutlet private weak var backgroundBlurView: UIVisualEffectView!
    @IBOutlet private weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupShadows()
        
        deleteButton.isHidden = !isEditing
        deleteButton.tintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        deleteButton.addTarget(self, action: #selector(deleteButtonTappedFromCell), for: .touchUpInside)
        
    }
    
    public func setFilmNameLabel(film name: String) {
        filmName.text = name
    }
    
    public func setLastShotLabel(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        lastShotLabel.text = "Last shot on: \(dateFormatter.string(from: date))"
    }
    
    public func setFrameCountLabel(currentFrameCount: Int, maxFrameCount: Int) {
        frameCountLabel.text = "Frames: \(currentFrameCount)/\(maxFrameCount)"
    }

    //Tell the collectionview which cell had its button pressed
    @objc private func deleteButtonTappedFromCell() {
        delegate?.didTapDeleteButton(cell: self)
    }
    
    fileprivate func setupShadows() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3.0)
        self.layer.shadowOpacity = 0.6
        self.layer.shadowRadius = 4
        
        topImg.clipsToBounds = false
        topImg.layer.shadowColor = UIColor.black.cgColor
        topImg.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        topImg.layer.shadowOpacity = 1
        topImg.layer.shadowRadius = 2
        
        backImg.clipsToBounds = false
        backImg.layer.shadowColor = UIColor.black.cgColor
        backImg.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        backImg.layer.shadowOpacity = 1
        backImg.layer.shadowRadius = 2
        
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 10.0
        
    }
    
    public func startAnimating() {
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: [.repeat, .autoreverse],
                       animations: { [weak self] in
                        guard let self = self else { return }

                        self.containerView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: nil)
    }
    
    public func stopAnimating() {
        self.layer.removeAllAnimations()

        UIView.animate(withDuration: 0.2,
                       animations: { [weak self] in
                        guard let self = self else { return }

                        self.containerView.transform = .identity
        }, completion: nil)
    }
}
