//
//  Camera.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 27/07/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public class Camera: NSManagedObject {
    
    func addIdIfCompleteEnough() -> Bool {
        if !(name?.isEmpty ?? true) {
            self.id = UUID()
            return true
        }
        
        return false
    }
    
    class func getCamera(by name: String, in context: NSManagedObjectContext) throws -> [Camera] {
        
        let fetchRequest: NSFetchRequest<Camera> = Camera.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name contains[c] %@", name)
        fetchRequest.returnsDistinctResults = true
        
        do {
            
            let cameras = try context.fetch(fetchRequest)
            return cameras
            
        } catch {
            throw error
        }
        
    }
    
    class func getCamera(by id: UUID, in context: NSManagedObjectContext) throws -> Camera? {
        
        let fetchRequest: NSFetchRequest<Camera> = Camera.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            
            let cameras = try context.fetch(fetchRequest)
            
            if cameras.count > 1 {
                
                assert(cameras.count == 1, "Too many cameras with single UUID. Database error.")
                return cameras[0]
            }
            
            return cameras.first
            
        } catch {
            throw error
        }
        
    }
    
    func filmsShotOnCamera() -> [Film] {
        if let films = self.filmsShot {
            let arrayOfFilms = films.map { $0 as! Film }
            return arrayOfFilms
        }
        return []
    }
    
    func getUIImage() -> UIImage? {
        if  let data = self.photo,
            let image = UIImage(data: data) {
            return image
        } else {
            return nil
        }
    }
    
    func hasPhotos(in context: NSManagedObjectContext) -> Bool {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "belongsTo.shotOn = %@", self)
        
        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                return false
            }
            
            return true
        } catch  {
            print(String(describing: error))
            return false
        }
    }
}
