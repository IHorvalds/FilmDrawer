//
//  PhotoDetailTableViewController.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 12/11/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher

class PhotoDetailTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let imagePicker = UIImagePickerController()
    var photo: Photo?
    var film: Film?
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer

    var isAddingNewPicture: Bool = true
    var shouldTakeNewPicture: Bool = true
    
    
    // Cells and text fields
    @IBOutlet private weak var pictureCell: PictureTableViewCell!
    @IBOutlet private weak var filmNameCell: UITableViewCell!
    @IBOutlet private weak var exposureMenu: DropDown!
    @IBOutlet private weak var apertureMenu: DropDown!
    @IBOutlet private weak var focalLengthMenu: DropDown!
    @IBOutlet private weak var positionInFilmMenu: DropDown!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

         imagePicker.delegate = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButton))
        
        if  isAddingNewPicture,
            let context = container?.viewContext {
            photo = Photo(context: context)
        }
        
        
//        setupPictureCell()
        setupDropDown()
    }

}

extension PhotoDetailTableViewController: PhotoDetailControllerDelegate {
    func savePicture(cell: PictureTableViewCell, picture: CGImage) {
        print(picture)
    }
    
    func generateTags(cell: PictureTableViewCell, for image: CGImage) {
        print(image)
        print("hello")
    }
    
    
}

extension PhotoDetailTableViewController { // Helper functions
    
    fileprivate func setupDropDown() {
        exposureMenu.optionArray = ["1/2000s", "1/1000s", "1/500s", "1/250s",
                                    "1/125s", "1/60s", "1/30s", "1/15s", "1/8s",
                                    "1/4s", "1/2s", "1s", "2s", "4s"].reversed()
        exposureMenu.handleKeyboard = true
        
        apertureMenu.optionArray = ["f/1.4", "f/1.7", "f/2", "f/2.8", "f/4", "f/5.6", "f/8", "f/16", "f/22"]
        apertureMenu.handleKeyboard = true
        
        focalLengthMenu.optionArray = ["16mm", "35mm", "50mm", "85mm", "90mm", "105mm", "150mm", "200mm"]
        focalLengthMenu.handleKeyboard = true
        
        let maxFrames = film?.numberOfFrames ?? 36
        positionInFilmMenu.optionArray = (1...maxFrames).map({"\($0)"})
        positionInFilmMenu.handleKeyboard = false
    }
    
    fileprivate func setupPictureCell() {
        pictureCell.delegate = self
        pictureCell.shouldCaptureNewImage = (photo?.file == nil)
        
        if !pictureCell.shouldCaptureNewImage {
            let size = pictureCell.pictureView.bounds.size
            let scale = tableView.traitCollection.displayScale
            
            if let url = photo?.file {
                let provider = LocalFileImageDataProvider(fileURL: url)
                let processor = DownsamplingImageProcessor(size: size)
                pictureCell.pictureView.kf.indicatorType = .activity
                pictureCell.pictureView.kf.setImage(with: provider,
                                                    placeholder: nil,
                                                    options: [
                    .processor(processor),
                    .scaleFactor(scale),
                    .cacheOriginalImage], completionHandler: nil)
            }
            
//            DispatchQueue.global(qos: .userInitiated).async {
//                //downsample on a background queue
//                if  let data = self.photo?.file,
//                    let image = UIImage.downsample(imageWithData: data, to: size, scale: scale) {
//                    DispatchQueue.main.async { [weak self] in
//                        guard let self = self else { return }
//                        //and display on the main queue
//                        self.pictureCell.pictureView.image = image
//                    }
//                }
//            }
        }
    }
    
    @objc func doneButton() {
        if  photo?.addIDIfcompleteEnough() ?? false,
            let context = container?.viewContext {
            
            try? context.save()
            
        } else if let photo = photo {
            container?.viewContext.delete(photo)
        }
    }
    
    @objc func cancelButton() {
        if let photo = photo {
            container?.viewContext.delete(photo)
        }
        if self.isModal() {
            self.dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
}
