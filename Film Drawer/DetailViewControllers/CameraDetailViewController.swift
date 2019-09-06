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

class CameraDetailViewController: UITableViewController {
    
    let imagePicker = UIImagePickerController()
    
    var camera: Camera?
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    //Camera Capture vars
    var previewLayer:AVCaptureVideoPreviewLayer!
    var captureDevice: AVCaptureDevice!
    var capturePhotoOutput: AVCapturePhotoOutput!
    var session: AVCaptureSession!
    lazy var shouldCaptureNewImage: Bool = true

    lazy var isAddingNewCamera: Bool = true
    
    var doneButton = UIBarButtonItem()
    var cancelButton = UIBarButtonItem()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed(_:)))
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed(_:)))
        
        imagePicker.delegate = self
        
        navigationItem.title = (camera == nil) ? "Add camera" : camera?.name
        
        if  isAddingNewCamera,
            let context = container?.viewContext {
            camera = Camera(context: context)
            navigationItem.leftBarButtonItem = cancelButton
        }
        
        navigationItem.rightBarButtonItem = doneButton
    }
    
    deinit {
        camera = nil
        previewLayer = nil
        session = nil
        captureDevice = nil
        capturePhotoOutput = nil
    }
}

extension CameraDetailViewController { //Helper functions
    
    @objc fileprivate func cancelButtonPressed(_ sender: UIBarButtonItem) {
        if  !(camera?.addIdIfCompleteEnough() ?? true),
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
    
    fileprivate func alertForPermissions(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message, preferredStyle: .alert)
        
        alert.addAction(.init(title: "Review access", style: .default, handler: { (_) in
            //take user to settings
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }))
        
        alert.addAction(.init(title: "Keep no access", style: .cancel, handler: { [weak self] (_) in
            guard let self = self else { return }
            self.shouldCaptureNewImage = false
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func checkAccessForCamera(_ cameraCell: CameraPictureCell) {
        //Do we have permission for camera?
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.setupAVCapture(sender: cameraCell)
                } else {
                    self.alertForPermissions(title: "Camera access error", message: "Camera access is necessary for taking preview pictures of your shots and, optionally, of your cameras.")
                }
            }
        case .restricted:
            alertForPermissions(title: "Camera access error", message: "Camera access is necessary for taking preview pictures of your shots and, optionally, of your cameras.")
        case .denied:
            alertForPermissions(title: "Camera access error", message: "Camera access is necessary for taking preview pictures of your shots and, optionally, of your cameras.")
        case .authorized:
            setupAVCapture(sender: cameraCell)
        default:
            break
        }
    }
    
    fileprivate func checkForPhotosPermission() -> Bool {
        var authorized = false
        
        switch PHPhotoLibrary.authorizationStatus(){
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized {
                    self.imagePicker.sourceType = .photoLibrary
                    authorized = true
                } else {
                    self.alertForPermissions(title: "Photo library access error", message: "Please allow access to your photo library in order to choose a picture from there.")
                }
            }
        case .restricted:
            alertForPermissions(title: "Photo library access error", message: "Please allow access to your photo library in order to choose a picture from there.")
        case .denied:
            alertForPermissions(title: "Photo library access error", message: "Please allow access to your photo library in order to choose a picture from there.")
        case .authorized:
            imagePicker.sourceType = .photoLibrary
            authorized = true
        default:
            print("eh?")
        }
        
        return authorized
    }
    
    @objc fileprivate func capturePicture() {
        //Capture the image and add it to the database
        print("Snap!")
        
        let captureSettings: AVCapturePhotoSettings
        if capturePhotoOutput.availablePhotoCodecTypes.contains(.hevc) {
            captureSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            captureSettings = AVCapturePhotoSettings()
        }
        capturePhotoOutput.capturePhoto(with: captureSettings, delegate: self)
        
        shouldCaptureNewImage = false
    }
    
    @objc fileprivate func chooseFromGallery() {
        if checkForPhotosPermission() {
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
                
                checkAccessForCamera(cameraCell)
            } else {
                let image = camera?.getUIImage()
                cameraCell.cameraPicture.image = image ?? #imageLiteral(resourceName: "CameraDefaultPictureLarge")
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

extension CameraDetailViewController:  AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    
    func setupAVCapture(sender: CameraPictureCell) {
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                        return
        }
        captureDevice = device
        beginSession(previewView: sender.cameraPreview)
    }
    
    func beginSession(previewView: UIView) {
        var deviceInput: AVCaptureDeviceInput!
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            guard deviceInput != nil else {
                print("error: cant get deviceInput")
                return
            }
            
            if session.canAddInput(deviceInput) {
                session.addInput(deviceInput)
            }
            
            capturePhotoOutput = AVCapturePhotoOutput()
            capturePhotoOutput.isHighResolutionCaptureEnabled = true
            
            if session.canAddOutput(capturePhotoOutput) {
                session.addOutput(capturePhotoOutput)
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            
            DispatchQueue.main.async {
                let rootLayer: CALayer = previewView.layer
                rootLayer.masksToBounds = true
                self.previewLayer.frame = rootLayer.bounds
                rootLayer.addSublayer(self.previewLayer)
            }
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.startRunning()
            }
        } catch {
            deviceInput = nil
            print("error: \(error.localizedDescription)")
        }
    }
    
    // clean up AVCapture
    func stopCamera() {
        session.stopRunning()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if  error == nil,
            let imageData = photo.cgImageRepresentation()?.takeUnretainedValue() {
            //Trying to crop to a square
            let size = (imageData.width > imageData.height) ? imageData.height : imageData.width
            let rectToCrop = CGRect(x: (imageData.width-size)/2, y: (imageData.height-size)/2, width: size, height: size)
            if let croppedImage = imageData.cropping(to: rectToCrop) {
                camera?.photo = UIImage(cgImage: croppedImage, scale: 1, orientation: .right).jpegData(compressionQuality: 0.9)
            } else {
                //if we can't, then just save the whole picture
                camera?.photo = photo.fileDataRepresentation()
            }
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        } else {
            print("\(String(describing: error))")
        }
        stopCamera()
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
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            camera?.photo = editedImage.jpegData(compressionQuality: 0.9)
            changeShouldCaptureNewImage()
        } else {
            if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                camera?.photo = originalImage.jpegData(compressionQuality: 0.9)
                changeShouldCaptureNewImage()
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
