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
    
    var captureManager = CameraCaptureManager.shared
    
    var shouldSave: Bool = false
    
    
    // Cells and text fields
    @IBOutlet private weak var pictureCell: PictureTableViewCell!
    @IBOutlet private weak var filmNameCell: UITableViewCell!
    @IBOutlet private weak var exposureMenu: DropDown!
    @IBOutlet private weak var apertureMenu: DropDown!
    @IBOutlet private weak var focalLengthMenu: DropDown!
    @IBOutlet private weak var positionInFilmMenu: DropDown!
    @IBOutlet weak var dateTaken: UITextField!
    
    let datePicker = UIDatePicker()
    let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 44.0))
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        captureManager.delegate = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButton))
        
        if  isAddingNewPicture,
            let context = container?.viewContext {
            photo = Photo(context: context)
        }
        
        setupDatePicker()
        setupPictureCell()
        setupDropDown()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // save logic.
        //TODO: - Regular expression this. ASAP
        if shouldSave {
            photo?.belongsTo = film
            photo?.dateTaken = dateFormatter.date(from: dateTaken.text!)
            //photo?.aperture = apertureMenu.text // regular expression to fix this?
            photo?.exposure = exposureMenu.text
            //photo?.focalLength = focalLengthMenu.text // regular expression to fix this too?
            photo?.positionInFilm = Int16(positionInFilmMenu.text!)!
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNonzeroMagnitude
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            
            if indexPath.section == 0 {
                return UIScreen.main.bounds.width
            }
            
            if indexPath.section == 2 {
                return 420
            }
        }
        
        return 55
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
        pictureCell.imagePicker.delegate = self
        pictureCell.shouldCaptureNewImage = (photo?.file == nil)
        
        pictureCell.choosePhotoButton.addTarget(self, action: #selector(chooseFromGallery), for: .touchUpInside)
        pictureCell.takePhotoButton.addTarget(self, action: #selector(capturePicture), for: .touchUpInside)
        pictureCell.previewButton.addTarget(self, action: #selector(previewButtonTapped), for: .touchUpInside)
        pictureCell.newImageButton.addTarget(self, action: #selector(newImageTapped), for: .touchUpInside)
        
        if !pictureCell.shouldCaptureNewImage {
            let size = pictureCell.pictureView.bounds.size
            let scale = tableView.traitCollection.displayScale
            
            if  let imageName = photo?.file,
                let url = ImageFileManager.shared.getBaseURL()?.appendingPathComponent(imageName) {
                
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
        } else {
            captureManager.setupCameraOutput(previewView: pictureCell.previewView)
        }
    }
    
    fileprivate func setupDatePicker() {
        dateTaken.placeholder = dateFormatter.string(from: Date())
        dateTaken.tintColor = .clear
        dateFormatter.dateStyle = .medium
        datePicker.datePickerMode = .date
        datePicker.date = Date()
        datePicker.addTarget(self, action: #selector(changePhotoDateTaken(sender:)), for: .valueChanged)
        setupToolbar()
        dateTaken.inputAccessoryView = toolBar
        dateTaken.inputView = datePicker
    }
    
    fileprivate func setupToolbar() {
        let cancelBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelDatePicker))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(changePhotoDateTaken(sender:)))
        toolBar.setItems([cancelBarButton, spacer, doneBarButton], animated: false)
    }
    
    @objc func cancelDatePicker() {
        dateTaken.text = dateFormatter.string(from: Date())
    }
    
    @objc func changePhotoDateTaken(sender: Any) {
        dateTaken.text = dateFormatter.string(from: datePicker.date)
        photo?.dateTaken = datePicker.date
        if sender is UIBarButtonItem {
            dateTaken.resignFirstResponder()
        }
    }
    
    @objc func previewButtonTapped() {
        pictureCell.choosePhotoButton.backCol = .darkGray
        pictureCell.previewButton.backCol = UIColor(named: "AccentColor")!
        
        if !shouldTakeNewPicture {
            captureManager.setupCameraOutput(previewView: pictureCell.previewView)
        }
    }
    
    @objc func chooseFromGallery() {
        pictureCell.choosePhotoButton.backCol = UIColor(named: "AccentColor")!
        pictureCell.previewButton.backCol = .darkGray
        
        present(imagePicker, animated: true)
    }
    
    @objc func capturePicture() {
        captureManager.capturePicture()
        
        shouldTakeNewPicture = false
    }
    
    @objc func newImageTapped() {
        captureManager.setupCameraOutput(previewView: pictureCell.previewView)
    }
    
    @objc func doneButton() {
        
        if  photo?.addIDIfcompleteEnough() ?? false,
            let context = container?.viewContext {
            
            try? context.save()
            
        } else if let photo = photo {
            container?.viewContext.delete(photo)
        }
        
        if self.isModal() {
            self.dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func cancelButton() {
        
        shouldSave = false
        
        if let photo = photo {
            container?.viewContext.delete(photo)
        }
        if self.isModal() {
            self.dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    fileprivate func cropImageToSquare(image: CGImage, orientation: UIImage.Orientation) -> UIImage {
        //Trying to crop to a square
        let scale = tableView.traitCollection.displayScale
        let size = (image.width > image.height) ? image.height : image.width
        let rectToCrop = CGRect(x: (image.width-size)/2, y: (image.height-size)/2, width: size, height: size)
        
        if let croppedImage = image.cropping(to: rectToCrop) {
            let image = UIImage(cgImage: croppedImage, scale: scale, orientation: orientation)
            
            return image
        } else {
            return UIImage(cgImage: image, scale: scale, orientation: orientation)
        }
    }
    
    private func saveImage(_ image: UIImage) {
        if  let rotatedImage = image.rotateImage(),
            let imageData = rotatedImage.pngData() {
            
            if let url = photo?.file {
                ImageFileManager.shared.delete(file: url) {[weak self] (success, error) in
                    guard let self = self else { return }
                    if error != nil {
                        let alert = UIAlertController(title: "Oops", message: "An error occured saving your picture: \(String(describing: error!))", preferredStyle: .alert)
                        
                        alert.addAction(.init(title: "OK", style: .default, handler: nil))
                        alert.view.tintColor = UIColor(named: "AccentColor")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            
            
            let filename = "Picture-\(UUID()).PNG"
            ImageFileManager.shared.saveFile(with: imageData, filename: filename) {[weak self] (success, url, error) in
                guard let self = self else { return }
                if error != nil {
                    let alert = UIAlertController(title: "Oops", message: "An error occured saving your camera's picture: \(String(describing: error!))", preferredStyle: .alert)
                    
                    alert.addAction(.init(title: "OK", style: .default, handler: nil))
                    alert.view.tintColor = UIColor(named: "AccentColor")
                    self.present(alert, animated: true, completion: nil)
                } else if let url = url {
                    self.photo?.file = url
                    self.setupPictureCell()
                }
            }
        }
    }
    
}

extension PhotoDetailTableViewController: PhotoPickerDelegate {
    
    func shouldStopCameraRecording() {
        shouldTakeNewPicture = false
    }
    
    func processImage(image: CGImage) {
        if  let rotatedImage = UIImage(cgImage: image).rotateImage(),
            self.captureManager.checkForPhotosPermission() {
            UIImageWriteToSavedPhotosAlbum(rotatedImage, self, nil, nil)
        }
        saveImage(cropImageToSquare(image: image, orientation: .right))
    }
    
}
extension PhotoDetailTableViewController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if  let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            saveImage(cropImageToSquare(image: editedImage.cgImage!, orientation: .up))
            shouldStopCameraRecording()
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            saveImage(cropImageToSquare(image: originalImage.cgImage!, orientation: .up))
            shouldStopCameraRecording()
        }
        print("nothing")
        picker.dismiss(animated: true, completion: nil)
    }
}
