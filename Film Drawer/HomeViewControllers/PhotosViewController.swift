//
//  PhotosViewController.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 13/08/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

class PhotosViewController: BasePhotosCollectionViewController {
    
    //MARK: Navigation accessories
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search photos"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        setupBarButtons()
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                     withReuseIdentifier: "header", for: indexPath) as! CollectionHeaderReusableView

        let sectionInfo = fetchedResultsController?.sections?[indexPath.section]
        let photo = sectionInfo?.objects?[0] as! Photo
//        let firstPhoto = photo.belongsTo?.containsPictures?.firstObject as? Photo
//        let lastPhoto = photo.belongsTo?.containsPictures?.lastObject as? Photo

        var headerTitle = photo.belongsTo?.name
        if  let cameraName = photo.belongsTo?.shotOn?.name,
            let filmName = headerTitle {

            headerTitle = filmName + " • " + cameraName
        }

        header.filmNameLabel.text = headerTitle

        return header
    }

}

extension PhotosViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
//        print(searchController.searchBar.text)
        print("update the fetched results controller's query so that the text in here matches at least partially the tags")
    }
    
    
}

extension PhotosViewController { //MARK: Helper functions
    @objc fileprivate func setupBarButtons() {
        
    }
}

extension PhotosViewController { //MARK: navigation
    
}
