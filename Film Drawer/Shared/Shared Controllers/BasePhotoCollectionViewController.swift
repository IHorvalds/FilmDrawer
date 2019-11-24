//
//  BasePhotoCollectionViewController.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 02/09/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit
import Kingfisher
import CoreData

class BasePhotosCollectionViewController: FetchedResultsCollectionViewController, UICollectionViewDelegateFlowLayout {
    
    //MARK: variables for data source
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    var fetchedResultsController: NSFetchedResultsController<Photo>?
    var camera: Camera?
    var film: Film?
    //2 objects per row
    var spacing: CGFloat = 3
    
    private var doneDeletingButton = UIBarButtonItem()
    private var addPhotoButton = UIBarButtonItem()
    private var moreButton = UIBarButtonItem()
    
    override var isEditing: Bool {
        didSet {
            if isEditing {
                navigationItem.rightBarButtonItem = doneDeletingButton
            } else {
                if film != nil {
                    navigationItem.rightBarButtonItem = moreButton
                } else {
                    navigationItem.rightBarButtonItem = addPhotoButton
                }
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
            
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "belongsTo.name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))), NSSortDescriptor(key: "belongsTo.lastUpdate", ascending: false)]
            
            fetchedResultsController = NSFetchedResultsController<Photo>(fetchRequest: fetchRequest,
                                                                         managedObjectContext: context,
                                                                         sectionNameKeyPath: "belongsTo.name",
                                                                         cacheName: nil)
            
            fetchedResultsController?.delegate = self
            
            context.performAndWait {
                do {
                    try fetchedResultsController?.performFetch()
                } catch {
                    print("PhotosForCameraViewController: line 77. Error performing fetch.\n")
                    print("\(error)")
                }
            }
            
            collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isEditing = false
        updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        collectionView.prefetchDataSource = self
        
        collectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "photocell")
        collectionView.register(UINib(nibName: "CollectionHeaderReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        let layout = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout)
        
        layout.sectionHeadersPinToVisibleBounds = true
        
        setupBarButtons()
        setupCollectionViewPersona()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        fetchedResultsController?.delegate = nil
    }
}

extension BasePhotosCollectionViewController: PhotoCellDelegate {
    //MARK: Helper functions
    
    fileprivate func setupBarButtons() {
        doneDeletingButton = UIBarButtonItem(title: "OK", style: .plain, target: self, action: #selector(stopEditing(_:)))
        addPhotoButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(goToAddPhotoVC(_:)))
        moreButton = UIBarButtonItem(image: #imageLiteral(resourceName: "􀍠MoreIcon"), style: .plain, target: self, action: #selector(displayMoreMenu))
        
        doneDeletingButton.tintColor = .systemYellow
        addPhotoButton.tintColor = .systemYellow
        moreButton.tintColor = .systemYellow
    }
    
    fileprivate func setupCollectionViewPersona() {
        let backgroundView = UIView()
        let image = UIImageView(image: #imageLiteral(resourceName: "OctoPui"))
        image.contentMode = .scaleAspectFill
        collectionView.backgroundView = backgroundView
        backgroundView.addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.widthAnchor.constraint(equalTo: backgroundView.widthAnchor).isActive = true
        image.heightAnchor.constraint(equalTo: backgroundView.widthAnchor).isActive = true
        image.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        image.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor).isActive = true
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
        goToAddPhotoViewController()
    }
    
    @objc fileprivate func displayMoreMenu() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(.init(title: "Add a photo", style: .default, handler: { [weak self] (_) in
            //go to add a photo vc
            guard let self = self else { return }
            print("goto AddPhotoVC")
            self.goToAddPhotoViewController()
        }))
        
        
        actionSheet.addAction(.init(title: "Edit film properties", style: .default, handler: { [weak self] (_) in
            guard let self = self else { return }
            print("go to FilmDetailViewController")
            self.goToFilmDetailViewController()
        }))
        
        actionSheet.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
        
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
    
    fileprivate func goToAddPhotoViewController() {
        let addPhotoVC = UIStoryboard(name: "PhotoDetail", bundle: nil).instantiateViewController(withIdentifier: "addphoto") as! PhotoDetailTableViewController
        let addPhotoModal = UINavigationController(rootViewController: addPhotoVC)
        
        addPhotoVC.isAddingNewPicture = true
        addPhotoVC.container = container
        
        addPhotoModal.modalPresentationStyle = .fullScreen
        
        present(addPhotoModal, animated: true, completion: nil)
    }
    
    fileprivate func goToFilmDetailViewController() {
        let filmDetailVC = UIStoryboard(name: "FilmDetail", bundle: nil).instantiateViewController(withIdentifier: "filmdetailvc") as! FilmDetailViewController
        
        let filmDetailModal = UINavigationController(rootViewController: filmDetailVC)
        
        filmDetailVC.isAddingFilmToDatabase = false
        filmDetailVC.film = film
        filmDetailVC.container = container
        
        filmDetailVC.modalPresentationStyle = .fullScreen
        
        present(filmDetailModal, animated: true, completion: nil)
    }
    
}

extension BasePhotosCollectionViewController { //MARK: Collection View Data source and Delegate
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
//        print(fetchedResultsController?.sections?.count)
        return fetchedResultsController?.sections?.count ?? 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count >= 1 {
            print(section, sections[section].numberOfObjects)
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

        let imageSize = cell.bounds.size
        let imageScale = collectionView.traitCollection.displayScale

        if let url = photo.file {
            let provider = LocalFileImageDataProvider(fileURL: url)
            let processor = DownsamplingImageProcessor(size: imageSize) |> RoundCornerImageProcessor(cornerRadius: 5.0)
            cell.image.kf.setImage(with: provider, options: [
                .processor(processor),
                .scaleFactor(imageScale),
                .cacheOriginalImage
            ])
        }

        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = imageScale

//        serialQueue.async {
//            if  let data = photo.file,
//                let downsampledImage = UIImage.downsample(imageWithData: data, to: imageSize, scale: imageScale) {
//
//
//                DispatchQueue.main.async {
//                    cell.image.image = downsampledImage
//                }
//
//
//            }
//        }

        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
//        // Asynchronously decode and downsample every image we are about to show
//        let imageScale = collectionView.traitCollection.displayScale
//        var cells = [PhotoCollectionViewCell]()
//        var photos = [Photo]()
//        for index in indexPaths {
//            if let photo = fetchedResultsController?.object(at: index),
//                let cell = collectionView.cellForItem(at: index) as? PhotoCollectionViewCell {
//                cells.append(cell)
//                photos.append(photo)
//            }
//        }
//
//        for (i, cell) in cells.enumerated() {
//            serialQueue.async {
//                let imageSize = cell.bounds.size
//                if  let data = photos[i].file,
//                    let downsampledImage = UIImage.downsample(imageWithData: data, to: imageSize, scale: imageScale) {
//
//
//                    DispatchQueue.main.async {
//                        cell.image.image = downsampledImage
//                    }
//
//
//                }
//            }
//        }
//    }
}

extension BasePhotosCollectionViewController { //MARK: Collection View Flow Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let deviceWidth = UIScreen.main.bounds.width - 3 * spacing
        
        return CGSize(width: deviceWidth/4, height: deviceWidth/4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: spacing, left: 0, bottom: spacing, right: 0)
    }
    
}
