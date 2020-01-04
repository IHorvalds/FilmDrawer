//
//  CameraDetailViewController.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 13/08/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import Photos
import Kingfisher

class CameraDetailViewController: UITableViewController {
    
    let imagePicker = UIImagePickerController()
    let cameraCaptureManager = CameraCaptureManager.shared
    
    var camera: Camera?
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    lazy var shouldCaptureNewImage: Bool = true

    lazy var isAddingNewCamera: Bool = true
    
    var doneButton = UIBarButtonItem()
    var cancelButton = UIBarButtonItem()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed(_:)))
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed(_:)))
        
        imagePicker.delegate = self
        
        cameraCaptureManager.delegate = self
        
        navigationItem.title = (camera == nil) ? "Add camera" : camera?.name
        
        if  isAddingNewCamera,
            let context = container?.viewContext {
            camera = Camera(context: context)
            navigationItem.leftBarButtonItem = cancelButton
        }
        
        navigationItem.rightBarButtonItem = doneButton
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(updateTableView),
                                       name: Notification.Name.NSManagedObjectContextObjectsDidChange,
                                       object: container?.viewContext)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension CameraDetailViewController { //Helper functions
    
    @objc fileprivate func updateTableView() {
        tableView.reloadData()
        navigationController?.title = camera?.name
    }
    
    @objc fileprivate func cancelButtonPressed(_ sender: UIBarButtonItem) {
        if  isAddingNewCamera,
            let camera = camera {
            container?.viewContext.delete(camera)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func doneButtonPressed(_ sender: UIBarButtonItem) {
        if  let context = container?.viewContext,
            isAddingNewCamera,
            camera != nil,
            camera!.addIdIfCompleteEnough() {
            
            do {
                try context.save()
                dismiss(animated: true, completion: nil)
            } catch {
                print("Oops. Problem saving.")
                let alert = UIAlertController(title: "Error saving camera", message: "Here's the error:/n \(error)", preferredStyle: .alert)
                alert.addAction(.init(title: "Dismiss", style: .default, handler: { [weak self] (_) in
                    self?.dismiss(animated: true, completion: nil)
                }))
                alert.view.tintColor = UIColor(named: "AccentColor")
                present(alert, animated: true)
            }
            
        } else {
            if  !(camera?.addIdIfCompleteEnough() ?? true),
                let camera = camera {
                container?.viewContext.delete(camera)
            }
            
            try? container?.viewContext.save()
            
            if self.isModal() {
                dismiss(animated: true, completion: nil)
            } else {
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc fileprivate func changeShouldCaptureNewImage() {
        shouldCaptureNewImage = !shouldCaptureNewImage
        tableView.reloadData()
    }
    
    @objc fileprivate func capturePicture() {
        cameraCaptureManager.capturePicture()
        
        shouldCaptureNewImage = false
    }
    
    @objc fileprivate func chooseFromGallery() {
        if cameraCaptureManager.checkForPhotosPermission() {
            present(imagePicker, animated: true, completion: nil)
        }
    }

}

extension CameraDetailViewController { //MARK: TableView Data source and delegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 2 {
            return 1
        } else {
            if  let context = container?.viewContext,
                (camera?.hasPhotos(in: context) ?? false) {
                return 4
            }
            return 3
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        }
        if section == 1 {
            return "Camera Details"
        }
        
        return "Description"
    }

    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "You need to give your camera a name. Other parameters are optional."
        }
    
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNonzeroMagnitude
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UIScreen.main.bounds.width
        }
        
        if indexPath.section == 1 {
            return 44
        }
        
        return 120
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "camerapicturecell")!
            
            let cameraCell: CameraPictureCell = cell as! CameraPictureCell
            
            cameraCell.takeOrChooseNewPicture.addTarget(self, action: #selector(changeShouldCaptureNewImage), for: .touchUpInside)
            cameraCell.captureButton.addTarget(self, action: #selector(capturePicture), for: .touchUpInside)
            cameraCell.galleryButton.addTarget(self, action: #selector(chooseFromGallery), for: .touchUpInside)
            
            //Show or hide views and buttons depending on whether we should capture or display an image
            cameraCell.cameraPreview.isHidden = !shouldCaptureNewImage
            cameraCell.cameraPicture.isHidden = shouldCaptureNewImage
            cameraCell.captureButton.isHidden = !shouldCaptureNewImage
            cameraCell.galleryButton.isHidden = !shouldCaptureNewImage
            
            if shouldCaptureNewImage {
                cameraCell.cameraPreview.contentMode = .scaleAspectFit
                cameraCaptureManager.setupCameraOutput(previewView: cameraCell.cameraPreview)
            } else {
                
                let imageScale = tableView.traitCollection.displayScale
                let imageSize = cameraCell.cameraPicture.bounds.size
                
                if  let imageName = camera?.photo,
                    let imageUrl = ImageFileManager.shared.getBaseURL()?.appendingPathComponent(imageName) {
                    
                    let provider = LocalFileImageDataProvider(fileURL: imageUrl)
                    let processor = DownsamplingImageProcessor(size: imageSize)
                    let placeholder = #imageLiteral(resourceName: "CameraDefaultPictureLarge")
                    cameraCell.cameraPicture.kf.setImage(with: provider,
                                                 placeholder: placeholder,
                                                 options: [
                        .processor(processor),
                        .scaleFactor(imageScale),
                        .cacheOriginalImage])
                } else {
                    cameraCell.cameraPicture.image = #imageLiteral(resourceName: "CameraDefaultPicture")
                }
            }
            
            
        }
        
        if indexPath.section == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "cameraproperty")!
            
            if indexPath.row == 0 {
                cell.textLabel?.text = "Name"
                cell.detailTextLabel?.text = camera?.name
                cell.accessoryType = (!(camera?.name?.isEmpty ?? true)) ? .none : .disclosureIndicator
            }
            
            if indexPath.row == 1 {
                cell.textLabel?.text = "Lens mount"
                cell.detailTextLabel?.text = camera?.lensMount
                cell.accessoryType = (!(camera?.lensMount?.isEmpty ?? true)) ? .none : .disclosureIndicator
            }
            
            if indexPath.row == 2 {
                cell.textLabel?.text = "Maximum film width"
                cell.accessoryType = (camera?.maximumWidth == nil || camera?.maximumWidth == 0) ? .disclosureIndicator : .none
                cell.detailTextLabel?.text = (camera?.maximumWidth == nil || camera?.maximumWidth == 0) ? "" : (String(camera!.maximumWidth) + "mm")
            }
            
            if indexPath.row == 3 {
                cell.textLabel?.text = "Photos"
                cell.detailTextLabel?.text = nil
                cell.accessoryType = .disclosureIndicator
            }
        }
        
        if indexPath.section == 2 {
            cell = tableView.dequeueReusableCell(withIdentifier: "cameradescription")!
            (cell as! DescriptionCell).delegate = self
            (cell as! DescriptionCell).textView.text = camera?.desc ?? "Description (Optional)"
        }
        
        return cell
    }
    
}

