//
//  EditCameraDetailTableVC.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 28/08/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

class EditCameraDetailTableVC: UITableViewController, UITextFieldDelegate {
    
    var camera: Camera?
    var key: String!
    var keyboardType = UIKeyboardType.default
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        setValue()
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if key == "maximumWidth" {
            keyboardType = .decimalPad
        } else {
            keyboardType = .default
        }
        
        textField.keyboardType = keyboardType
        textField.placeholder = key.titlecased()
        textField.delegate = self
        navigationItem.title = key.titlecased()
    }
    
    fileprivate func setValue() {
        if !(textField.text?.isEmpty ?? true) {
            if  key == "maximumWidth",
                let i = Int16(textField.text!) {
                camera?.setValue(i, forKey: key)
            } else {
                 camera?.setValue(textField.text, forKey: key)
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        setValue()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("hi there")
        setValue()
        
        return true
    }

}
