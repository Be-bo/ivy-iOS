//
//  Reg9Photo.swift
//  ivy
//
//  Created by paul dan on 2019-07-14.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import CropViewController

class Reg9Photo: UIViewController, CropViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //initializers
    var registerInfoStruct = UserProfile(email: "", first: "", last: "", gender: "", degree: "", birthday: "", bio:"", interests: [""]) //will be overidden by the actual data
    private var croppedRect = CGRect.zero
    private var croppedAngle = 0

    
    @IBOutlet weak var finalImageView: UIImageView! //where the final iamge will be placed to display to the user
    
    @IBOutlet weak var actualFinalImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("photo", registerInfoStruct)
    }
    
    //when they click on add photo take them to which photo they should choose
    @IBAction func clickAddPhoto(_ sender: Any) {
        presentCropViewController()
//        showImagePickerController()
    }
    
    func presentCropViewController() {
        var image: UIImage? = finalImageView.image // Load an image
        let cropViewController = CropViewController(image: image!)
        cropViewController.delegate = self
        present(cropViewController, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // 'image' is the newly cropped version of the original image
        self.croppedRect = cropRect
        self.croppedAngle = angle
        actualFinalImage.image = image
        dismiss(animated: true, completion: nil)
        let byteArray = image.jpegData(compressionQuality: 1.0)
        print("This is the byte array", byteArray)
    }
    
}

//UINavigationControllerDelegate will allow us to navigate to the uiimagepickercontroller
//extension Reg9Photo: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//    func showImagePickerController() {
//        let imagePickerController = UIImagePickerController()
//        imagePickerController.delegate = self   //listen for events
//        imagePickerController.allowsEditing = true  //pan/zoom/pinch selected image
//        imagePickerController.sourceType = .photoLibrary    //choose photo library or from camera
//        present(imagePickerController, animated: true, completion: nil) //show it
//    }
//
//    //when they actually choose an image
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//
//        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{ //extract the "edited" image from our info
//            finalImageView.image = editedImage //set it in whatever place we want
//        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{ //extract the non "edited" image from our info
//            finalImageView.image = originalImage
//        }
//
//        dismiss(animated: true, completion: nil)    //dismiss the imagepickercontroller view
//    }
//
//}
