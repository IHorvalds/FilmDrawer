//
//  LocationTableViewCell.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 10/09/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol LocationCellDelegate {
    var shouldTakeNewPicture: Bool { get set }
    func updatePhotoLocation(cell: LocationTableViewCell, location: CLLocation)
}

class LocationTableViewCell: UITableViewCell {

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var location: CLLocation?
    
    let locationManager = CLLocationManager()
    
    var shouldUpdateLocation: Bool = true
    
    var delegate: (UIViewController & LocationCellDelegate)?
    
    let mapViewSpan: Double = 200 // that is 400m
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        checkForLocationServices()
        
    }
    
}

extension LocationTableViewCell: CLLocationManagerDelegate { //helper functions
    
    fileprivate func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    fileprivate func checkForLocationAutorization() {
        
        if [CLAuthorizationStatus.notDetermined, CLAuthorizationStatus.authorizedWhenInUse, CLAuthorizationStatus.authorizedAlways].contains(CLLocationManager.authorizationStatus()) {
            //this executes only when we have permission for when in use, always or when we don't know if we're allowed yet.
            //Thus, we only show the permission alerts once.
            
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted:
                //show alert asking mommy for permission
                showPermissionAlert()
            case .denied:
                //show alert and give button for settings app
                showPermissionAlert()
            case .authorizedWhenInUse:
                //good to go
                if shouldUpdateLocation {
                    // go to user's current position
                    setCurrentLocation()
                    displayLocation()
                } else {
                    // just display the location
                    displayLocation()
                }
            default:
                break
            }
            
        }
    }
    
    fileprivate func showPermissionAlert() {
        let alert = UIAlertController(title: "Location access error", message: "You can still add location metadata to your picture by dragging the map onto the desired place. But it's easier to get it automatically. Please consider allowing access to your location.", preferredStyle: .alert)
        
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
        
        alert.addAction(.init(title: "Keep no access", style: .cancel, handler: nil))
        
        delegate?.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func checkForLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkForLocationAutorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        
        setCurrentLocation(lastLocation)
        displayLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkForLocationAutorization()
    }
    
    fileprivate func displayLocation() {
        if let coordinates = location?.coordinate {
            let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: mapViewSpan, longitudinalMeters: mapViewSpan)
            mapView.setRegion(region, animated: true)
        }
    }
    
    fileprivate func setCurrentLocation(_ withLocation: CLLocation? = nil) {
        if shouldUpdateLocation {
            //if we should update the location shown on the map (that is when we're still taking a picture),
            //then the self's location will be set to the current location from locationManager.
            
            //if the parameter is set to nil, then we get the location from the locationManager, otherwise we set it to the
            //location in the parameter
            location = (withLocation == nil) ? locationManager.location : withLocation
        }
    }
}
