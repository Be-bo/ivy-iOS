//
//  UIImage+Compression.swift
//  ivy-iOS
//
//  Created by paul dan on 2020-01-26.
//  Copyright © 2020 ivy social network. All rights reserved.
//

import Foundation
import UIKit

let IMAGE_MAX_DIMEN = CGFloat(1500)
let PREVIEW_IMAGE_DIVIDER = CGFloat(3)

extension UIImage {
    func compress() -> UIImage {
        let inputImage = self

        //compress a normal sized image
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

    func compressPreivew() -> UIImage {
        let inputImage = self

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
