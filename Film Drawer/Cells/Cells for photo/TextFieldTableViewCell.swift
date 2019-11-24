//
//  TextFieldTableViewCell.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 23/09/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

protocol TextFieldCellDelegate {
    func saveValue(text: String, for key: String)
    func displayFormatWarning(for text: String, format: String)
}

class TextFieldTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    var format: String = String()
    var key: String = String()
    
    var delegate: TextFieldCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.delegate = self
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if  let text = textField.text,
            !text.isEmpty {
            
            if text.range(of: format, options: .regularExpression, range: nil, locale: nil) != nil {
                delegate?.saveValue(text: text, for: key)
                resignFirstResponder()
            } else {
                delegate?.displayFormatWarning(for: text, format: format)
            }
            
        }
    }
    

}
