//
//  RoundedButton.swift
//  Counter
//
//  Created by Tudor Croitoru on 21/04/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

@IBDesignable class RoundedButton: UIButton {
    
    @IBInspectable var backCol: UIColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1) {
        didSet {
            backgroundColor = backCol
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 15.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius  = cornerRadius
        backgroundColor     = backCol
        addTarget(self, action: #selector(hasBeenPressed), for: .touchDown)
    }
    
    @objc func hasBeenPressed() {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.backgroundColor = .darkGray
        }) { (_) in
            UIView.animate(withDuration: 0.4) { [weak self] in
                self?.backgroundColor = self?.backCol
            }
        }
    }

}
