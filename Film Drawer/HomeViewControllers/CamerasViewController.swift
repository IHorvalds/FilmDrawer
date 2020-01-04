//
//  CamerasViewController.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 13/08/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher

class CamerasViewController: FetchedResultsCollectionViewController, UICollectionViewDelegateFlowLayout {
    

    //MARK: variables for data source
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    var fetchedResultsController: NSFetchedResultsController<Camera>?
//    let serialQueue = DispatchQueue(label: "Decode queue")
    //2 objects per row
    var spacing: CGFloat = 0.05 * UIScreen.main.bounds.width //Cell width is 25.6% of screen width. This is the remainder.
    
    //MARK: Navigation accessories
    let searchController = UISearchController(searchResultsController: nil)
    var doneDeletingButton = UIBarButtonItem()
    var addCameraButton = UIBarButtonItem()
    
    
    override var isEditing: Bool {
        didSet {
            if isEditing {
                navigationItem.rightBarButtonItem = doneDeletingButton
            } else {
                navigationItem.rightBarButtonItem = addCameraButton
            }
        }
    }
    
    private func updateUI(_ predicate: NSPredicate = NSPredicate(value: true)) {
        if let context = container?.viewContext {
            let fetchRequest: NSFetchRequest<Camera> = Camera.fetchRequest()
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "favourite", ascending: false), NSSortDescriptor(key: "name", ascending: true), NSSortDescriptor(key: "dateAdded", ascending: false)]
            
            fetchedResultsController = NSFetchedResultsController<Camera>(fetchRequest: fetchRequest,
                                                                          managedObjectContext: context,
                                                                          sectionNameKeyPath: nil,
                                                                          cacheName: nil)
            fetchedResultsController?.delegate = self
            
            context.performAndWait {
                do {
                    try fetchedResultsController?.performFetch()
                } catch {
                    print("CameraViewController: line 51. Error performing fetch.\n")
                    print("\(error)")
                }
            }
            collectionView.reloadSections(IndexSet(arrayLiteral: 0))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isEditing = false
        updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //register the xib file for the film cell
        collectionView.register(UINib(nibName: "CameraCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cameracell")
        
        //add the search controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search cameras"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        setupBarButtons()
        setupCollectionViewPersona()
    }

}

extension CamerasViewController { //MARK: Helper functions
        
    fileprivate func setupBarButtons() {
        doneDeletingButton = UIBarButtonItem(title: "OK", style: .plain, target: self, action: #selector(stopEditing(_:)))
        addCameraButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(goToAddCameraVC(_:)))
        
        doneDeletingButton.tintColor = UIColor(named: "AccentColor")
        addCameraButton.tintColor = UIColor(named: "AccentColor")
    }
    
    fileprivate func setupCollectionViewPersona() {
        let backgroundView = UIView()
        let image = UIImageView(image: #imageLiteral(resourceName: "Efefantel"))
        image.contentMode = .scaleAspectFill
        collectionView.backgroundView = backgroundView
        backgroundView.addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.widthAnchor.constraint(equalTo: backgroundView.widthAnchor, multiplier: 0.5).isActive = true
        image.heightAnchor.constraint(equalTo: backgroundView.widthAnchor, multiplier: 0.5).isActive = true
        image.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        image.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor).isActive = true
    }
    
