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
    
    
    //passed through segue from the gallery
    public var thisUserProfile:Dictionary<String,Any>? = nil
    public var thisUniDomain = String()
    public var thisUserId = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        
        showImagePickerController()
    }
    
    private func setUpNavigationBar(){
        let titleView = MediumGreenLabel()
        titleView.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        titleView.text = "Crop"
        titleView.textAlignment = .center
        navigationItem.titleView = titleView
        
        
        let checkButton = UIButton(type: .custom)
        checkButton.frame = CGRect(x: 0.0, y: 0.0, width: 45, height: 35)
        checkButton.setImage(UIImage(named:"check"), for: .normal)
        checkButton.addTarget(self, action: #selector(self.didTapCheckButton), for: .touchUpInside)
        
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
//        self.performSegue(withIdentifier: "photoAdderToGallery" , sender: self) //pass data over to
        uploadAndUpdate()
//        self.dismiss(animated: true)
        
        //TODO: maybe use something like this to go back tot he gallery
//        func presentCropViewController() { //pop up the TOCropViewController editor to allow editing of the image thats chosen
//            var image: UIImage? = self.actualFinalImage.image // Load an image
//            let cropViewController = CropViewController(image: image!)
//            cropViewController.delegate = self
//            present(cropViewController, animated: true, completion: nil)
//        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let vc = segue.destination as! Gallery
//        vc.thisUniDomain = self.thisUniDomain
//        vc.galleryUpdated = self.galleryUpdated
//        vc.thisUserId = self.thisUserId
//    }
    
    
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
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile!["uni_domain"] as! String).collection("userpreviews").document(self.thisUserProfile!["id"] as! String).updateData(["preview_image":self.previewByteArray])
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile!["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile!["id"] as! String).updateData(["picture_references":FieldValue.arrayUnion([storagePath])])
            
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile!["uni_domain"] as! String).collection("userpreviews").document(self.thisUserProfile!["id"] as! String).updateData(["memo":"Uploaded a new profile picture!"])
            
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile!["uni_domain"] as! String).collection("userpreviews").document(self.thisUserProfile!["id"] as! String).updateData(["memo_millis":Date().timeIntervalSince1970])
            
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile!["uni_domain"] as! String).collection("userpreviews").document(self.thisUserProfile!["id"] as! String).updateData(["update_has_image":true])
            
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile!["uni_domain"] as! String).collection("userpreviews").document(self.thisUserProfile!["id"] as! String).updateData(["update_image":storagePath])
            
            //TODO figure out how to dismiss this controller properly and go back to the gallery screen
            self.navigationController!.dismiss(animated: true, completion: nil)
//            self.dismiss(animated: true)

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
        var image: UIImage? = self.actualFinalImage// Load an image
        let cropViewController = CropViewController(image: image!)
        cropViewController.delegate = self
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.aspectRatioPickerButtonHidden = true
        cropViewController.aspectRatioPreset = .preset3x2
        present(cropViewController, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) { // 'image' is the newly cropped version of the original image
        self.croppedRect = cropRect
        self.croppedAngle = angle
        self.actualFinalImage = image
        dismiss(animated: true, completion: nil)
        self.byteArray = (image.jpegData(compressionQuality: 1.0)!) as NSData
        self.previewByteArray = (image.jpegData(compressionQuality: 0.25)!) as NSData
        self.galleryUpdated = true                  //true so the segue knows weupdated the profile pic
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
            self.actualFinalImage = originalImage
//            self.actualFinalImage.layer.borderWidth = 0.0;    //get rid of the image border
        }
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.actualFinalImage = editedImage
            return
        }
        
        
        dismiss(animated: true, completion: nil)    //dismiss the imagepickercontroller view
        presentCropViewController()
    }
    
    
}
