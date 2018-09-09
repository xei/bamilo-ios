//
//  Ext+UIImage.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 4/9/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import Foundation

extension UIImage {
    
    var noir: UIImage {
        let context = CIContext(options: nil)
        let currentFilter = CIFilter(name: "CIPhotoEffectNoir")!
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        let output = currentFilter.outputImage!
        let cgImage = context.createCGImage(output, from: output.extent)!
        let processedImage = UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        
        return processedImage
    }
}
