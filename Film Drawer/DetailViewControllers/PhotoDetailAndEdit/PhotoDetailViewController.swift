//
//  PhotoDetailViewController.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 13/08/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class PhotoDetailViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    let imagePicker = UIImagePickerController()
    var photo: Photo?
    var film: Film?
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer

    var isAddingNewPicture: Bool = true
    var shouldTakeNewPicture: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButton))
        
        if  isAddingNewPicture,
            let context = container?.viewContext {
            photo = Photo(context: context)
        }
        
        //register cells from nibs
        tableView.register(UINib(nibName: "PictureTableViewCell", bundle: nil), forCellReuseIdentifier: "picturecell")
        tableView.register(UINib(nibName: "LocationTableViewCell", bundle: nil), forCellReuseIdentifier: "mapcell")
    }

}

extension PhotoDetailViewController: PhotoDetailControllerDelegate {
    
    func savePicture(cell: PictureTableViewCell, picture: CGImage) {
        var rectToCrop = CGRect()
        let ratio = 1.5
        let imageScale = tableView.traitCollection.displayScale
        
        if picture.width >= picture.height { //if it's taller than wide (it's rotated left)
            let width = picture.height
            let height = Double(width) / ratio
            
            let origin = CGPoint(x: (Double(picture.width) - height)/2, y: 0)
            
            rectToCrop.origin = origin
            rectToCrop.size.width = CGFloat(height)
            rectToCrop.size.height = CGFloat(width)
        } else { // if it's wider than tall
            let height = picture.width
            let width = Double(height) * ratio
            
            let origin = CGPoint(x: 0, y: (Double(picture.height) - width)/2)
            
            rectToCrop.origin = origin
            rectToCrop.size.width = CGFloat(height)
            rectToCrop.size.height = CGFloat(width)
        }
        
        
        if let image = picture.cropping(to: rectToCrop) {
            let uiImage = UIImage(cgImage: image, scale: imageScale, orientation: .right)
//            photo?.file = uiImage.jpegData(compressionQuality: 0.7)
            photo?.dateTaken = Date()
            photo?.isFinalPicture = false
            
            
            let size = cell.pictureView.bounds.size
            let scale = tableView.traitCollection.displayScale
            
//            DispatchQueue.global(qos: .userInitiated).async {
//                //downsample on a background queue
//                if  let data = self.photo?.file,
//                    let image = UIImage.downsample(imageWithData: data, to: size, scale: scale) {
//                    DispatchQueue.main.async {
//                        //and display on the main queue
//                        cell.pictureView.image = image
//                    }
//                }
//            }
            
        }
    }
    
    func generateTags(cell: PictureTableViewCell, for image: CGImage) {
        print("tell cell to generate tags")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Picked a picture from the library")
    }
}

extension PhotoDetailViewController: LocationCellDelegate { //MARK: Location cell delegate functions
    func updatePhotoLocation(cell: LocationTableViewCell, location: CLLocation) {
        print("Must convert \(location) into Data and assing it to photo.location")
    }
    
    
}