extension CameraDetailViewController: DescriptionCellDelegate {
    func didFinishWritingInTextView(textView: UITextView) {
        camera?.desc = textView.text
    }
}

extension CameraDetailViewController: PhotoPickerDelegate {
    
    func shouldStopCameraRecording() {
        shouldCaptureNewImage = false
    }
    
    
    func processImage(image: CGImage) {
        saveImage(cropImageToSquare(image: image, orientation: .right))
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
    }
    
    fileprivate func cropImageToSquare(image: CGImage, orientation: UIImage.Orientation) -> UIImage {
        //Trying to crop to a square
        let scale = tableView.traitCollection.displayScale
        let size = (image.width > image.height) ? image.height : image.width
        let rectToCrop = CGRect(x: (image.width-size)/2, y: (image.height-size)/2, width: size, height: size)
        
        if let croppedImage = image.cropping(to: rectToCrop) {
            let image = UIImage(cgImage: croppedImage, scale: scale, orientation: orientation)
            
            if cameraCaptureManager.checkForPhotosPermission() {
                UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
            }
            
            return image
        } else {
            return UIImage(cgImage: image, scale: scale, orientation: orientation)
        }
    }
    
    fileprivate func saveImage(_ image: UIImage) {
        if  let rotatedImage = image.rotateImage(),
            let imageData = rotatedImage.pngData() {
            
            if let url = camera?.photo {
                ImageFileManager.shared.delete(file: url) {[weak self] (success, error) in
                    guard let self = self else { return }
                    if error != nil {
                        let alert = UIAlertController(title: "Oops", message: "An error occured saving your camera's picture: \(String(describing: error!))", preferredStyle: .alert)
                        
                        alert.addAction(.init(title: "OK", style: .default, handler: nil))
                        alert.view.tintColor = UIColor(named: "AccentColor")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            
            
            let filename = "Camera-\(UUID()).PNG"
            ImageFileManager.shared.saveFile(with: imageData, filename: filename) {[weak self] (success, url, error) in
                guard let self = self else { return }
                if error != nil {
                    let alert = UIAlertController(title: "Oops", message: "An error occured saving your camera's picture: \(String(describing: error!))", preferredStyle: .alert)
                    
                    alert.addAction(.init(title: "OK", style: .default, handler: nil))
                    alert.view.tintColor = UIColor(named: "AccentColor")
                    self.present(alert, animated: true, completion: nil)
                } else if let url = url {
                    self.camera?.photo = url
                }
            }
        }
    }
    
}

extension CameraDetailViewController { //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editcamerasegue",
            let destVC = segue.destination as? EditCameraDetailTableVC,
            let cell = sender as? UITableViewCell,
            let index = tableView.indexPath(for: cell) {
            destVC.camera = camera
            switch index.row {
            case 0:
                destVC.key = "name"
            case 1:
                destVC.key = "lensMount"
            case 2:
                destVC.key = "maximumWidth"
            default:
                break
            }
        }
        
        if  segue.identifier == "picturesforcamerasegue",
            let destVC = segue.destination as? PhotosViewController {
            destVC.camera = camera
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let cell = tableView.cellForRow(at: indexPath)
            if indexPath.row != 3 {
                performSegue(withIdentifier: "editcamerasegue", sender: cell)
            } else {
                performSegue(withIdentifier: "picturesforcamerasegue", sender: cell)
            }
        }
    }
    
}

extension CameraDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if  let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
            let cgImage = editedImage.cgImage {
            saveImage(cropImageToSquare(image: cgImage, orientation: .up))
            changeShouldCaptureNewImage()
        } else if   let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
            let cgImage = originalImage.cgImage {
            saveImage(cropImageToSquare(image: cgImage, orientation: .up))
            changeShouldCaptureNewImage()
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
