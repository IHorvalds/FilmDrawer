//
//  ArchivesViewController.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 13/08/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

class ArchivesViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionViewPersona()
    }
    
    fileprivate func setupCollectionViewPersona() {
        let backgroundView = UIView()
        let image = UIImageView(image: #imageLiteral(resourceName: "Bufnita"))
        image.contentMode = .scaleAspectFill
        collectionView.backgroundView = backgroundView
        backgroundView.addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.widthAnchor.constraint(equalTo: backgroundView.widthAnchor).isActive = true
        image.heightAnchor.constraint(equalTo: backgroundView.widthAnchor).isActive = true
        image.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        image.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor).isActive = true
    }

}
