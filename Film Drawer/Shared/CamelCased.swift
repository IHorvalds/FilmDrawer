//
//  CamelCased.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 28/08/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import Foundation

extension String {
    
//    mutating public func camelCaseToCapitalisedWords() -> String {
//        self.forEach { (c) in
//            if c.isUppercase {
////                self.insert(" ", at: self.firstIndex(of: c)!)
//                self.
//                self.insert(" ", at: <#T##String.Index#>)
//            }
//        }
//    }
    
    func titlecased() -> String {
        return self.replacingOccurrences(of: "([A-Z])", with: " $1", options: .regularExpression, range: self.range(of: self))
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized
    }
    
}
