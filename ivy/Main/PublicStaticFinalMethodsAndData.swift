//
//  PublicStaticFinalMethodsAndData.swift
//  ivy
//
//  Created by Robert on 2019-09-03.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import Foundation
import UIKit

class PublicStaticMethodsAndData{
    
    static let IMAGE_MAX_DIMEN = CGFloat(1500)
    static let PREVIEW_IMAGE_DIVIDER = CGFloat(3)
    
    static func createInfoDialog(titleText: String, infoText: String, context: UIViewController){
        let alert = UIAlertController(title: titleText, message: infoText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        context.present(alert, animated: true)
    }
    
    static func calculateAge(millis: Int64) -> Int64 {
        let currentMillis = Int64(NSDate().timeIntervalSince1970 * 1000)
        print("current millis: ",currentMillis, " born millis: ", millis)
        let difference = currentMillis - millis
        let age = difference / 31536000000
        return age
    }
    
    static func compressStandardImage(inputImage: UIImage) -> UIImage{ //compress a normal sized image
        let origSize = inputImage.size
        let widthLarger = origSize.width >= origSize.height
        let dimensLimitExceeded = max(origSize.width, origSize.height) > IMAGE_MAX_DIMEN
        var newHeight = CGFloat(0)
        var newWidth = CGFloat(0)
        
        if dimensLimitExceeded && widthLarger { //limit exceeded
            newWidth = IMAGE_MAX_DIMEN
            newHeight = (origSize.height / origSize.width) * IMAGE_MAX_DIMEN
        }else if dimensLimitExceeded && !widthLarger{ //limit exceeded
            newHeight = IMAGE_MAX_DIMEN
            newWidth = (origSize.width / origSize.height) * IMAGE_MAX_DIMEN
        }else{ //limit not exceeded
            newHeight = origSize.height
            newWidth = origSize.width
        }
        
        let rect = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        inputImage.draw(in: rect)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext() ?? inputImage
        UIGraphicsEndImageContext()
        return outputImage
    }
    
    static func compressPreviewImage(inputImage: UIImage) -> UIImage{
        let origSize = inputImage.size
        let widthLarger = origSize.width >= origSize.height
        let dimensLimitExceeded = max(origSize.width, origSize.height) > IMAGE_MAX_DIMEN
        var newHeight = CGFloat(0)
        var newWidth = CGFloat(0)
        
        if dimensLimitExceeded && widthLarger { //limit exceeded
            newWidth = IMAGE_MAX_DIMEN
            newHeight = (origSize.height / origSize.width) * IMAGE_MAX_DIMEN
        }else if dimensLimitExceeded && !widthLarger{ //limit exceeded
            newHeight = IMAGE_MAX_DIMEN
            newWidth = (origSize.width / origSize.height) * IMAGE_MAX_DIMEN
        }else{ //limit not exceeded
            newHeight = origSize.height
            newWidth = origSize.width
        }
        
        newWidth = newWidth / PREVIEW_IMAGE_DIVIDER //the only difference for the preview image to make it smaller
        newHeight = newHeight / PREVIEW_IMAGE_DIVIDER
        
        let rect = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        inputImage.draw(in: rect)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext() ?? inputImage
        UIGraphicsEndImageContext()
        return outputImage
    }
}
