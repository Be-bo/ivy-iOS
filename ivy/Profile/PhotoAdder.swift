//
//  PhotoAdder.swift
//  ivy
//
//  Created by paul dan on 2019-09-02.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import CropViewController

class PhotoAdder: UIViewController, CropViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    private let baseStorageReference = Storage.storage().reference()
    private let baseDatabaseReference = Firestore.firestore()                    //reference to the database

    private var croppedRect = CGRect.zero
    private var croppedAngle = 0
    private var byteArray:NSData? =  nil
    private var previewByteArray:NSData? =  nil
    private var actualFinalImage:UIImage? = nil
    private var galleryUpdated = false
    
    public var previousGalleryVC = Gallery()

    let checkButton = UIButton(type: .custom)
    
    @IBOutlet weak var finalImageView: UIImageView!
    
    //passed through segue from the gallery
    public var thisUserProfile:Dictionary<String,Any>? = nil
    public var thisUniDomain = String()
    public var thisUserId = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showImagePickerController()
    }
    
    private func setUpNavigationBar(){
        let titleView = MediumGreenLabel()
        titleView.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        titleView.text = "Crop"
        titleView.textAlignment = .center
        navigationItem.titleView = titleView
        
        
//        checkButton = UIButton(type: .custom)
        checkButton.frame = CGRect(x: 0.0, y: 0.0, width: 45, height: 35)
        checkButton.setImage(UIImage(named:"check"), for: .normal)
        checkButton.addTarget(self, action: #selector(self.didTapCheckButton), for: .touchUpInside)
        self.checkButton.isEnabled = true
        
        let checkButtonItem = UIBarButtonItem(customView: checkButton)
        let currWidth = checkButtonItem.customView?.widthAnchor.constraint(equalToConstant: 35)
        currWidth?.isActive = true
        let currHeight = checkButtonItem.customView?.heightAnchor.constraint(equalToConstant: 35)
        currHeight?.isActive = true
        
        
        
        self.navigationItem.rightBarButtonItem = checkButtonItem
        
        
    }
    
    //when they click on the green plus checkmark
    @objc func didTapCheckButton() {
        //now I have the image they chose so I can go back to the gallery
        let alert = UIAlertController(title: "Add this photo?", message: .none, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.checkButton.isEnabled = false
//            Timer.scheduledTimer(timeInterval: 10, target: self, selector: Selector("enableButton"), userInfo: nil, repeats: false)
            self.uploadAndUpdate()
        }))
        self.present(alert, animated: true)
        
    
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let vc = segue.destination as! Gallery
//        vc.thisUniDomain = self.thisUniDomain
//        vc.galleryUpdated = self.galleryUpdated
//        vc.thisUserId = self.thisUserId
//    }
    
//    func enableButton() {
//        self.checkButton.isEnabled = true
//    }
//
    
    //upload the image  to the db
    func uploadAndUpdate() {
        //image firebase storage path
        let uuid = NSUUID().uuidString
        let userId = self.thisUserProfile!["id"] as! String
        let storagePath = "userimages/" + userId + "/" + uuid + ".jpg"
        
        // Create a storage reference from our storage service
        let storageImageRef = baseStorageReference.child(storagePath)
        

        
        
        // Upload the file to the path storagePath
        let uploadTask = storageImageRef.putData(self.byteArray! as Data, metadata: nil) { (metadata, error) in

        }
        
        // Upload completed successfully
        uploadTask.observe(.success) { snapshot in
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile!["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile!["id"] as! String).updateData(["profile_picture":storagePath])
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile!["uni_domain"] as! String).collection("userpreviews").document(self.thisUserProfile!["id"] as! String).updateData(["profile_picture":storagePath])
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile!["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile!["id"] as! String).updateData(["picture_references":FieldValue.arrayUnion([storagePath])])
            
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile!["uni_domain"] as! String).collection("userpreviews").document(self.thisUserProfile!["id"] as! String).updateData(["memo":"Uploaded a new profile picture!"])
            
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile!["uni_domain"] as! String).collection("userpreviews").document(self.thisUserProfile!["id"] as! String).updateData(["memo_millis":Date().timeIntervalSince1970])
            
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile!["uni_domain"] as! String).collection("userpreviews").document(self.thisUserProfile!["id"] as! String).updateData(["update_has_image":true])
            
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile!["uni_domain"] as! String).collection("userpreviews").document(self.thisUserProfile!["id"] as! String).updateData(["update_image":storagePath])
            
            self.baseStorageReference.child("userimages/"+self.thisUserId+"/preview.jpg").putData(self.previewByteArray! as Data)
            
            
            //actually dismiss the view so we can clickon stuff again
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
            
            
            //TODO: maybe find a cleaner way to do all this below
            //update the profile picture of the card real time to contain the current path of the image they chose
            self.thisUserProfile!["profile_picture"] = storagePath
            self.previousGalleryVC.previousVC.setUp(user: self.thisUserProfile!)
            
            //dismiss the gallery screen also to show them the new profile picture
            self.previousGalleryVC.navigationController?.popViewController(animated: true)
            self.previousGalleryVC.dismiss(animated: true, completion: nil)
 
        }
        
        
        //upload task failed
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as NSError? {
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    print("File doesn't exist")
                    break
                case .unauthorized:
                    print("User doesn't have permission to access file")
                    break
                case .cancelled:
                    print("User canceled the upload")
                    break
                case .unknown:
                    print("unknown error")
                    break
                default:
                    print("retry the upload here if it fails")
                    break
                }
            }
        }
        
        
        
        
    }
    
    
    
    
    // MARK: Image Cropping Methods
    func presentCropViewController() { //pop up the TOCropViewController editor to allow editing of the image thats chosen
        var image: UIImage? = self.finalImageView.image // Load an image
        let cropViewController = CropViewController(image: image!)
        cropViewController.delegate = self
        cropViewController.customAspectRatio = CGSize(width: 2.0, height: 3.0)
        cropViewController.aspectRatioPreset = .presetCustom
        cropViewController.resetAspectRatioEnabled = false
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.aspectRatioPickerButtonHidden = true
        cropViewController.modalPresentationStyle = .fullScreen
        present(cropViewController, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) { // 'image' is the newly cropped version of the original image
        self.croppedRect = cropRect
        self.croppedAngle = angle
        finalImageView.image = image

        
        dismiss(animated: true, completion: nil)
        let compressedImage = PublicStaticMethodsAndData.compressStandardImage(inputImage: image)
        self.byteArray = (compressedImage.jpegData(compressionQuality: 0.8)!) as NSData
        self.previewByteArray = (PublicStaticMethodsAndData.compressPreviewImage(inputImage: compressedImage).jpegData(compressionQuality: 0.8)!) as NSData
        self.galleryUpdated = true                  //true so the segue knows weupdated the profile pic
        
        self.setUpNavigationBar()                   //only after they have chosen an image do we add the checkmark to submit it
        


    }
    
    func showImagePickerController() { //present the imagepicker controller which allows users to choose what image they want from the gallery
        let imagePicker = UIImagePickerController()
       // imagePicker.modalPresentationStyle = .popover
        imagePicker.preferredContentSize = CGSize(width: 320, height: 568)
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    //when they actually choose an image, then call TOCropViewController with that image that they chose so they can edit
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{ //extract the non "edited" image from our info
            self.finalImageView.image = originalImage
            self.finalImageView.layer.borderWidth = 0.0;    //get rid of the image border
        }
        dismiss(animated: true, completion: nil)    //dismiss the imagepickercontroller view
        presentCropViewController()
    }
    
    
}