extension PhotoDetailViewController { //MARK: Table view delegate and data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1: //film, aperture, exposure, focal length, position in film
            return 5
        case 2: //either 1 -> generate tags; or 2 -> generate tags, View tags
            let isMissingTags = photo?.desc?.isEmpty ?? true
            return (isMissingTags) ? 1 : 2
        default: //section 0 and 3: photo, map
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNonzeroMagnitude
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Image metadata"
        }
        
        if section == 3 {
            return "Location"
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0, indexPath.section == 0 {
            return UIScreen.main.bounds.width / 1.5
        }
        
        if indexPath.section == 3, indexPath.row == 0 {
            return UIScreen.main.bounds.width
        }
        
        return 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        switch indexPath.section {
        case 0: //picture preview
            cell = tableView.dequeueReusableCell(withIdentifier: "picturecell")!
            let pictureCell = cell as! PictureTableViewCell
            
            pictureCell.delegate = self
            pictureCell.shouldCaptureNewImage = (photo?.file == nil)
            
//            if !pictureCell.shouldCaptureNewImage {
//                let size = pictureCell.pictureView.bounds.size
//                let scale = tableView.traitCollection.displayScale
//
//                DispatchQueue.global(qos: .userInitiated).async {
//                    //downsample on a background queue
//                    if  let data = self.photo?.file,
//                        let image = UIImage.downsample(imageWithData: data, to: size, scale: scale) {
//                        DispatchQueue.main.async {
//                            //and display on the main queue
//                            pictureCell.pictureView.image = image
//                        }
//                    }
//                }
//            }
            
        case 1: //text cells
            switch indexPath.row {
            case 0: //film cell
                cell = tableView.dequeueReusableCell(withIdentifier: "textcell")!
                cell.textLabel?.text = "Film"
                cell.detailTextLabel?.text = (photo?.belongsTo != nil) ? photo?.belongsTo?.name : "Choose"
                if #available(iOS 13.0, *) {
                    cell.detailTextLabel?.textColor = .secondaryLabel
                } else {
                    cell.detailTextLabel?.textColor = #colorLiteral(red: 0.4235294118, green: 0.4235294118, blue: 0.4235294118, alpha: 1)
                }
                cell.accessoryType = .disclosureIndicator
                
                
            case 1: //f-stop cell
//                cell = tableView.dequeueReusableCell(withIdentifier: "fstopcell") as! TextFieldTableViewCell
//                cell.textLabel?.text = "Aperture"
//                cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
//                (cell as! TextFieldTableViewCell).format = "[-+]?[0-9]*\\.?[0-9]+"
//                (cell as! TextFieldTableViewCell).key = "aperture"
//                (cell as! TextFieldTableViewCell).delegate = self
                cell = tableView.dequeueReusableCell(withIdentifier: "textcell")!
                cell.textLabel?.text = "Aperture"
                cell.detailTextLabel?.textColor = secondaryLabelColor
                if  let aperture = photo?.aperture,
                    aperture != 0 {
                     cell.detailTextLabel?.text = "f/\(String(describing: aperture))"
                } else {
                     cell.detailTextLabel?.text = ""
                }
                cell.accessoryType = .disclosureIndicator
               
                
            case 2: //exposure time cell
//                cell = tableView.dequeueReusableCell(withIdentifier: "editabletextcell") as! TextFieldTableViewCell
//                cell.textLabel?.text = "Exposure (s)"
//                cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
//                (cell as! TextFieldTableViewCell).format = "[-+]?[0-9]*\\.?[0-9]+"
//                (cell as! TextFieldTableViewCell).key = "exposure"
//                (cell as! TextFieldTableViewCell).delegate = self
//                (cell as! TextFieldTableViewCell).textField.placeholder = "1/125"
                cell = tableView.dequeueReusableCell(withIdentifier: "textcell")!
                cell.textLabel?.text = "Exposure"
                cell.detailTextLabel?.textColor = secondaryLabelColor
                if  let exposure = photo?.exposure,
                    !exposure.isEmpty {
                    cell.detailTextLabel?.text = String(describing: exposure)
                } else {
                    cell.detailTextLabel?.text = ""
                }
                cell.accessoryType = .disclosureIndicator
                
            case 3: //focal length time cell
//                cell = tableView.dequeueReusableCell(withIdentifier: "editabletextcell") as! TextFieldTableViewCell
//                cell.textLabel?.text = "Focal length"
//                cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
//                (cell as! TextFieldTableViewCell).format = "some regex"
//                (cell as! TextFieldTableViewCell).key = "focalLength"
//                (cell as! TextFieldTableViewCell).delegate = self
//                (cell as! TextFieldTableViewCell).textField.placeholder = "50mm"
                cell = tableView.dequeueReusableCell(withIdentifier: "textcell")!
                cell.textLabel?.text = "Focal length"
                cell.detailTextLabel?.textColor = secondaryLabelColor
                if  let focal = photo?.focalLength,
                    focal != 0 {
                    cell.detailTextLabel?.text = "\(String(describing: focal))mm"
                } else {
                    cell.detailTextLabel?.text = ""
                }
                cell.accessoryType = .disclosureIndicator
                
            case 4: //can only be frame number
                cell = tableView.dequeueReusableCell(withIdentifier: "textcell")!
                cell.textLabel?.text = "Frame #"
                cell.detailTextLabel?.text = String(describing: (photo?.positionInFilm ?? 0))
                cell.detailTextLabel?.textColor = secondaryLabelColor
                cell.accessoryType = .disclosureIndicator
            
            default:
                break
            }
            
        case 2: //tags cells
            switch indexPath.row {
            case 0: //Generate tags cell
                cell = tableView.dequeueReusableCell(withIdentifier: "textcell")!
                cell.textLabel?.text = "Generate tags"
                cell.textLabel?.textColor = .systemBlue
                cell.detailTextLabel?.text = ""
                cell.accessoryType = .none
                let isMissingTags = photo?.desc?.isEmpty ?? true
                if !isMissingTags {
                    let imageView = UIImageView(image: #imageLiteral(resourceName: "􀁣CheckMark"))
                    imageView.frame.origin = .zero
                    imageView.tintColor = .systemGreen
                    cell.accessoryView = imageView
                } else {
                    cell.textLabel?.textColor = .lightGray
                }
            case 1: //position in film cell or view tags cell (if there are no tags else if there are tags, respectively)
                cell = tableView.dequeueReusableCell(withIdentifier: "textcell")!
                cell.textLabel?.text = "View tags"
                cell.detailTextLabel?.text = ""
                cell.accessoryType = .disclosureIndicator
            default:
                break
                }
            
        case 3: //mapview
            cell = tableView.dequeueReusableCell(withIdentifier: "mapcell")!
            let mapCell = cell as! LocationTableViewCell
            mapCell.shouldUpdateLocation = (photo?.location == nil)
            mapCell.delegate = self
            //TODO: convert photo?.location into CLLocation instance and mapCell.location = convertedValue
            
        
        default:
            break
        }
        
        return cell
    }
    
}

extension PhotoDetailViewController { //MARK: Navigation
    
    fileprivate func segueToVC(indexPath: IndexPath, sender: UITableViewCell) {
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

extension PhotoDetailViewController { // Helper functions
    
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
