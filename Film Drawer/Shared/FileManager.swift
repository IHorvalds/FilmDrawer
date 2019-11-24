//
//  FileManager.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 17/11/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import Foundation

class ImageFileManager {
   
    private let fileManager: FileManager
    private let baseURL: URL?
    
    private init(){
        self.fileManager = FileManager.default
        self.baseURL = try? fileManager.url(for: .documentDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: true)

    }
    
    static let shared = ImageFileManager()
    
    
    public func saveFile(with data: Data, filename: String, handler: @escaping (Bool, URL?, Error?) -> ()) {
        
        guard let baseURL = self.baseURL else {
            handler(false, nil, NSError(domain: kCFURLPathKey as String, code: -1001, userInfo: nil))
            return
        }
        
        do {
            let url = baseURL.appendingPathComponent(filename)
            try data.write(to: url)
            handler(true, url, nil)
        } catch {
            
            handler(false, nil, error)
        }
    }
    
    public func update(with data: Data, for file: URL, handler: @escaping (Bool, URL?, Error?) -> ()) {
        do {
            try data.write(to: file)
            handler(true, file, nil)
        } catch {
            
            handler(false, nil, error)
        }
    }
    
    public func delete(file url: URL, handler: ((Bool, Error?) -> ())?) {
        do {
            try fileManager.removeItem(at: url)
            handler?(true, nil)
        } catch {
            handler?(false, nil)
        }
    }
}
