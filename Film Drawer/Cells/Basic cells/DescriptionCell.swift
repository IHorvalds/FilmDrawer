//
//  DescriptionCell.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 27/08/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

protocol DescriptionCellDelegate {
    func didFinishWritingInTextView(textView: UITextView)
}

class DescriptionCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    var delegate: DescriptionCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.delegate = self
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 16)
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        delegate?.didFinishWritingInTextView(textView: textView)
        resignFirstResponder()
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.didFinishWritingInTextView(textView: textView)
        resignFirstResponder()
    }

}
