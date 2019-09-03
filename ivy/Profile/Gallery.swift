//
//  Gallery.swift
//  ivy
//
//  Created by paul dan on 2019-09-02.
//  Copyright © 2019 ivy social network. All rights reserved.
//

//this class handles the logic forthe profiles gallery where you can edit your profile picture
import UIKit
import Firebase
import FirebaseCore
import FirebaseStorage
import FirebaseFirestore


class Gallery: UIViewController {
    
    private let baseStorageReference = Storage.storage().reference()
    private let baseDatabaseReference = Firestore.firestore()                    //reference to the database

    
    
    private var pages: [galleryImageView] = []                                      //represents all the pages in the gallery
    private var deleteVisible = false                                               //indicating whether the delete button should be shown or not
    private var thisUserProfile:Dictionary<String,Any>? = nil

    //passed through segue from profile
    public var thisUniDomain = String()
    public var thisUserId = ""
    
    //passed through segue from phot adder
    public var galleryUpdated = false                                               //Bool indicating that the gallery was updated or not
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.bringSubviewToFront(pageControl)
        
        setUpNavigationBar()
        getThisUserProfile()    //everytime we load we wanna repull from db to have the accurate amount of picture references.
//        loadImages()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        
    }
    
    

    private func setUpNavigationBar(){
        let titleView = MediumGreenLabel()
        titleView.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        titleView.text = "My Gallery"
        titleView.textAlignment = .center
        navigationItem.titleView = titleView
    
        
        let addButton = UIButton(type: .custom)
        addButton.frame = CGRect(x: 0.0, y: 0.0, width: 45, height: 35)
        addButton.setImage(UIImage(named:"plus"), for: .normal)
        addButton.addTarget(self, action: #selector(self.didTapAddButton), for: .touchUpInside)
        
        let addBarItem = UIBarButtonItem(customView: addButton)
        var currWidth = addBarItem.customView?.widthAnchor.constraint(equalToConstant: 35)
        currWidth?.isActive = true
        var currHeight = addBarItem.customView?.heightAnchor.constraint(equalToConstant: 35)
        currHeight?.isActive = true
        
        
        
        let chooseProfileButton = UIButton(type: .custom)
        chooseProfileButton.frame = CGRect(x: 0.0, y: 0.0, width: 45, height: 35)
        chooseProfileButton.setImage(UIImage(named:"set_profile_picture"), for: .normal)
        chooseProfileButton.addTarget(self, action: #selector(self.didTapChooseProfileButton), for: .touchUpInside)
        
        let chooseProfileItem = UIBarButtonItem(customView: chooseProfileButton)
        currWidth = chooseProfileItem.customView?.widthAnchor.constraint(equalToConstant: 35)
        currWidth?.isActive = true
        currHeight = chooseProfileItem.customView?.heightAnchor.constraint(equalToConstant: 35)
        currHeight?.isActive = true
        
        
        
        
        let deleteButton = UIButton(type: .custom)
        deleteButton.frame = CGRect(x: 0.0, y: 0.0, width: 45, height: 35)
        deleteButton.setImage(UIImage(named:"trash"), for: .normal)
        deleteButton.addTarget(self, action: #selector(self.didTapDeleteButton), for: .touchUpInside)
        
        let deleteItem = UIBarButtonItem(customView: deleteButton)
        currWidth = deleteItem.customView?.widthAnchor.constraint(equalToConstant: 35)
        currWidth?.isActive = true
        currHeight = deleteItem.customView?.heightAnchor.constraint(equalToConstant: 35)
        currHeight?.isActive = true
        
        
        self.navigationItem.rightBarButtonItems = [addBarItem, deleteItem, chooseProfileItem]
        

    }
    
    //segue over to the page where they can create a new picture
    @objc func didTapAddButton(sender: AnyObject){
        self.performSegue(withIdentifier: "galleryToAddPhoto" , sender: self) //pass data over to

    }
    
    //called every single time a segway is called
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! PhotoAdder
        vc.thisUserProfile = self.thisUserProfile
        vc.thisUniDomain = self.thisUniDomain
        vc.thisUserId = self.thisUserId
    }
    
    
    //TODO: figure out how to update the profile picture on the previous screen once this one has been updated.
    @objc func didTapChooseProfileButton(sender: AnyObject){
        let currentPos = self.pageControl.currentPage
        let currentPath = self.pages[currentPos].pictureReference
        
        //if user selected an image thats already profile pic, then do nothing
        if (self.thisUserProfile!["profile_picture"] as! String != self.pages[currentPos].pictureReference){
            
            
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile!["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile!["id"] as! String).updateData(["profile_picture": currentPath], completion: { (error) in
                if error != nil {
                    print("oops, an error")
                } else {
                    //TODO: allowInteraction
                    //TODO: cancel the dialog box that prompts them if they wanna choose this profile pic or not
                }
            })
            
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile!["uni_domain"] as! String).collection("userpreviews").document(self.thisUserProfile!["id"] as! String).updateData(["profile_picture":currentPath])
            self.thisUserProfile!["profile_picture"] = currentPath
            
            //update newly  selected picture prev in firebase
            baseStorageReference.child(self.thisUserProfile!["profile_picture"] as! String).getData(maxSize: 2 * 1024 * 1024) { (data, e) in
                if let e = e {
                    print("Error obtaining image: ", e)
                }else{
                    var userId = self.thisUserProfile!["id"] as! String
                    var newProfilePicCompressed = UIImage(data: data! as Data,scale: 0.25)
                    let previewImageBytes = (newProfilePicCompressed!.jpegData(compressionQuality: 0.25)!) as NSData//convert the compressed
                    self.baseStorageReference.child("userimages/"+userId+"/preview.jpg").putData(previewImageBytes as Data, metadata: nil)
                }
            }
        }else{
            //TODO: allowInteraction
            //TODO: cancel the dialog box that prompts them if they wanna choose this profile pic or not
        }
        
    }
    
    
    //TODO: figure out how to update the profile picture on the previous screen once this one has been updated. 
    @objc func didTapDeleteButton(sender: AnyObject){
//        var currentPos = Int(self.scrollView.contentOffset.x / self.scrollView.frame.size.width)
        let currentPos = self.pageControl.currentPage
        //if user deletes current profile pic
        if (self.thisUserProfile!["profile_picture"] as! String == self.pages[currentPos].pictureReference){
            
            //get highest avaialbwe pos to replace
            var availablePos:[Int] = []
            for i in 0 ..< self.pages.count{
                if (i != currentPos){
                    availablePos.append(i)
                    
                }
            }
            //replace old profile pic
            self.thisUserProfile!["profile_picture"] = self.pages[availablePos[0]].pictureReference
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile!["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile!["id"] as! String).updateData(["profile_picture":self.pages[availablePos[0]].pictureReference])
            
            //update newly  selected picture prev in firebase
            baseStorageReference.child(self.thisUserProfile!["profile_picture"] as! String).getData(maxSize: 2 * 1024 * 1024) { (data, e) in
                if let e = e {
                    print("Error obtaining image: ", e)
                }else{
                    var userId = self.thisUserProfile!["id"] as! String
                    var newProfilePicCompressed = UIImage(data: data! as Data,scale: 0.25)
                    let previewImageBytes = (newProfilePicCompressed!.jpegData(compressionQuality: 0.25)!) as NSData//convert the compressed
                    self.baseStorageReference.child("userimages/"+userId+"/preview.jpg").putData(previewImageBytes as Data, metadata: nil)
                }
            }
        }
        //delete image in firebase
        self.baseStorageReference.child(self.pages[currentPos].pictureReference).delete()
        self.baseDatabaseReference.collection("universities").document(self.thisUserProfile!["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile!["id"] as! String).updateData(["picture_references":FieldValue.arrayRemove([self.pages[currentPos].pictureReference])], completion: { (error) in
            if error != nil {
                print("error trying to update picture references in gallery.swift")
            }
            //else updated fine, so remove the picture reference from the array of pic references
            var pics = self.thisUserProfile!["picture_references"] as! [String]
            if (!pics.isEmpty){
                pics.removeAll { $0 == self.pages[currentPos].pictureReference}
                self.pages = [] //clear the pages array so were not always appening the same image
                self.thisUserProfile!["picture_references"] = pics
                self.loadImages()

            }
        })
    }
    
    func getThisUserProfile() {
        
        if (self.thisUserId == "" || self.thisUniDomain == ""){
            if (self.thisUserProfile == nil){   //no profile
                let user = Auth.auth().currentUser  //get the current user that was just created above
                if let user = user {
                    self.thisUserId = user.uid  //user id unique to firebase project
                }
                if (self.thisUniDomain != "" && self.thisUserId != ""){
                    self.baseDatabaseReference.collection("universities").document(self.thisUniDomain).collection("userprofiles").document(self.thisUserId).getDocument { (document, error) in
                        if let document = document, document.exists {
                            self.thisUserProfile = document.data()
                            self.loadImages()
                            
                        } else {
                            print("Document does not exist")
                        }
                    }
                }else{
                    self.dismiss(animated: true)
                }
                
            }else{
                self.baseDatabaseReference.collection("universities").document(self.thisUserProfile!["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile!["id"] as! String).getDocument { (document, error) in
                    if let document = document, document.exists {
                        self.thisUserProfile = document.data()
                        self.loadImages()
                    } else {
                        print("Document does not exist")
                    }
                }
            }
        }else{
            self.baseDatabaseReference.collection("universities").document(self.thisUniDomain).collection("userprofiles").document(self.thisUserId).getDocument { (document, error) in
                if let document = document, document.exists {
                    self.thisUserProfile = document.data()
                    self.loadImages()
                } else {
                    print("Document does not exist")
                }
            }

        }
        
    }
    
    
    
    //setup the scroll view, takes all the pages that are present in our array and populates the scroll view with them
    func setupScrollView(){
        
        //TODO: figure out why scroll view always has empty space on bottom of pictures.
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(self.pages.count), height: view.frame.height)  //creates multiple pages
        scrollView.isPagingEnabled = true
        
        
        print("self.pages.count", self.pages.count)
        //setup frame of each image present that the user has, take width of screen, multiple that for # of pages..
        for i in 0 ..< self.pages.count{
            self.pages[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            if (pages[i].isProfileImage){   //if its a profile image then make the border green
                pages[i].imageView.layer.borderColor = UIColor.ivyGreen.cgColor
                pages[i].imageView.layer.borderWidth = 5
            }
            scrollView.addSubview(self.pages[i])
        }
    }
    
    
    //load all the images that are present in the storage of this users profile pictures.
    func loadImages() {
        //extract all the users profile pictures
        var arr = self.thisUserProfile!["picture_references"] as! [String]   //arraylist containing all there pic references
        if (!arr.isEmpty){
            for imagePath in arr{   //for every path in picture references
                var isProfileImage = false;
                if (imagePath == self.thisUserProfile!["profile_picture"] as! String){
                    isProfileImage = true
                }
                //using image page, extract the image that is at that location
                baseStorageReference.child(imagePath).getData(maxSize: 2 * 1024 * 1024) { (data, e) in
                    if let e = e {
                        print("Error obtaining image: ", e)
                    }else{
                        let page: galleryImageView = Bundle.main.loadNibNamed("galleryImageView", owner: self, options: nil)?.first as! galleryImageView
                        page.imageView.image = UIImage(data: data!)
                        if (isProfileImage){    //set that current page to contain the bool indicating whther its profile pic or not
                            page.isProfileImage = isProfileImage
                        }
                        page.pictureReference = imagePath
                        self.pages.append(page) //append this image to the pages
                        //everytime this view loads we wanna start on the 0th page
                        self.pageControl.numberOfPages = self.pages.count
                        self.pageControl.currentPage = 0
                        self.setupScrollView()  //TODO: maybe move this to a better spot if I can think of one. For now this works
                    }
                }
            }
        }
        
        
    }
    
    

    
}


//instead of doing class Gallery: UIViewController, UIScrollViewDelegate you can write the code like this to keep thigns seperated
extension Gallery: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
    
    
}
