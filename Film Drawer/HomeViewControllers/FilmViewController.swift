//
//  ViewController.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 13/06/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit
import CoreData

class FilmViewController: FetchedResultsCollectionViewController, UICollectionViewDelegateFlowLayout {
    
    //MARK: variables for data source
    let serialQueue = DispatchQueue(label: "filmsvc decoding queue")
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    var fetchedResultsController: NSFetchedResultsController<Film>?
    var spacing: CGFloat = 0.05 * UIScreen.main.bounds.width //Cell width is 25.6% of screen width. This is the remainder.

    //MARK: Navigation accessories
    let searchController = UISearchController(searchResultsController: nil)
    var doneDeletingButton = UIBarButtonItem()
    var addFilmButton = UIBarButtonItem()
    
    
    override var isEditing: Bool {
        didSet {
            if isEditing {
                navigationItem.rightBarButtonItem = doneDeletingButton
            } else {
                navigationItem.rightBarButtonItem = addFilmButton
            }
        }
    }
    
    private func updateUI(_ prediate: NSPredicate = NSPredicate(value: true)) {
        if let context = container?.viewContext {
            let fetchRequest: NSFetchRequest<Film> = Film.fetchRequest()
            fetchRequest.predicate = prediate
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastUpdate", ascending: false)]
            
            fetchedResultsController = NSFetchedResultsController<Film>(fetchRequest: fetchRequest,
                                                                        managedObjectContext: context,
                                                                        sectionNameKeyPath: nil,
                                                                        cacheName: nil)
            
            do {
                try fetchedResultsController?.performFetch()
                collectionView.reloadSections(IndexSet(integer: 0))
            } catch {
                print("FilmViewController: line 33. Error performing fetch.\n")
                print("\(error)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isEditing = false
        updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController?.delegate = self
        
        //register the xib file for the film cell
        collectionView.register(UINib(nibName: "FilmCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "filmcell")
        
        //add the search controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search films"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        setupBarButtons()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "addfilmsegue",
            let destVC = segue.destination as? FilmDetailViewController {
            
            destVC.container = container
            if let _ = sender as? UIBarButtonItem {
                destVC.isAddingFilmToDatabase = true
            } else {
                destVC.isAddingFilmToDatabase = false
            }
        }
        
        if  segue.identifier == "filmdetailsegue",
            let destVC = segue.destination as? BasePhotosCollectionViewController,
            let sender = sender as? FilmCollectionViewCell,
            let index = collectionView.indexPath(for: sender),
            let film = fetchedResultsController?.object(at: index) {
            
            destVC.container = container
            destVC.film = film
            destVC.navigationItem.title = film.name ?? "Film #\(index.row + 1)"
            
        }
    }
}

//MARK: Helper functions
extension FilmViewController {
    
    fileprivate func setupBarButtons() {
        doneDeletingButton = UIBarButtonItem(title: "OK", style: .plain, target: self, action: #selector(stopEditing(_:)))
        addFilmButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(goToAddFilmVC(_:)))
    }
    
    @objc fileprivate func goToAddFilmVC(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addfilmsegue", sender: sender)
    }
    
    @objc fileprivate func startEditing(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            isEditing = true
            collectionView.reloadData()
        }
    }
    
    @objc fileprivate func stopEditing(_ sender: UIBarButtonItem) {
        isEditing = false
        collectionView.reloadData()
    }
}

extension FilmViewController: FilmCellDelegate {
    //MARK: FilmCellDelegate function
    func didTapDeleteButton(cell: FilmCollectionViewCell) {
        if  let index = collectionView.indexPath(for: cell),
            let film = fetchedResultsController?.object(at: index),
            let context = container?.viewContext {
            
            context.delete(film)
            try? context.save()
            updateUI()
            
        }
    }
    
    //MARK: Collection View Delegate functions
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count >= 1 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filmcell", for: indexPath) as! FilmCollectionViewCell
        
        guard let film = fetchedResultsController?.object(at: indexPath) else {
            fatalError("Attempting to create cell without a film managed object. FilmViewController, line 64.")
        }
        
        cell.isEditing = self.isEditing
        cell.delegate = self
        
        let lpGR = UILongPressGestureRecognizer(target: self, action: #selector(startEditing(sender:)))
        cell.addGestureRecognizer(lpGR)
        cell.isUserInteractionEnabled = true
        
        cell.midImg.image = nil
        cell.backImg.image = nil
        
        let topImageSize = cell.topImg.bounds.size
        let midImageSize = cell.midImg.bounds.size
        let backImageSize = cell.backImg.bounds.size
        let imageScale = collectionView.traitCollection.displayScale
        
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = imageScale
        
        serialQueue.async {
            if let film = self.fetchedResultsController?.object(at: indexPath) {
                
                let photos = film.getPhotos()
                let topPicture = photos.last
                let midPicture = (photos.count >= 2) ? photos[photos.count - 2] : nil
                let backPicture = (photos.count >= 3) ? photos[photos.count - 3] : nil
                
                if  let topData = topPicture?.file,
                    let downsampled = UIImage.downsample(imageWithData: topData, to: topImageSize, scale: imageScale) {
                    DispatchQueue.main.async {
                        cell.topImg.image = downsampled
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.topImg.image = #imageLiteral(resourceName: "FilmOutline")
                    }
                }
                
                if  let midData = midPicture?.file,
                    let downsampled = UIImage.downsample(imageWithData: midData, to: midImageSize, scale: imageScale) {
                    DispatchQueue.main.async {
                        cell.midImg.image = downsampled
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.midImg.image = nil
                    }
                }
                
                if  let backData = backPicture?.file,
                    let downsampled = UIImage.downsample(imageWithData: backData, to: backImageSize, scale: imageScale) {
                    DispatchQueue.main.async {
                        cell.backImg.image = downsampled
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.backImg.image = nil
                    }
                }
            }
        }
        
        cell.filmNameLabel.text = film.name
        
        return cell
    }
    
    //MARK: Navigation
    //NOTE: When the user taps on one of the films, they are taken to the photos that belong to the film they tapped. There, they will have (1) a button on the right to add another frame to the film and (2) a button on the left to see the propoerties of the film, which will take them to the FilmDetalVC with "isAddingFilmToDatabase" being false.
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

//        let filmDetailVC = UIStoryboard(name: "FilmDetail", bundle: nil).instantiateViewController(withIdentifier: "filmdetailvc") as! FilmDetailViewController
//        filmDetailVC.isAddingFilmToDatabase = false
//        filmDetailVC.film = fetchedResultsController?.object(at: indexPath)
//        navigationController?.pushViewController(filmDetailVC, animated: true)
        
        performSegue(withIdentifier: "filmdetailsegue", sender: collectionView.cellForItem(at: indexPath) as! FilmCollectionViewCell)
    }
}


extension FilmViewController { //MARK: Collection View Flow Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let deviceWidth = UIScreen.main.bounds.width
        let heightToWidthRatio: CGFloat = 1.5 //from design
        
        return CGSize(width: deviceWidth * 0.256, height: deviceWidth * 0.256 * heightToWidthRatio)
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

extension FilmViewController: UISearchResultsUpdating, UISearchBarDelegate {
    //TODO: tf do we search for? How? what? ...ugh....
    func updateSearchResults(for searchController: UISearchController) {
        
        if !(searchController.searchBar.text?.isEmpty ?? true) {
            let cVarArg = searchController.searchBar.text! as CVarArg
            
            let predicate = NSPredicate(format: "name contains[c] %@ OR iso == %@ OR isoDevelopedAt == %@", cVarArg, cVarArg, cVarArg)
            updateUI(predicate)
        } else {
            updateUI()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("what")
        updateUI()
    }
    
}
