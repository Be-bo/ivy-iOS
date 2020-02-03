//
//  AddEvent.swift
//  ivy-iOS
//
//  Created by paul dan on 2020-01-26.
//  Copyright © 2020 ivy social network. All rights reserved.
//

import Foundation
import UIKit
import TagListView
import Firebase
import Toast_Swift


class AddEvent: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TagListViewDelegate {
    
    //MARK: Variables and Constants

    private let DATE_FORMAT = "dd MMM yyyy, HH:mm"
    private let databaseReference = Firestore.firestore()
    private let storageReference = Storage.storage().reference()
    public var userProfile = Dictionary<String, Any>()
    let datePickerFrom = UIDatePicker()
    let datePickerTo = UIDatePicker()
    var tagListHeight = 28 //height of one taglistview row
    var tagArray: [String] = []
    var screenHeight = UIScreen.main.bounds.height
    var keyboardHeight = CGFloat(0)
    
    
    
    
    //MARK: IBActions and IBOutlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventFromDateTextfield: UITextField!
    @IBOutlet weak var eventToDateTextfield: UITextField!
    @IBOutlet weak var eventLocationTextfield: UITextField!
    @IBOutlet weak var eventDescriptionTextview: UITextView!
    @IBOutlet weak var eventTagsTextfield: UITextField!
    @IBOutlet weak var tagView: TagListView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addImageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var eventLinkTextField: UITextField!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitButton: StandardButton!
    @IBOutlet weak var loadingWheel: LoadingWheel!
    
    
    @IBAction func addEventPhoto(_ sender: Any) {
          let pickerController = UIImagePickerController()
          pickerController.delegate = self
          pickerController.allowsEditing = true
          pickerController.mediaTypes = ["public.image"]
          pickerController.sourceType = .photoLibrary
          self.present(pickerController, animated: true, completion: nil)
          
      }
      
