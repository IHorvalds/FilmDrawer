//
//  PhotoDetailViewController.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 13/08/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit
import CoreData

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
