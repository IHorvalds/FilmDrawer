//
//  Film.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 27/07/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import Foundation
import CoreData

public class Film: NSManagedObject {
    
    enum Attribute {
        case Colour
        case Developed
        case ISO
        case Name
        case Width
    }
    
    func isComplete() -> Bool {
        if  self.id      != nil,
            !(self.name?.isEmpty ?? true),
            self.iso     != 0 {
            return true
        }
        
        return false
    }
    
    func isCompleteEnough() -> Bool {
        if  !(self.name?.isEmpty ?? true),
            self.iso     != 0 {
            
            return true
        }
        
        return false
    }
    
    ///Method returns true and gives it an ID if the instance has a name and an iso value different than 0. After this, isComplete() will return true.
    ///If the instance doesn't have a name or the iso is yet unset, it doesn't set an ID and returns false.
    func addIdIfCompleteEnough() -> Bool {
        if  !(self.name?.isEmpty ?? true),
            self.iso     != 0 {
            
            self.id = UUID()
            return true
        }
        
        return false
    }
    
    class func getAllFilms(context: NSManagedObjectContext) -> [Film]? {
        let fetchRequest: NSFetchRequest<Film> = Film.fetchRequest()
        fetchRequest.predicate = NSPredicate(value: true)
        fetchRequest.returnsDistinctResults = true
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastUpdate", ascending: false)]
        
        do {
            let films = try context.fetch(fetchRequest)
            
            return films
        } catch {
            return nil
        }
    }
    
    
    
    class func getFilm(by id: UUID, in context: NSManagedObjectContext) throws -> Film? {
        let fetchRequest: NSFetchRequest<Film> = Film.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            
            let films = try context.fetch(fetchRequest)
            
            if films.count > 1 {
                
                assert(films.count == 1, "Too many films with single UUID. Database error.")
                return films[0]
            }
            
            return films.first
            
        } catch {
            throw error
        }
    }
    
    func getPhotos() -> [Photo] {
        if let photosOn = self.containsPictures {
            let photos = photosOn.map( {$0 as! Photo } )
            return photos
        }
        return []
    }
    
    func getPhoto(number: Int16) -> Photo? {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "belongsTo = %@ && positionInFilm = %d", self, number)
        
        do {
            if let photos = try self.managedObjectContext?.fetch(fetchRequest) {
                if photos.count > 1 {
                    assert(photos.count == 1, "Too many photos with the same film position. Data entry error.")
                    return photos[0]
                }
                return photos.first
            }
            print("no context for the film \(self.id!)")
            return nil
        } catch  {
            print("query error in <Film>.getPhoto(number:)")
            return nil
        }
        
    }
    
    func getPhotosCount() -> Int {
        return self.containsPictures?.count ?? 0
    }
    
    class func getFilms(by attribute: Attribute, value: Any, in context: NSManagedObjectContext) throws -> [Film] {
        let fetchRequest: NSFetchRequest<Film> = Film.fetchRequest()
        
        switch attribute { // i don't wanna write 10 functions with the same logic. Screw that...
        
        case .Colour:
            if let colour = value as? Bool {
                fetchRequest.predicate = NSPredicate(format: "colour == %@", colour)
            } else {
                throw NSError(domain: "Invalid argument", code: -10, userInfo: nil)
            }
        case .Developed:
            if let dev = value as? Bool {
                fetchRequest.predicate = NSPredicate(format: "developed == %@", dev)
            } else {
                throw NSError(domain: "Invalid argument", code: -10, userInfo: nil)
            }
        case .ISO:
            if let iso = value as? Int16 {
                fetchRequest.predicate = NSPredicate(format: "iso == %@", iso)
            } else {
                throw NSError(domain: "Invalid argument", code: -10, userInfo: nil)
            }
        case .Name:
            if let name = value as? String {
                fetchRequest.predicate = NSPredicate(format: "name contains[c] %@", name)
            } else {
                throw NSError(domain: "Invalid argument", code: -10, userInfo: nil)
            }
        case .Width:
            if let width = value as? Int16 {
                fetchRequest.predicate = NSPredicate(format: "width == %@", width)
            } else {
                throw NSError(domain: "Invalid argument", code: -10, userInfo: nil)
            }
        }
        
        
        fetchRequest.returnsDistinctResults = true
        
        do {
            let films = try context.fetch(fetchRequest)
            
            return films
        } catch {
            throw error
        }
    }
}
