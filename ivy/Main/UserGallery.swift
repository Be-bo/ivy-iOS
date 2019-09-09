//
//  UserGallery.swift
//  ivy
//
//  Created by Robert on 2019-09-09.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit
import Firebase

class UserGallery: UIViewController {
    
    // MARK: Variables and Constants
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    private let baseStorageReference = Storage.storage().reference()
    private let baseDatabaseReference = Firestore.firestore()
    public var previousVC = ViewFullProfileActivity()
    public  var pages: [galleryImageView] = []
    private var deleteVisible = false
    private var otherUserProfile = Dictionary<String, Any>()
    public var thisUniDomain = String()
    public var otherUserId = ""
    public var galleryUpdated = false //passed through segue from phot adder
    
    
    
    // MARK: Base Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    func setUp(){
        view.bringSubviewToFront(pageControl)
        getOtherUserProfile()
        if #available(iOS 11.0, *){
            scrollView.contentInsetAdjustmentBehavior = .never
        }else{
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    func setUpNavigationBar(){
        let titleView = MediumGreenLabel()
        titleView.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        if let fName = otherUserProfile["first"] as? String{
            let concatTitle = fName + "'s Gallery"
            titleView.text = concatTitle
        }else{
            titleView.text = "Gallery"
        }
        titleView.textAlignment = .center
        navigationItem.titleView = titleView
    }
    
    func setUpScrollView(){
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(self.pages.count), height: view.frame.height)  //creates multiple pages
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< self.pages.count{ //setup frame of each image present that the user has, take width of screen, multiple that for # of pages..
            self.pages[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            scrollView.addSubview(self.pages[i])
        }
    }
    
    
    
    
    
    
    
    
    
    
    // MARK: Database Interaction Functions
    
    func getOtherUserProfile(){
        if otherUserId != nil && thisUniDomain != nil{ //if we have the minimum necessary data for Firestore retreival
            self.baseDatabaseReference.collection("universities").document(thisUniDomain).collection("userprofiles").document(otherUserId).getDocument { (docSnap, err) in //get the profile of the user who's gallery we're viewing
                if err != nil{
                    print("Error obtaining user's profile in user gallery: ", err)
                }else{
                    if let unwrappedData = docSnap?.data(){
                        self.otherUserProfile = unwrappedData
                        self.setUpNavigationBar()
                        self.loadImages()
                    }
                }
            }
        }
    }
    
    func loadImages(){ //extract all the users profile pictures
        if let arr = self.otherUserProfile["picture_references"] as? [String]{ //get user's pics
            if (!arr.isEmpty){
                
                for imagePath in arr{   //for every path in picture references
                    baseStorageReference.child(imagePath).getData(maxSize: 2 * 1024 * 1024) { (data, e) in //using image page, extract the image that is at that location
                        if let e = e {
                            print("Error obtaining image: ", e)
                        }else{
                            let page: galleryImageView = Bundle.main.loadNibNamed("galleryImageView", owner: self, options: nil)?.first as! galleryImageView
                            page.imageView.image = UIImage(data: data!)
                            page.pictureReference = imagePath
                            self.pages.append(page) //append this image to the pages
                            self.pageControl.numberOfPages = self.pages.count
                            self.pageControl.currentPage = 0
                            self.setUpScrollView()
                        }
                    }
                }
            }
        }
    }
}

extension UserGallery: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
}
