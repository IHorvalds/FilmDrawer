//
//  FilmCollectionViewCell.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 13/08/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

protocol FilmCellDelegate {
    func didTapDeleteButton(cell: FilmCollectionViewCell)
}

class FilmCollectionViewCell: UICollectionViewCell {
    
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
    
    var delegate: FilmCellDelegate?

    @IBOutlet weak var background: UIView!
    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var midImg: UIImageView!
    @IBOutlet weak var topImg: UIImageView!
    @IBOutlet weak var filmNameLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var topToMidConstraint: NSLayoutConstraint!
    @IBOutlet weak var midToBackConstraint: NSLayoutConstraint!
    
    fileprivate func setupConstraints() {
        let heightPercentage: CGFloat = 0.11
        
        print(topImg.frame.height * 0.26)
        
        topToMidConstraint.constant = topImg.frame.height * heightPercentage

        midToBackConstraint.constant = topImg.frame.height * 0.23
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        setupConstraints()
        
        deleteButton.isHidden = !isEditing
        deleteButton.tintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        deleteButton.addTarget(self, action: #selector(deleteButtonTappedFromCell), for: .touchUpInside)
        self.clipsToBounds = false
        
        setupShadow(for: topImg)
        setupShadow(for: midImg)
        setupShadow(for: backImg)
    }
    
    public func setupShadow(for imageView: UIImageView) {
        //shadow:
        //black, 50% alpha, X: 0, Y: 2, radius: 4
        if imageView == topImg {
            background.layer.cornerRadius = 4
            background.clipsToBounds = false
            background.layer.shadowColor = UIColor.black.cgColor
            background.layer.shadowOffset = CGSize(width: 0, height: 2)
            background.layer.shadowOpacity = 0.8
            background.layer.shadowRadius = 7
            
            imageView.layer.cornerRadius = 4
        } else {
            //setup shadow view
            let shadowView = UIView(frame: imageView.frame)
//            self.insertSubview(shadowView, belowSubview: imageView)
            self.insertSubview(shadowView, at: 0)
            shadowView.translatesAutoresizingMaskIntoConstraints = false
            shadowView.heightAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
            shadowView.widthAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
            shadowView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
            shadowView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
            
            
            shadowView.layer.cornerRadius = 3
            shadowView.backgroundColor = .white
            shadowView.clipsToBounds = false
            shadowView.layer.shadowColor = UIColor.darkGray.cgColor
            shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
            shadowView.layer.shadowOpacity = 0.8
            shadowView.layer.shadowRadius = 4
            
            imageView.layer.cornerRadius = 3
        }
    }
    
    func startAnimating() {
        let shadowViews = self.subviews[0...1]
        UIView.animateKeyframes(withDuration: 0.3,
                                delay: TimeInterval.random(in: 0.0...0.3),
                                options: [.calculationModeLinear, .repeat, .autoreverse],
                                animations: {
                                    
                                    let scale: CGFloat = 0.95
                                    
                                    UIView.addKeyframe(withRelativeStartTime: 0,
                                                       relativeDuration: 1/2,
                                                       animations: { [weak self] in
                                                        
                                                        let transform = CGAffineTransform(scaleX: scale + 0.01, y: scale + 0.01)
                                                        
                                                        self?.topImg.transform = transform
                                                        self?.background.transform = transform
                                                        self?.midImg.transform = transform
                                                        self?.backImg.transform = transform
                                                        
                                                        _ = shadowViews.map({ (view) -> Void in
                                                            view.transform = transform
                                                        })
                                    })
                                    UIView.addKeyframe(withRelativeStartTime: 1/2,
                                                       relativeDuration: 1/2,
                                                       animations: {[weak self] in
                                                        
                                                        let transform = CGAffineTransform(scaleX: scale, y: scale)
                                                        
                                                        self?.topImg.transform = transform
                                                        self?.background.transform = transform
                                                        self?.midImg.transform = transform
                                                        self?.backImg.transform = transform
                                                        
                                                        _ = shadowViews.map({ (view) -> Void in
                                                            view.transform = transform
                                                        })
                                    })
        }, completion: nil)
    }
    
    func stopAnimating() {
        let shadowViews = self.subviews[0...1]
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.topImg.transform = .identity
            self?.background.transform = .identity
            self?.midImg.transform = .identity
            self?.backImg.transform = .identity
            
            _ = shadowViews.map({ (view) -> Void in
                view.transform = .identity
            })
        }
    }
    
    //Tell the collectionview which cell had its button pressed
    @objc func deleteButtonTappedFromCell() {
        delegate?.didTapDeleteButton(cell: self)
    }

}
