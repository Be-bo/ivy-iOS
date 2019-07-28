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
    private var byteArray:NSData? =  nil

    //outlets
    @IBOutlet weak var finalImageView: UIImageView! //where the final iamge will be placed to display to the user
    @IBOutlet weak var actualFinalImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    //////////////////////////////////////////SEGUE//////////////////////////////////////////
    @IBAction func onClickContinue(_ sender: Any) {
        print("attempt to continue")
        attemptToContinue()
    }
    
    func attemptToContinue() {
        if (self.actualFinalImage.image == nil){ //if they press continue they must have chosen an image
        }else {
            self.performSegue(withIdentifier: "reg9ToReg10Segue" , sender: self) //pass data over to

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //called every single time a segue is called
        let vc = segue.destination as! Reg10Recap
        vc.registerInfoStruct.email = self.registerInfoStruct.email ?? "no email"
        vc.registerInfoStruct.first = self.registerInfoStruct.first ?? "no first name"
        vc.registerInfoStruct.last = self.registerInfoStruct.last ?? "no last name"
        vc.registerInfoStruct.gender = self.registerInfoStruct.gender ?? "no gender"
        vc.registerInfoStruct.degree = self.registerInfoStruct.degree ?? "no degree"
        vc.registerInfoStruct.birthday = self.registerInfoStruct.birthday ?? "no birthday"
        vc.registerInfoStruct.bio = self.registerInfoStruct.bio ?? "no bio"
        vc.registerInfoStruct.interests = self.registerInfoStruct.interests ?? ["no interests chosen"]
        vc.registerInfoStruct.imageByteArray = self.byteArray
    }
    //////////////////////////////////////////SEGUE//////////////////////////////////////////
    
    //////////////////////////////////////////IMAGE CHOOSING & CROPPING//////////////////////////////////////////
    //when they click on add photo take them to which photo they should choose
    @IBAction func clickAddPhoto(_ sender: Any) {
        showImagePickerController()
    }
    
    //pop up the TOCropViewController editor to allow editing of the image thats chosen
    func presentCropViewController() {
        var image: UIImage? = self.actualFinalImage.image // Load an image
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
        self.byteArray = (image.jpegData(compressionQuality: 1.0)!) as NSData
//        print("byte array", self.byteArray)
        
    }
    
    //present the imagepicker controller which allows users to choose what image they want from the gallery
    func showImagePickerController() {
        let imagePicker = UIImagePickerController()
        imagePicker.modalPresentationStyle = .popover
        imagePicker.preferredContentSize = CGSize(width: 320, height: 568)
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    //when they actually choose an image, then call TOCropViewController with that image that they chose so they can edit
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{ //extract the non "edited" image from our info
            self.actualFinalImage.image = originalImage
        }
        dismiss(animated: true, completion: nil)    //dismiss the imagepickercontroller view
        presentCropViewController()
    }
    //////////////////////////////////////////IMAGE CHOOSING & CROPPING//////////////////////////////////////////

    
}
