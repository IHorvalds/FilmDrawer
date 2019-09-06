//
//  Photo.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 27/07/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public class Photo: NSManagedObject {
    
    enum Attribute {
        case Aperture
        case Exposure
        case FocalLength
    }
    
    class func getPhotos(by attribute: Photo.Attribute, value: Any, in context: NSManagedObjectContext) throws -> [Photo] {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        switch attribute { // i don't wanna write 10 functions with the same logic. Screw that...
            
        case .Aperture:
            if let aperture = value as? Decimal {
                fetchRequest.predicate = NSPredicate(format: "aperture == %@", aperture as CVarArg)
            } else {
                throw NSError(domain: "Invalid argument", code: -10, userInfo: nil)
            }
        case .Exposure:
            if let exp = value as? String {
                fetchRequest.predicate = NSPredicate(format: "exposure == %@", exp)
            } else {
                throw NSError(domain: "Invalid argument", code: -10, userInfo: nil)
            }
        case .FocalLength:
            if let focal = value as? Int16 {
                fetchRequest.predicate = NSPredicate(format: "focalLength == %@", focal)
            } else {
                throw NSError(domain: "Invalid argument", code: -10, userInfo: nil)
            }
        }
        
        
        fetchRequest.returnsDistinctResults = true
        
        do {
            let photos = try context.fetch(fetchRequest)
            
            return photos
        } catch {
            throw error
        }
    }
    
    class func getPhoto(by id: UUID, in context: NSManagedObjectContext) throws -> Photo? {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            
            let photos = try context.fetch(fetchRequest)
            
            if photos.count > 1 {
                
                assert(photos.count == 1, "Too many cameras with single UUID. Database error.")
                return photos[0]
            }
            
            return photos.first
            
        } catch {
            throw error
        }
    }
    
    func getUIImage() -> UIImage? {
        if  let data = self.file,
            let image = UIImage(data: data) {
            return image
        } else {
            return nil
        }
    }
    
    func addIDIfcompleteEnough() -> Bool {
        if  let _ = self.getUIImage(),
            self.belongsTo != nil {
            
            self.id = UUID()
            return true
        }
        
        return false
    }
    
    //TODO: Find picture by date (idk. Use just month an year? And maybe you have just one or just the other?)
    
    //TODO: When you figure out location, find photos by location
}
