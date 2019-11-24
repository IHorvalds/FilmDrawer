//
//  PictureTableViewCell.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 08/09/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

protocol PhotoDetailControllerDelegate {
    var shouldTakeNewPicture: Bool { get set }
    func savePicture(cell: PictureTableViewCell, picture: CGImage)
    func generateTags(cell: PictureTableViewCell, for image: CGImage)
}

class PictureTableViewCell: UITableViewCell { //we're gonna be treating this as a view controller from the AV stuff's perspective and a view from the PhotoDetailVC's perspective

    enum ButtonStatus {
        case Active
        case Chosen
    }
    
    //Outlets
    @IBOutlet weak var previewButton: RoundedButton!
    
    @IBOutlet weak var takePhotoButton: UIButton!
    
    @IBOutlet weak var choosePhotoButton: RoundedButton!
    
    @IBOutlet weak var pictureView: UIImageView!
    
    @IBOutlet weak var previewView: UIView!
    
    let buttonColors = [ButtonStatus.Chosen: UIColor.darkGray,
                        ButtonStatus.Active: #colorLiteral(red: 1, green: 0.8, blue: 0, alpha: 1)]
    
    //AV vars
    var previewLayer:AVCaptureVideoPreviewLayer!
    var captureDevice: AVCaptureDevice!
    var capturePhotoOutput: AVCapturePhotoOutput!
    var session: AVCaptureSession!
    var shouldCaptureNewImage: Bool = true {
        didSet {
            pictureView.isHidden = shouldCaptureNewImage
            previewView.isHidden = !shouldCaptureNewImage
            
            if shouldCaptureNewImage {
                setupAVCapture()
            }
            
            delegate?.shouldTakeNewPicture = shouldCaptureNewImage
        }
    }
    
    //image picker
    let imagePicker = UIImagePickerController()
    
    //delegate
    var delegate: (UIViewController & PhotoDetailControllerDelegate & UIImagePickerControllerDelegate & UINavigationControllerDelegate)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        imagePicker.delegate = delegate
        
        setupButtons()
    }
    
}

extension PictureTableViewCell { // Helper functions
    
    fileprivate func setupButtons() {
        takePhotoButton.addTarget(self, action: #selector(capturePicture), for: .touchUpInside)
        takePhotoButton.addTarget(self, action: #selector(animateButtonTap), for: .touchUpInside)
        previewButton.addTarget(self, action: #selector(previewButtonTapped(sender:)), for: .touchUpInside)
        choosePhotoButton.addTarget(self, action: #selector(chooseButtonTapped(sender:)), for: .touchUpInside)
    }
    
    @objc fileprivate func previewButtonTapped(sender: RoundedButton) {
        
    }
    
    @objc func animateButtonTap() {
        UIView.animateKeyframes(withDuration: 0.2,
                                delay: 0,
                                options: [.calculationModeLinear],
                                animations: {
                                    UIView.addKeyframe(withRelativeStartTime: 0.0,
                                                       relativeDuration: 1/2) { [weak self] in
                                                        guard let self = self else { return }
                                                        self.takePhotoButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                                    }
                                    
                                    UIView.addKeyframe(withRelativeStartTime: 1/2,
                                                       relativeDuration: 1/2) { [weak self] in
                                                        guard let self = self else { return }
                                                        self.takePhotoButton.transform = .identity
                                    }
        }, completion: nil)
    }
    
    @objc fileprivate func chooseButtonTapped(sender: RoundedButton) {
        stopCamera()
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
            
        }))
        
        delegate?.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func checkAccessForCamera(_ cameraCell: CameraPictureCell) {
        //Do we have permission for camera?
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.setupAVCapture()
                } else {
                    self.alertForPermissions(title: "Camera access error", message: "Camera access is necessary for taking preview pictures of your shots and, optionally, of your cameras.")
                }
            }
        case .restricted:
            alertForPermissions(title: "Camera access error", message: "Camera access is necessary for taking preview pictures of your shots and, optionally, of your cameras.")
        case .denied:
            alertForPermissions(title: "Camera access error", message: "Camera access is necessary for taking preview pictures of your shots and, optionally, of your cameras.")
        case .authorized:
            setupAVCapture()
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
    
    @objc fileprivate func chooseFromGallery() {
        if checkForPhotosPermission() {
            delegate?.present(imagePicker, animated: true, completion: nil)
        }
    }
}

extension PictureTableViewCell: AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate { // AV stuff
    
    func setupAVCapture() {
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            return
        }
        captureDevice = device
        beginSession(previewView: previewView)
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
        
        if error == nil {
            //Tell the delegate to generate a description for the image
            if  let cgImage = photo.cgImageRepresentation()?.takeUnretainedValue() {
                pictureView.image = UIImage(cgImage: cgImage)
                
                delegate?.generateTags(cell: self, for: cgImage)
                //Save
                delegate?.savePicture(cell: self, picture: cgImage)
            }
            //we're not saving to the library here because we're gonna export the whole film once it's done
        } else {
            print(String(describing: error))
        }
        
        //stop camera when we finish saving it
        stopCamera()
    }
}
