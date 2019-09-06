//
//  BasePhotoCollectionViewController.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 02/09/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

import CoreData

class BasePhotosCollectionViewController: FetchedResultsCollectionViewController, UICollectionViewDelegateFlowLayout {
    
    //MARK: variables for data source
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    var fetchedResultsController: NSFetchedResultsController<Photo>?
    var camera: Camera?
    var film: Film?
    //2 objects per row
    var spacing: CGFloat = 0
    
    var doneDeletingButton = UIBarButtonItem()
    var addPhotoButton = UIBarButtonItem()
    
    override var isEditing: Bool {
        didSet {
            if isEditing {
                navigationItem.rightBarButtonItem = doneDeletingButton
            } else {
                navigationItem.rightBarButtonItem = addPhotoButton
            }
        }
    }
    
    public func updateUI() {
        if  let context = container?.viewContext {
            let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
            if let camera = camera { // if there's a camera, use that to create a predicate
                let predicate = NSPredicate(format: "belongsTo.shotOn = %@", camera)
                fetchRequest.predicate = predicate
            }
            
            if let film = film { // if there's a film, use that to create a predicate
                let preditcate = NSPredicate(format: "belongsTo = %@", film)
                fetchRequest.predicate = preditcate
            }
            
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "belongsTo.name", ascending: true), NSSortDescriptor(key: "positionInFilm", ascending: true)]
            
            fetchedResultsController = NSFetchedResultsController<Photo>(fetchRequest: fetchRequest,
                                                                         managedObjectContext: context,
                                                                         sectionNameKeyPath: "belongsTo.name",
                                                                         cacheName: nil)
            fetchedResultsController?.delegate = self
            
            context.performAndWait {
                do {
                    try fetchedResultsController?.performFetch()
                } catch {
                    print("PhotosForCameraViewController: line 54. Error performing fetch.\n")
                    print("\(error)")
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "photocell")
        
        setupBarButtons()
    }
}

extension BasePhotosCollectionViewController: PhotoCellDelegate {
    //MARK: Helper functions
    
    fileprivate func setupBarButtons() {
        doneDeletingButton = UIBarButtonItem(title: "OK", style: .plain, target: self, action: #selector(stopEditing(_:)))
        addPhotoButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(goToAddPhotoVC(_:)))
    }
    
    func didTapDeleteButton(cell: PhotoCollectionViewCell) {
        if  let index = collectionView.indexPath(for: cell),
            let photo = fetchedResultsController?.object(at: index),
            let context = container?.viewContext {
            
            context.delete(photo)
            try? context.save()
            updateUI()
            
        }
    }
    
    @objc fileprivate func goToAddPhotoVC(_ sender: UIBarButtonItem) {
        print("go to add photo vc")
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

extension BasePhotosCollectionViewController { //MARK: Navigation
    
}

extension BasePhotosCollectionViewController { //MARK: Collection View Data source and Delegate
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photocell", for: indexPath) as! PhotoCollectionViewCell
        
        guard let photo = fetchedResultsController?.object(at: indexPath) else {
            fatalError("No photo at index path \(indexPath)")
        }
        
        let lpGR = UILongPressGestureRecognizer(target: self, action: #selector(startEditing(sender:)))
        cell.addGestureRecognizer(lpGR)
        cell.isUserInteractionEnabled = true
        cell.delegate = self
        
        cell.image.image = photo.getUIImage()
        
        return cell
    }
}

extension BasePhotosCollectionViewController { //MARK: Collection View Flow Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let deviceWidth = UIScreen.main.bounds.width
        
        return CGSize(width: deviceWidth/4, height: deviceWidth/4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
    }
    
}
