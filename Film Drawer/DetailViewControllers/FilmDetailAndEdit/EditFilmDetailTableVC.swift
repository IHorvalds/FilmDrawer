//
//  EditFilmDetailTableVC.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 22/08/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

class EditFilmDetailTableVC: UITableViewController, UITextFieldDelegate {
    
    var filmProperty: FilmDetailViewController.ValueToEdit?
    var keyboardType: UIKeyboardType = .default
    var film: Film?

    @IBOutlet weak var textFieldOutlet: UITextField!
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        changeFilmProperty(sender: textFieldOutlet)
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldOutlet.delegate = self
        textFieldOutlet.becomeFirstResponder()
        
        if let property = filmProperty {
            var title = String()
            
            switch property {
                
            case .FilmName:
                title = "Film name"
                keyboardType = .default
            case .ISO:
                title = "Film's ISO"
                keyboardType = .numberPad
            case .ISOShotAt:
                title = "ISO shot at"
                keyboardType = .numberPad
            case .NumberOfFrames:
                title = "Number of frames"
                keyboardType = .numberPad
            case .Width:
                title = "Width"
                keyboardType = .numberPad
            default:
                title = "Wrong screen? Oops..."
            }
            
            navigationItem.title = title
            textFieldOutlet.placeholder = title
            textFieldOutlet.keyboardType = keyboardType
        }
    }
    
    private func changeFilmProperty(sender: UITextField) {
        if  let property = filmProperty,
            !(sender.text?.isEmpty ?? true) {
            switch property {
            case .FilmName:
                film?.name = sender.text
            case .ISO:
                film?.iso = Int16(sender.text!) ?? 0
            case .ISOShotAt:
                film?.isoDevelopedAt = Int16(sender.text!) ?? 0
            case .NumberOfFrames:
                film?.numberOfFrames = Int16(sender.text!) ?? 36
            case .Width:
                film?.width = Int16(sender.text!) ?? 35
            default:
                break
                
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        changeFilmProperty(sender: textField)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        changeFilmProperty(sender: textField)
    }

}
