//
//  CameraCaptureManager.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 18/11/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import Foundation
import AVFoundation
import Photos
import UIKit

protocol PhotoPickerDelegate: class {
    var imagePicker: UIImagePickerController { get }
    func processImage(image: CGImage)
    func shouldStopCameraRecording()
}

class CameraCaptureManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    
    
    //Camera Capture vars
    var previewLayer: AVCaptureVideoPreviewLayer!
    var captureDevice: AVCaptureDevice!
    var capturePhotoOutput: AVCapturePhotoOutput!
    var session: AVCaptureSession!
    
    weak var delegate: (UITableViewController & PhotoPickerDelegate)?
    
    static let shared = CameraCaptureManager()
    
    private override init() { }
    
    public func setupCameraOutput(previewView: UIView) {
        checkAccessForCamera(previewView: previewView)
    }
    
    public func capturePicture() {
        //Capture the image and add it to the database
        print("Snap!")
        
        let captureSettings: AVCapturePhotoSettings
        if capturePhotoOutput.availablePhotoCodecTypes.contains(.hevc) {
            captureSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            captureSettings = AVCapturePhotoSettings()
        }
        if let connection = capturePhotoOutput.connection(with: .video) {
            connection.videoOrientation = .portrait
        }
        capturePhotoOutput.capturePhoto(with: captureSettings, delegate: self)
    }
    
    fileprivate func checkAccessForCamera(previewView: UIView) {
        //Do we have permission for camera?
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if granted {
                        self.setupAVCapture(previewView: previewView)
                    } else {
                        self.alertForPermissions(title: "Camera access error", message: "Camera access is necessary for taking preview pictures of your shots and, optionally, of your cameras.")
                    }
                }
            }
        case .restricted:
            alertForPermissions(title: "Camera access error", message: "Camera access is necessary for taking preview pictures of your shots and, optionally, of your cameras.")
        case .denied:
            alertForPermissions(title: "Camera access error", message: "Camera access is necessary for taking preview pictures of your shots and, optionally, of your cameras.")
        case .authorized:
            setupAVCapture(previewView: previewView)
        default:
            break
        }
    }
    
    public func checkForPhotosPermission() -> Bool {
        var authorized = false
        
        switch PHPhotoLibrary.authorizationStatus(){
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                DispatchQueue.main.async {
                    if status == .authorized {
                        self.delegate?.imagePicker.sourceType = .photoLibrary
                        authorized = true
                    } else {
                        self.alertForPermissions(title: "Photo library access error", message: "Please allow access to your photo library in order to choose a picture from there.")
                    }
                }
            }
        case .restricted:
            alertForPermissions(title: "Photo library access error", message: "Please allow access to your photo library in order to choose a picture from there.")
        case .denied:
            alertForPermissions(title: "Photo library access error", message: "Please allow access to your photo library in order to choose a picture from there.")
        case .authorized:
            delegate?.imagePicker.sourceType = .photoLibrary
            authorized = true
        default:
            print("eh?")
        }
        
        return authorized
    }
    
    private func setupAVCapture(previewView: UIView) {
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                        return
        }
        captureDevice = device
        beginSession(previewView: previewView)
    }
    
    private func beginSession(previewView: UIView) {
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
    private func stopCamera() {
        session.stopRunning()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if  error == nil,
            let imageData = photo.cgImageRepresentation()?.takeUnretainedValue() {
            delegate?.processImage(image: imageData)
        } else {
            print("\(String(describing: error))")
        }
        stopCamera()
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
            self.delegate?.shouldStopCameraRecording()
            self.delegate?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            
        }))
        alert.view.tintColor = UIColor(named: "AccentColor")
        delegate?.present(alert, animated: true, completion: nil)
    }
    
}
