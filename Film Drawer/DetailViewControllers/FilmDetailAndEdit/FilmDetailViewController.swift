//
//  FilmDetailViewController.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 13/08/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit
import CoreData

class FilmDetailViewController: UITableViewController {
    
    enum ValueToEdit: Int {
        case FilmName = 0
        case Camera = 1
        case Developed = 2
        case Photos = 3
        case Color = 4
        case ISO = 5
        case PushPull = 6
        case ISOShotAt = 7
        case NumberOfFrames = 8
        case Width = 9
    }
    
    //MARK: Model variables
    var film: Film?
    var isAddingFilmToDatabase: Bool = true
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    //MARK: button
    var cancelButton = UIBarButtonItem()
    @IBOutlet weak var doneButtonOutlet: UIBarButtonItem!
    
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        if  let context = container?.viewContext,
            isAddingFilmToDatabase,
            film != nil,
            film!.addIdIfCompleteEnough() {
            
            do {
                try context.save()
                if isModal() {
                    dismiss(animated: true, completion: nil)
                } else {
                    navigationController?.popViewController(animated: true)
                }
            } catch {
                print("Oops. Problem saving.")
                let alert = UIAlertController(title: "Error saving film", message: "Here's the error:/n \(error)", preferredStyle: .alert)
                alert.addAction(.init(title: "Dismiss", style: .default, handler: { [weak self] (_) in
                    self?.dismiss(animated: true, completion: nil)
                }))
            }
            
        } else {
            if  !(film?.addIdIfCompleteEnough() ?? true),
                let film = film {
                container?.viewContext.delete(film)
            }
            
            try? container?.viewContext.save()
            
            if isModal() {
                dismiss(animated: true, completion: nil)
            } else {
                navigationController?.popViewController(animated: true)
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        doneButtonOutlet.isEnabled = (film?.isCompleteEnough() ?? true)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Setup cancel button
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(pressedCancel(_:)))
        
        //Setup film and left bar button item
        if  isAddingFilmToDatabase,
            let context = container?.viewContext {
            film = Film(context: context)
            navigationItem.leftBarButtonItem = cancelButton
        } else {
            navigationItem.title = film?.name
            navigationItem.leftBarButtonItem = nil
        }
        
//        setupSwitchControl()
    }
}

extension FilmDetailViewController { //MARK: Helper functions
    
//    @objc fileprivate func updateFilmColorState() {
//        film?.colour = switchControl.isOn
//    }
    
//    fileprivate func setupSwitchControl() {
//        //MARK: Setup switch control
//        switchControl.frame.origin = .zero
//        switchControl.addTarget(self, action: #selector(updateFilmColorState), for: .valueChanged)
//        switchControl.frame.origin = .zero
//        tableView.reloadData()
//    }
    
    @objc fileprivate func pressedCancel(_ sender: UIBarButtonItem) {
        if  isAddingFilmToDatabase,
            let film = film {
            container?.viewContext.delete(film)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension FilmDetailViewController { //MARK: Display
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "About the roll"
        case 1:
            return "Development and scanning"
        case 2:
            return "Properties"
        case 3:
            return "Extra info"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "Note: You need to give the film a name and an ISO value to add it."
        }
        
        if section == 2 {
            return "The “ISO” refers to the roll’s standard value in ASA rating (eg. 100, 200, 800, etc)."
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return (isAddingFilmToDatabase) ? 2 : 1
        case 1:
            return 2
        case 2:
            if (film?.pushOrPull ?? false) {
                return 6
            }
            return 5
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        switch indexPath.section {
            
        case 0: //about the roll
            if isAddingFilmToDatabase {
                if indexPath.row == 0 {
                    cell = tableView.dequeueReusableCell(withIdentifier: "textcell")!
                    cell.textLabel?.text = "Name"
                    cell.detailTextLabel?.text = film?.name ?? ""
                    if ["", nil].contains(cell.detailTextLabel?.text) {
                        cell.accessoryType = .disclosureIndicator
                    }
                    cell.detailTextLabel?.textColor = secondaryLabelColor
                } else {
                    cell = tableView.dequeueReusableCell(withIdentifier: "textcell")!
                    cell.accessoryType = .disclosureIndicator
                    cell.textLabel?.text = "Camera"
                    cell.detailTextLabel?.text = film?.shotOn?.name ?? "Choose"
                    cell.detailTextLabel?.textColor = secondaryLabelColor
                }
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "textcell")!
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = "Camera"
                cell.detailTextLabel?.text = film?.shotOn?.name ?? "Choose"
                cell.detailTextLabel?.textColor = secondaryLabelColor
            }
            
            
        case 1: //development and scanning
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "checkedcell")!
                cell.textLabel?.text = "Developed"
//                cell.accessoryType = (film?.developed ?? false) ? .checkmark : .none
                let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 20, height: 20)))
                cell.accessoryView = imageView
                imageView.image = (film?.developed ?? false) ? #imageLiteral(resourceName: "􀁣CheckMark") : #imageLiteral(resourceName: "exit")
                (cell.accessoryView as! UIImageView).tintColor = (film?.developed ?? false) ? UIColor.green : secondaryLabelColor
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "checkedcell")!
                cell.textLabel?.text = "Scanned"
                //                cell.accessoryType = (film?.developed ?? false) ? .checkmark : .none
                let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 20, height: 20)))
                cell.accessoryView = imageView
                imageView.image = (film?.scanned ?? false) ? #imageLiteral(resourceName: "􀁣CheckMark") : #imageLiteral(resourceName: "exit")
                (cell.accessoryView as! UIImageView).tintColor = (film?.scanned ?? false) ? UIColor.green : secondaryLabelColor
            }
            
            
        case 2: //properties
            
            switch indexPath.row {
            case 0:
//                print("color")
                
                cell = tableView.dequeueReusableCell(withIdentifier: "checkedcell")!
                cell.textLabel?.text = "Color"
//                switchControl.isOn = film?.colour ?? true
//                cell.accessoryType = (film?.colour ?? false) ? .checkmark : .none
                let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 20, height: 20)))
                cell.accessoryView = imageView
                imageView.image = (film?.colour ?? false) ? #imageLiteral(resourceName: "􀁣CheckMark") : #imageLiteral(resourceName: "exit")
                (cell.accessoryView as! UIImageView).tintColor = (film?.colour ?? false) ? UIColor.green : secondaryLabelColor
            case 1:
