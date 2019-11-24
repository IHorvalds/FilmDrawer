//
//  FullWidthCollectionViewController.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 07/08/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

class FullWidthCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var numberOfItemsPerLine: Int = 3 // set this to 4 when working with PhotoVC
    var spacing: CGFloat = 0

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let deviceWidth = UIScreen.main.bounds.width - CGFloat(numberOfItemsPerLine + 1) * spacing //numberOfItemsPerLine + 1 = (numberOfItemsPerLine - 1) + 2. That is the spaces in between the items plus the padding around all the items.
        
        return CGSize(width: deviceWidth/CGFloat(numberOfItemsPerLine), height: deviceWidth/CGFloat(numberOfItemsPerLine))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
    }

}
