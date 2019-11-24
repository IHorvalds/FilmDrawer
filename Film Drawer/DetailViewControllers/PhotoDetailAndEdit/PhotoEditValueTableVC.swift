//
//  PhotoEditValueTableVC.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 30/09/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

class PhotoEditValueTableVC: UITableViewController {
    
    var photo: Photo?
    
    let apertures = [1, 1.4, 1.7, 2, 2.8, 4, 5.6, 8, 11, 16, 22]
    let exposures = ["1/4000", "1/2000", "1/1000", "1/500", "1/250",
                     "1/125", "1/60", "1/30", "1/15", "1/8", "1/4",
                     "1/2", "1", "2", "4", "8"]
    var key: String!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if key == "focalLength" {
            return 1
        }
        
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if key == "aperture" {
                return apertures.count
            }
            
            if key == "focalLength" {
                return 1
            }
            
            if key == "exposure" {
                return exposures.count
            }
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if indexPath.section == 0 && key != "focalLength"{
            cell = tableView.dequeueReusableCell(withIdentifier: "valuecell")!
            
            if key == "aperture" {
                cell.textLabel?.text = String(describing: apertures[indexPath.row])
            }
            
            if key == "exposure" {
                cell.textLabel?.text = exposures[indexPath.row]
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "editvaluecell") as! TextFieldTableViewCell
            (cell as! TextFieldTableViewCell).delegate = self
            
            if key == "focalLength" {
                (cell as! TextFieldTableViewCell).format = "[0-9]*\\.?[0-9]+"
            }
            
            if key == "aperture" {
                (cell as! TextFieldTableViewCell).format = "[0-9]*\\.?[0-9]+"
            }
            
            if key == "exposure" {
                (cell as! TextFieldTableViewCell).format = "[0-9]*[\\./]?[0-9]+"
            }
        }
        
        return cell
    }

}

extension PhotoEditValueTableVC: TextFieldCellDelegate {
    func saveValue(text: String, for key: String) {
        if  key == "aperture",
            let aperture = Decimal(string: text) {
            photo?.setValue(aperture, forKey: key)
        } else {
            photo?.setValue(text, forKey: key)
        }
    }
    
    func displayFormatWarning(for text: String, format: String) {
        let alert = UIAlertController(title: "Error saving", message: "\(text) doesn't match the necessary regex \(format). Please review the data you entered.", preferredStyle: .alert)
        
        alert.addAction(.init(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    
}
