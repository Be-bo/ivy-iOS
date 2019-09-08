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

    
    // MARK: Variables and Constants
    var password = ""   //carried over
    var registerInfoStruct = UserProfile(age:"", banned: nil, bio: "", birth_time: nil, degree: "", email: "", first_name: "", gender: "") //will be overidden by the actual data
    private var croppedRect = CGRect.zero
    private var croppedAngle = 0
    private var byteArray:NSData? =  nil

    
    
    
    
    // MARK: IBOutlets and IBActions
    
    @IBOutlet weak var actualFinalImage: UIImageView!
    @IBAction func onClickContinue(_ sender: Any) {
        print("attempt to continue")
        attemptToContinue()
    }
    @IBAction func clickAddPhoto(_ sender: Any) { //when they click on add photo take them to which photo they should choose
        showImagePickerController()
    }
    
    
    
    
    
    
    // MARK: Base Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.actualFinalImage.layer.masksToBounds = true;
        self.actualFinalImage.layer.borderColor = UIColor.ivyGrey.cgColor
        self.actualFinalImage.layer.borderWidth = 1.0;    //thickness
        self.actualFinalImage.layer.cornerRadius = 10.0;  //rounded corner
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
        vc.registerInfoStruct.first_name = self.registerInfoStruct.first_name ?? "no first name"
        vc.registerInfoStruct.last_name = self.registerInfoStruct.last_name ?? "no last name"
        vc.registerInfoStruct.gender = self.registerInfoStruct.gender ?? "no gender"
        vc.registerInfoStruct.degree = self.registerInfoStruct.degree ?? "no degree"
        vc.registerInfoStruct.birth_time = self.registerInfoStruct.birth_time ?? nil
        vc.registerInfoStruct.bio = self.registerInfoStruct.bio ?? "no bio"
        vc.registerInfoStruct.interests = self.registerInfoStruct.interests ?? ["no interests chosen"]
        vc.imageByteArray = self.byteArray
        vc.password = self.password //set the password

    }
    
    
    
    
    
    
    
    
    
    // MARK: Image Cropping Methods
    
    func presentCropViewController() { //pop up the TOCropViewController editor to allow editing of the image thats chosen
        var image: UIImage? = self.actualFinalImage.image // Load an image
        let cropViewController = CropViewController(image: image!)
        cropViewController.delegate = self
        cropViewController.customAspectRatio = CGSize(width: 2.0, height: 3.0)
        cropViewController.resetAspectRatioEnabled = false
        cropViewController.aspectRatioPreset = .presetCustom
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.aspectRatioPickerButtonHidden = true
        present(cropViewController, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) { // 'image' is the newly cropped version of the original image
        self.croppedRect = cropRect
        self.croppedAngle = angle
        actualFinalImage.image = image
        dismiss(animated: true, completion: nil)
        self.byteArray = (image.jpegData(compressionQuality: 1.0)!) as NSData
    }
    
    func showImagePickerController() { //present the imagepicker controller which allows users to choose what image they want from the gallery
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
            self.actualFinalImage.layer.borderWidth = 0.0;    //get rid of the image border
        }
        dismiss(animated: true, completion: nil)    //dismiss the imagepickercontroller view
        presentCropViewController()
    }
}