//                print("iso")
                cell = tableView.dequeueReusableCell(withIdentifier: "textcell")!
                cell.textLabel?.text = "ISO"
                cell.accessoryType = (film?.iso == nil || film?.iso == 0) ? .disclosureIndicator : .none
                cell.detailTextLabel?.text = (film?.iso == nil || film?.iso == 0) ? "" : String(film!.iso)
                cell.detailTextLabel?.textColor = secondaryLabelColor
                
            case 2:
//                print("push/pull")
                cell = tableView.dequeueReusableCell(withIdentifier: "checkedcell")!
                cell.textLabel?.text = "Push/Pull"
//                cell.accessoryType = (film?.pushOrPull ?? false) ? .checkmark : .none
                let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 20, height: 20)))
                cell.accessoryView = imageView
                imageView.image = (film?.pushOrPull ?? false) ? #imageLiteral(resourceName: "􀁣CheckMark") : #imageLiteral(resourceName: "exit")
                (cell.accessoryView as! UIImageView).tintColor = (film?.pushOrPull ?? false) ? UIColor.green : secondaryLabelColor
                
            case 3:
                if (film?.pushOrPull ?? false) {
//                    print("shot at iso")
                    cell = tableView.dequeueReusableCell(withIdentifier: "textcell")!
                    cell.textLabel?.text = "Shot at ISO"
                    cell.accessoryType = ( film?.isoDevelopedAt == nil || film?.isoDevelopedAt == 0 ) ? .disclosureIndicator : .none
                    cell.detailTextLabel?.text = (film?.isoDevelopedAt == nil || film?.isoDevelopedAt == 0) ? "" : String(film!.isoDevelopedAt)
                    cell.detailTextLabel?.textColor = secondaryLabelColor
                } else {
//                    print("number of frames")
                    cell = tableView.dequeueReusableCell(withIdentifier: "textcell")!
                    cell.textLabel?.text = "Number of frames"
                    cell.accessoryType = (film?.numberOfFrames == nil || film?.numberOfFrames == 0) ? .disclosureIndicator : .none
                    cell.detailTextLabel?.text = (film?.numberOfFrames == nil || film?.numberOfFrames == 0) ? "" : String(film!.numberOfFrames)
                    cell.detailTextLabel?.textColor = secondaryLabelColor
                }
            case 4:
                if (film?.pushOrPull ?? false) {
//                    print("number of frames")
                    cell = tableView.dequeueReusableCell(withIdentifier: "textcell")!
                    cell.textLabel?.text = "Number of frames"
                    cell.accessoryType = (film?.numberOfFrames == nil || film?.numberOfFrames == 0) ? .disclosureIndicator : .none
                    cell.detailTextLabel?.text = (film?.numberOfFrames == nil || film?.numberOfFrames == 0) ? "" : String(film!.numberOfFrames)
                    cell.detailTextLabel?.textColor = secondaryLabelColor
                } else {
//                    print("width")
                    cell = tableView.dequeueReusableCell(withIdentifier: "textcell")!
                    cell.textLabel?.text = "Width"
                    cell.accessoryType = (film?.width == nil || film?.width == 0) ? .disclosureIndicator : .none
                    cell.detailTextLabel?.text = (film?.width == nil || film?.width == 0) ? "" : (String(film!.width) + "mm")
                    cell.detailTextLabel?.textColor = secondaryLabelColor
                }
            case 5:
                if (film?.pushOrPull ?? false) {
//                    print("width")
                    cell = tableView.dequeueReusableCell(withIdentifier: "textcell")!
                    cell.textLabel?.text = "Width"
                    cell.accessoryType = (film?.width == nil || film?.width == 0) ? .disclosureIndicator : .none
                    cell.detailTextLabel?.text = (film?.width == nil || film?.width == 0) ? "" : (String(film!.width) + "mm")
                    cell.detailTextLabel?.textColor = secondaryLabelColor
                }
            default:
                break
            }
        case 3:
//            print("expired")
            cell = tableView.dequeueReusableCell(withIdentifier: "checkedcell")!
            cell.textLabel?.text = "Expired"
//            cell.accessoryType = (film?.expired ?? false) ? .checkmark : .none
            let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 20, height: 20)))
            cell.accessoryView = imageView
            imageView.image = (film?.expired ?? false) ? #imageLiteral(resourceName: "􀁣CheckMark") : #imageLiteral(resourceName: "exit")
            (cell.accessoryView as! UIImageView).tintColor = (film?.expired ?? false) ? UIColor.green : secondaryLabelColor
            
            
        default:
            break
        }
        
        return cell
    }
}
    
extension FilmDetailViewController { //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "selectcameraforfilm",
            let destVC = segue.destination as? SelectCameraTableVC {
            destVC.film = film
            destVC.container = container
            destVC.selectedCamera = film?.shotOn
        }
    }
    
    private func segueToEdit(sender: UITableViewCell) -> Void {
        let editVC = UIStoryboard(name: "FilmDetail", bundle: nil).instantiateViewController(withIdentifier: "editvc") as! EditFilmDetailTableVC
        var shouldShow = true
        
        editVC.film = film
        if let index = tableView.indexPathForSelectedRow {
            switch index.section {
            case 0:
                if  isAddingFilmToDatabase,
                    index.row == 0 { // adding a film and row 0 is it's name
                    editVC.filmProperty = .FilmName
                } else { // segue to a list of all cameras
                    performSegue(withIdentifier: "selectcameraforfilm", sender: sender)
                    shouldShow = false
                }
            case 1:
                if index.row == 1 { // segue to the pictues contained by the film in this VC
                    performSegue(withIdentifier: "seguetophotos", sender: sender)
                    shouldShow = false
                }
            case 2:
                switch index.row {
                case 1:
                    editVC.filmProperty = .ISO
                case 3:
                    if film?.pushOrPull ?? false {
                        editVC.filmProperty = .ISOShotAt
                    } else {
                        editVC.filmProperty = .NumberOfFrames
                    }
                case 4:
                    if film?.pushOrPull ?? false {
                        editVC.filmProperty = .NumberOfFrames
                    } else {
                        editVC.filmProperty = .Width
                    }
                case 5:
                    if film?.pushOrPull ?? false {
                        editVC.filmProperty = .Width
                    } else {
                        shouldShow = false
                    }
                default:
                    shouldShow = false
                }
            default:
                shouldShow = false
            }
        }
        
        if shouldShow {
            self.show(editVC, sender: sender)
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            if indexPath.row == 0 { //developed
                film?.developed = (!(film?.developed ?? false))
            } else { //scanned
                film?.scanned = (!(film?.scanned ?? false))
            }
            
        case 2:
            if indexPath.row == 0 { //colour switch
                film?.colour = (!(film?.colour ?? false))
            }
            if indexPath.row == 2 { //push or pull switch
                film?.pushOrPull = (!(film?.pushOrPull ?? false))
                if film!.pushOrPull {
                    tableView.insertRows(at: [IndexPath(row: 3, section: 2)], with: .top)
                } else {
                    tableView.deleteRows(at: [IndexPath(row: 3, section: 2)], with: .top)
                }
            }
            segueToEdit(sender: tableView.cellForRow(at: indexPath)!)
            
        case 3:
            film?.expired = (!(film?.expired ?? false))
        default:
            segueToEdit(sender: tableView.cellForRow(at: indexPath)!)
        }
        tableView.reloadRows(at: [indexPath], with: .fade)
        film!.lastUpdate = Date()
    }

}