      func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
          if let chosenImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
              self.eventImageView.image = chosenImage
          } else if let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
              self.eventImageView.image = chosenImage
          }
          eventImageView.layer.borderWidth = 0
          dismiss(animated: true, completion: nil)
      }
      
      
    @IBAction func submitEvent(_ sender: Any) {
        
        guard let university = self.userProfile["uni_domain"] else {
            return
        }
        
        guard let authorID = self.userProfile["id"] else {  //so we know who pushed
            return
        }
        
        guard let authorUniDomain = self.userProfile["uni_domain"] else {
            return
        }
        
        guard let eventName = eventNameTextField.text else {
            self.view.makeToast("Event name is missing")
            return
        }
        
        guard let eventImage = eventImageView.image else {
            self.view.makeToast("Image is missing!")
            return
        }
        
        guard eventFromDateTextfield.text != nil else {
            self.view.makeToast("From date is not set!")
            return
        }
        
        guard eventToDateTextfield.text != nil else {
            self.view.makeToast("To date is not set!")
            return
        }
        
        guard let location = eventLocationTextfield.text else {
            self.view.makeToast("Location is not set!")
            return
        }
        
        guard let description = eventDescriptionTextview.text else {
            self.view.makeToast("Description is missing!")
            return
        }
        
        if description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.view.makeToast("Description is Empty!")
            return
        }
        
        if eventName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.view.makeToast("Name is Empty!")
            return
        }
        
        if location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.view.makeToast("Location is Empty!")
            return
        }
        
        
        let eventId = NSUUID().uuidString
        let eventImgPath = "organizationResources/\(eventId).jpg"
        let from = datePickerFrom.date.millisecondsSince1970
        let to = datePickerTo.date.millisecondsSince1970
        let link = eventLinkTextField.text  //can be empty so doesn't need gaurd
        
        if to - from <= 0 {
            self.view.makeToast("Please enter valid date range")
            return
        }
        
        
        
        //save all data to Firebase
        self.barInteraction()
        let compressedImage = PublicStaticMethodsAndData.compressStandardImage(inputImage: eventImage.compress())
        let eventImageRef = storageReference.child(eventImgPath)
        if let imgData = compressedImage.jpegData(compressionQuality: 100.0) {
            let imgMetadata = StorageMetadata()
            imgMetadata.contentType = "image/jpeg"
            eventImageRef.putData(imgData, metadata: imgMetadata) { (metadata, error) in
                guard metadata != nil else {
                    self.view.makeToast("Failed to upload event image.")
                    self.allowInteraction()
                    return
                }
                
                let eventModel: [String: Any] = [
                    "id": eventId,
                    "creation_time": from,
                    "start_time": from,
                    "name": eventName,
                    "description": description,
                    "end_time": to,
                    "going_ids": [],
                    "image": eventImgPath,
                    "keywords": self.tagArray,
                    "link": link,
                    "location": location,
                    "uni_domain": university,
                    "views": [],
                    "is_active": false,    //false until we decide otherwise for now
                    "is_featured": false,
                    "author_id" : authorID
                    
                ]
                
                self.databaseReference.collection("universities").document(authorUniDomain as! String).collection("events").document(eventId).setData(eventModel) { err in
                    if let err = err {
                        self.allowInteraction()
                        self.view.makeToast("Failed to add event data.")
                        print(err)
                    } else {
                        
                        //push to the ucalgary document array that holds the pending events
                        self.databaseReference.collection("universities").document(authorUniDomain as! String).updateData(["pendingevents": FieldValue.arrayUnion([eventId])]) {
                            err2 in
                            if let err2 = err2{
                                self.allowInteraction()
                                self.view.makeToast("Failed to add event approval id.")
                                print(err2)
                            }else{
                                self.view.makeToast("Your event has been submitted for approval.")
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {   //dismiss view controller after 2 seconds
                                    _ = self.navigationController?.popToRootViewController(animated: true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    //MARK: Setup Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Create Event"
        submitButton.isUserInteractionEnabled = true    //make sure submit button is clickable
        self.configureComponents()

        initializeDatePicker(
            with: datePickerFrom,
            textView: eventFromDateTextfield,
            action: #selector(doneDatePickerFrom(sender:))
        )

        initializeDatePicker(
            with: datePickerTo,
            textView: eventToDateTextfield,
            action: #selector(doneDatePickerTo(sender:))
        )
        
        self.setUpTags()
        self.setUpKeyboardPusher()
    }
    
    override func viewDidLayoutSubviews() {
        self.addImageTopConstraint.constant = (self.view.frame.width/2) - (self.addImageButton.frame.width/2) + 23
    }
    
    func barInteraction(){
        self.view.isUserInteractionEnabled = false
        submitButton.isHidden = true
        loadingWheel.isHidden = false
    }
    
    func allowInteraction(){
        self.view.isUserInteractionEnabled = true
        submitButton.isHidden = false
        loadingWheel.isHidden = true
    }
    
    func configureComponents() {
        //tags for return key continuity
        self.eventNameTextField.tag = 10
        self.eventFromDateTextfield.tag = 11
        self.eventFromDateTextfield.tag = 12
        self.eventLocationTextfield.tag = 13
        self.eventLinkTextField.tag = 14
        self.eventDescriptionTextview.tag = 15
        self.eventTagsTextfield.tag = 16
        
        //event description
        self.eventDescriptionTextview.layer.masksToBounds = true;
        self.eventDescriptionTextview.layer.borderColor = UIColor.ivyGrey.cgColor
        self.eventDescriptionTextview.layer.borderWidth = 1.0;    //thickness
        self.eventDescriptionTextview.layer.cornerRadius = 10.0;  //rounded corner
        self.eventDescriptionTextview.font = UIFont(name: "Cordia New", size: 25)
        
        //this block ain't working for some reason
        self.eventDescriptionTextview.layer.shadowColor = UIColor.black.cgColor
        self.eventDescriptionTextview.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.eventDescriptionTextview.layer.shadowRadius = 5
        self.eventDescriptionTextview.layer.shadowOpacity = 0.3
        self.eventDescriptionTextview.clipsToBounds = true

        //event imageview
        self.eventImageView.layer.masksToBounds = true;
        self.eventImageView.layer.borderColor = UIColor.ivyGrey.cgColor
        self.eventImageView.layer.borderWidth = 1.0;    //thickness
        self.eventImageView.layer.cornerRadius = 10.0;  //rounded corner
        self.eventImageView.layer.shadowColor = UIColor.black.cgColor
        self.eventImageView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.eventImageView.layer.shadowRadius = 5
        self.eventImageView.layer.shadowOpacity = 0.3
        self.eventImageView.clipsToBounds = true
        
        self.imageHeightConstraint.constant = self.view.frame.width - 50
        self.loadingWheel.isHidden = true

        self.eventNameTextField.delegate = self
        self.eventDescriptionTextview.delegate = self
        self.eventLinkTextField.delegate = self
        self.eventFromDateTextfield.delegate = self
        self.eventToDateTextfield.delegate = self
        self.eventLocationTextfield.delegate = self
        self.eventTagsTextfield.delegate = self
        
        let keyboardTopBar = UIToolbar()
        keyboardTopBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(textFieldShouldReturn(_:)))
        keyboardTopBar.items = [doneButton]
        self.hideKeyboardOnTapOutside()
//        self.eventDescriptionTextview.inputAccessoryView = keyboardTopBar
    }
    
    func setUpKeyboardPusher(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setUpTags() {
        tagView.delegate = self
        tagView.textFont = UIFont.systemFont(ofSize: 18)
    }
    
    
    
    
    
    
    
    //MARK: UI Functions
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.keyboardHeight = keyboardSize.height
            if (eventTagsTextfield.isFirstResponder) {
                self.view.frame.origin.y = -(keyboardSize.height)
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == eventTagsTextfield){
            addTag()
            return false
        }
        if(textField == eventLinkTextField){
            eventDescriptionTextview.becomeFirstResponder()
            return false
        }
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField { //try to find next responder and choose it if it exists
            textField.endEditing(true)
            nextField.becomeFirstResponder()
            let posToScrollTo = nextField.frame.origin.y
            self.scrollView.setContentOffset(CGPoint(x: 0, y: posToScrollTo), animated: true)
        }
        
        return false //don't add line break by default
    }

    func initializeDatePicker(with datePicker: UIDatePicker, textView: UITextField, action: Selector?) {
        let toolbar = UIToolbar();
        toolbar.sizeToFit()

        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .plain,
            target: self,
            action: action
        )

        let spaceButton = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )

        let cancelButton = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelDatePicker(sender:))
        )

        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: true)

        // add toolbar to eventFromDateTextfield
        textView.inputAccessoryView = toolbar
        // add datepicker to eventFromDateTextfield
        textView.inputView = datePicker
    }


    @objc func setDateText(textField: UITextField, datePicker: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = DATE_FORMAT
        textField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }

    @objc func doneDatePickerFrom(sender: UIBarButtonItem){
        setDateText(textField: eventFromDateTextfield, datePicker: datePickerFrom)
    }

    @objc func doneDatePickerTo(sender: UIBarButtonItem) {
        setDateText(textField: eventToDateTextfield, datePicker: datePickerTo)
    }

    @objc func cancelDatePicker(sender: UIBarButtonItem){
        self.view.endEditing(true)
    }

    func addTag(){
        let tagTextMaxLength = 50
        var tagText = eventTagsTextfield.text ?? ""
        if !tagText.isEmpty {
            //truncate if too long
            if (tagText.count > tagTextMaxLength) {
                let dropChars = tagText.count - tagTextMaxLength
                tagText = String(tagText.dropLast(dropChars))
            }
            //check if tag already exists
            if !tagArray.contains (tagText) {
                tagArray.insert(tagText, at: 0)
                tagView.insertTag(tagText, at: 0)
                let tagHeight = tagView.intrinsicContentSize.height;
                if (Int(tagHeight) > self.tagListHeight) {
                    self.scrollView.contentSize.height += 28
                    self.contentViewHeightConstraint.constant += 28 //so the button remains clickable
                    self.tagListHeight = Int(tagHeight)
                }
            }
            // erase tag textfield
            eventTagsTextfield.text = ""
        }
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        self.tagView.removeTag(title)
        self.tagArray = tagArray.filter{ $0 != title }
    }
}
