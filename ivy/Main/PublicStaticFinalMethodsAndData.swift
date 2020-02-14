//
//  PublicStaticFinalMethodsAndData.swift
//  ivy
//
//  Created by Robert on 2019-09-03.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class PublicStaticMethodsAndData{
    
    static let IMAGE_MAX_DIMEN = CGFloat(1500)
    static let PREVIEW_IMAGE_DIVIDER = CGFloat(3)
    
    static func createInfoDialog(titleText: String, infoText: String, context: UIViewController){
        let alert = UIAlertController(title: titleText, message: infoText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        context.present(alert, animated: true)
    }
    
    
    static func calculateAge(millis: Int64) -> Int64 {
        let currentMillis = Int64(Date().millisecondsSince1970)
        let difference = Int64(currentMillis - millis)
        let age = (difference) / 31536000000
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
    
    static func getHeightForShrunkenWidth(imgWidth: CGFloat, imgHeight: CGFloat, targetWidth: CGFloat) -> CGFloat{
        let aspectRatio = imgHeight/imgWidth
        let targetHeight = aspectRatio * targetWidth
        return targetHeight
    }
    
    static func getFileExtensionFromPath(filePath: String) -> String{
        let fileName = filePath.components(separatedBy: "/").last!
        let fileExt = fileName.components(separatedBy: ".").last!
        return fileExt.lowercased()
    }
    
    
    static func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    
    
    
    
    
    
    static let iconNames = [
        "accounting", "actuarialScience", "ancientAndMedievalHistory", "anthropology", "appliedscience", "archaeology", "architecture", "artHistory", "astrophysics",
        "biology", "businessadministration", "biochemistry", "bioinformatics", "biomechanics", "biomedicalSciences", "businessAnalytics", "businessTechnologyManagement", "businessAdmin", "businessStrategy",
        "chemistry", "computerscience", "canadianStudies", "cmandb", "chemicalEngineering", "civilEngineering", "communicationandMediaStudies", "communityRehabilitation", "commerce",
        "dentistry", "dance", "developmentStudies", "drama",
        "economics", "education", "engineering", "english", "earthSciences", "eastAsianLanguageStudies", "ecology", "electricalEngineering", "energy", "entrepreneurshipandinnovation", "environment",
        "finance", "finearts", "french", "film",
        "geography", "geology", "geophysics", "german", "greekandroman",
        "history", "health",
        "indigenous", "internationalrelations", "italian",
        "kinesiology",
        "lawandsociety", "law", "latinamerican", "leadership", "linguistics",
        "marketing", "math", "medicine", "mastersStudent",
        "neuroscience","nursing",
        "politicalscience", "psychology", "physiology", "physics", "philosophy", "plantBiology",
        "realEstate", "religiousStudies", "riskManagementAndInsurance", "russian",
        "socialWork", "sociology", "softwareEngineering", "spanish",
        "urbanStudies",
        "vet",
        "womensStudies",
        "zoology"
    ]
    
    static let degreeNames = ["Accounting", "Actuarial Science", "Ancient and Medieval History", "Anthropology", "Applied Science", "Archaeology", "Architecture", "Art History", "Astrophysics",
                       "Biology", "Business Administration", "Biochemistry", "Bioinformatics", "Biomechanics", "Biomedical Sciences", "Business Analytics", "Business Technology Management", "Business Administration", "Business Strategy",
                       "Chemistry", "Computer Science", "Canadian Studies", "Cellular, Molecular, and Microbial Biology", "Chemical Engineering", "Civil Engineering", "Communication and Media Studies", "Community Rehabilitation", "Commerce",
                       "Dentistry", "Dance", "Development Studies", "Drama",
                       "Economics", "Education", "Engineering", "English", "Earth Sciences", "East Asian Studies", "Ecology", "Electrical Engineering", "Energy", "Entrepreneurship and Innovation", "Environment",
                       "Finance", "Fine Arts", "French", "Film",
                       "Geography", "Geology", "Geophysics", "German", "Greek and Roman",
                       "History", "Health",
                       "Indigenous Studies", "International Relations", "Italian",
                       "Kinesiology",
                       "Law and Society", "Law", "Latin American Studies", "Leadership", "Linguistics",
                       "Marketing", "Math", "Medicine", "Masters Degree",
                       "Neuroscience","Nursing",
                       "Political Science", "Psychology", "Physiology", "Physics", "Philosophy", "Plant Biology",
                       "Real Estate", "Religious Studies", "Risk Management and Insurance", "Russian",
                       "Social Work", "Sociology", "Software Engineering", "Spanish",
                       "Urban Studies",
                       "Veterinary Medicine",
                       "Women's Studies",
                       "Zoology"
    ]
    
    //all our interest labels
    static let labels = [
        "Reading",
        "Cooking",
        "Sports",
        "Politics",
        "Music",
        "Painting",
        "Volunteer",
        "Traveling",
        "Animals",
        "Dancing",
        "Writing",
        "Socializing",
        "Hanging with Friends",
        "Partying",
        "Video Games",
        "Hitting the beach",
        "Graphic Design",
        "Computer Programming",
        "Meditating",
        "Puzzles",
        "Photography",
        "Drawing",
        "Exercise",
        "Working Out",
        "Fantasy Sports",
        "Legos",
        "Singing",
        "Movies",
        "Yoga",
        "Yo-yo",
        "Television",
        "Netflix",
        "Chilling",
        "Netflix and Chilling",
        "Knitting",
        "Puddle Jumping",
        "Cliff Jumping",
        "Rock Climbing",
        "Mountain Climbing",
        "Hiking",
        "Birdwatching",
        "Camping",
        "Glamping",
        "Driving",
        "Fishing",
        "Long Boarding",
        "Water Polo",
        "Extreme Sports",
        "Surfing",
        "Sailing",
        "Extreme Taco Eating",
        "Biking",
        "Rugby",
        "Football",
        "Soccer",
        "Basketball",
        "Walking",
        "Badminton",
        "Volleyball",
        "Laser Tag",
        "Tag",
        "Freeze Tag",
        "Upholstery",
        "Woodwork",
        "Welding",
        "The environment",
        "Working",
        "Twerking",
        "Clubbing",
        "Pool",
        "Foosball",
        "Watching the office",
        "Watching friends",
        "Pokémon",
        "Skateboarding",
        "Acting",
        "Theater",
        "Home movies",
        "Interior Design",
        "Design",
        "Fashion",
        "Fashion Design"
    ]

    
    
}