    @objc fileprivate func goToAddCameraVC(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addcamerasegue", sender: sender)
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

extension CamerasViewController: UISearchResultsUpdating, UISearchBarDelegate { //Search controller
    
    func updateSearchResults(for searchController: UISearchController) {

        if !(searchController.searchBar.text?.isEmpty ?? true) {
            let cVarArg = searchController.searchBar.text! as CVarArg

            let predicate = NSPredicate(format: "name contains[c] %@ OR lensMount contains[c] %@", cVarArg, cVarArg)
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

extension CamerasViewController: CameraCellDelegate {
    //MARK: Collection View Delegate functions
    func favouriteButtonPressed(for cell: CameraCollectionViewCell) {
        if  let index = collectionView.indexPath(for: cell),
            let camera = fetchedResultsController?.object(at: index),
            let context = container?.viewContext {
            
            context.performAndWait {
                camera.favourite = !camera.favourite
                let image = (camera.favourite) ? #imageLiteral(resourceName: "HeartFill") : #imageLiteral(resourceName: "HeartOutline")
                cell.favouriteButton.setImage(image, for: .normal)
                
                do {
                    try context.save()
                } catch {
                    print("\(error.localizedDescription)")
                }
            }
//            updateUI()
        }
        
    }
    
    func didTapDeleteButton(cell: CameraCollectionViewCell) {
        if  let index = collectionView.indexPath(for: cell),
            let camera = fetchedResultsController?.object(at: index),
            let context = container?.viewContext {
            
            if let url = camera.photo {
                ImageFileManager.shared.delete(file: url, handler: nil)
            }
            
            context.delete(camera)
            try? context.save()
            updateUI()
            
        }
    }
    
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cameracell", for: indexPath) as! CameraCollectionViewCell
        
        guard let camera = fetchedResultsController?.object(at: indexPath) else {
            fatalError("Attempting to create cell without a camera managed object. CamerasViewController, line 152.")
        }
        
        cell.isEditing = self.isEditing
        cell.delegate = self
        
        let lpGR = UILongPressGestureRecognizer(target: self, action: #selector(startEditing(sender:)))
        cell.addGestureRecognizer(lpGR)
        cell.isUserInteractionEnabled = true
        
        let imageSize = cell.cameraPhoto.bounds.size
        let imageScale = collectionView.traitCollection.displayScale
        
        if  let imageName = camera.photo,
            let imageUrl = ImageFileManager.shared.getBaseURL()?.appendingPathComponent(imageName) {
            
            let provider = LocalFileImageDataProvider(fileURL: imageUrl)
            let processor = DownsamplingImageProcessor(size: imageSize) |> RoundCornerImageProcessor(cornerRadius: 5.0)
            let placeholder = #imageLiteral(resourceName: "CameraDefaultPictureLarge")
            cell.cameraPhoto.kf.setImage(with: provider,
                                         placeholder: placeholder,
                                         options: [
                .processor(processor),
                .scaleFactor(imageScale),
                .cacheOriginalImage])
        } else {
            cell.cameraPhoto.image = #imageLiteral(resourceName: "CameraDefaultPicture")
        }
        
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = imageScale
        
        cell.cameraNameLabel.text = camera.name
        
        let image = (camera.favourite) ? #imageLiteral(resourceName: "HeartFill") : #imageLiteral(resourceName: "HeartOutline")
        cell.favouriteButton.setImage(image, for: .normal)
        
        return cell
    }
}

extension CamerasViewController { //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "addcamerasegue",
            let destVC = segue.destination as? CameraDetailViewController {
            
            if  let cell = sender as? CameraCollectionViewCell,
                let index = collectionView.indexPath(for: cell) {
                
                destVC.camera = fetchedResultsController?.object(at: index)
                destVC.isAddingNewCamera = false
                destVC.shouldCaptureNewImage = false
            } else {
                destVC.isAddingNewCamera = true
                destVC.shouldCaptureNewImage = true
            }
            
            destVC.container = container
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cameraDetailVC = (UIStoryboard(name: "CameraDetail", bundle: nil).instantiateViewController(withIdentifier: "cameradetailvc") as! CameraDetailViewController)
        cameraDetailVC.isAddingNewCamera = false
        cameraDetailVC.shouldCaptureNewImage = false
        cameraDetailVC.camera = fetchedResultsController?.object(at: indexPath)
        navigationController?.pushViewController(cameraDetailVC, animated: true)
    }
}

extension CamerasViewController { //MARK: Collection View Flow Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let deviceWidth = UIScreen.main.bounds.width
        let heightToWidthRatio: CGFloat = 1.3 //from design
        
        return CGSize(width: deviceWidth * 0.41, height: deviceWidth * 0.41 * heightToWidthRatio)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
    }
    
}
