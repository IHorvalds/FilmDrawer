//
//  SelectFilmTableVC.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 04/01/2020.
//  Copyright © 2020 Tudor Croitoru. All rights reserved.
//

import UIKit
import CoreData

class SelectFilmTableVC: UITableViewController {
    
    var fetchedResultsController: NSFetchedResultsController<Film>?
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    var photo: Photo?
    var selectedFilm: Film?
    
    private func updateUI() {
        if let context = container?.viewContext {
            let fetchRequest: NSFetchRequest<Film> = Film.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastUpdate", ascending: false), NSSortDescriptor(key: "name", ascending: true)]
            
            fetchedResultsController = NSFetchedResultsController<Film>(fetchRequest: fetchRequest,
                                                                        managedObjectContext: context,
                                                                        sectionNameKeyPath: nil,
                                                                        cacheName: nil)
            
            do {
                try fetchedResultsController?.performFetch()
                tableView.reloadData()
            } catch {
                print("SelectFilmTableVC: line 33. Error performing fetch.\n")
                print("\(error)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
        if  let camera = selectedFilm,
            let index = fetchedResultsController?.indexPath(forObject: camera) {
            
            tableView.cellForRow(at: index)!.accessoryType = .checkmark
            tableView.selectRow(at: index, animated: false, scrollPosition: .top)
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
        
        guard let cellFilm = fetchedResultsController?.object(at: indexPath) else {
            fatalError("Trying to display cell without a film at its indexPath.")
        }
        
        cell = tableView.dequeueReusableCell(withIdentifier: "selectfilm")!
        
        cell.textLabel?.text = cellFilm.name
        
        if let date = cellFilm.lastUpdate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let dateString = dateFormatter.string(from: date)
            cell.detailTextLabel?.text = "Last updated on \(dateString)"
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        if selectedFilm == fetchedResultsController?.object(at: indexPath) {
            selectedFilm = nil
            cell.accessoryType = .none
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            selectedFilm = fetchedResultsController?.object(at: indexPath)
            cell.accessoryType = .checkmark
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .none
    }

}
