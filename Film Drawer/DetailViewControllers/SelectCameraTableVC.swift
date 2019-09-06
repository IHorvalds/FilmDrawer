//
//  SelectCameraTableVC.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 25/08/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit
import CoreData

class SelectCameraTableVC: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var fetchedResultsController: NSFetchedResultsController<Camera>?
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    var film: Film?
    var selectedCamera: Camera?
    
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        
        film?.shotOn = selectedCamera
        if let film = film {
            selectedCamera?.addToFilmsShot(film)
        }
        navigationController?.popViewController(animated: true)
        
    }
    
    private func updateUI() {
        if let context = container?.viewContext {
            let fetchRequest: NSFetchRequest<Camera> = Camera.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false), NSSortDescriptor(key: "name", ascending: true)]
            
            fetchedResultsController = NSFetchedResultsController<Camera>(fetchRequest: fetchRequest,
                                                                        managedObjectContext: context,
                                                                        sectionNameKeyPath: nil,
                                                                        cacheName: nil)
            
            do {
                try fetchedResultsController?.performFetch()
                tableView.reloadData()
            } catch {
                print("SelectCameraTableVC: line 40. Error performing fetch.\n")
                print("\(error)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
        if  let camera = selectedCamera,
            let index = fetchedResultsController?.indexPath(forObject: camera) {
            print("???")
            tableView.cellForRow(at: index)!.accessoryType = .checkmark
            tableView.selectRow(at: index, animated: false, scrollPosition: .top)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        film?.shotOn = selectedCamera
        if let film = film {
            selectedCamera?.addToFilmsShot(film)
        }
        
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count >= 1 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        guard let cellCamera = fetchedResultsController?.object(at: indexPath) else {
            fatalError("Trying to display cell without a camera at its indexPath.")
        }
        
        cell = tableView.dequeueReusableCell(withIdentifier: "selectcamera")!
        cell.imageView?.image = cellCamera.getUIImage() ?? #imageLiteral(resourceName: "CameraIcon")
        cell.textLabel?.text = cellCamera.name
        
        if let date = cellCamera.dateAdded {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let dateString = dateFormatter.string(from: date)
            cell.detailTextLabel?.text = "Added on \(dateString)"
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        if selectedCamera == fetchedResultsController?.object(at: indexPath) {
            selectedCamera = nil
            cell.accessoryType = .none
        } else {
            selectedCamera = fetchedResultsController?.object(at: indexPath)
            cell.accessoryType = .checkmark
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .none
    }
}
