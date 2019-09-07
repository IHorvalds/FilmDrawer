//
//  UIImage+extension.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 07/09/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    class func downsample(imageWithData imageData: Data, to pointSize: CGSize, scale: CGFloat) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        
        
        if let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions) {
        
            let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
            let downsampleOptions =
                [kCGImageSourceCreateThumbnailFromImageAlways: true,
                 kCGImageSourceShouldCacheImmediately: true,
                 kCGImageSourceCreateThumbnailWithTransform: true,
                 kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
            
            let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)!
            return UIImage(cgImage: downsampledImage)
        }
        return nil
    }
    
}
