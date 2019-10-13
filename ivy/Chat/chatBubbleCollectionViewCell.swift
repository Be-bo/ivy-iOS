//
//  chatBubbleCollectionViewCell.swift
//  ivy
//
//  Created by paul dan on 2019-09-05.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit
import Firebase

class chatBubbleCollectionViewCell: UICollectionViewCell {

    var messageClickedOn = Dictionary<String, Any>()
    let baseStorageReference = Storage.storage().reference()
    var vc = ChatRoom()
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageContainer: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var fileIcon: UIImageView!
    @IBOutlet weak var fileIconHeight: NSLayoutConstraint!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var fileNameHeight: NSLayoutConstraint!
    @IBOutlet weak var downloadButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoImageHeight: NSLayoutConstraint!
    
    
    @IBAction func downloadClicked(_ sender: Any) { //downloading file
        if messageClickedOn != nil{
            if var fileReference = messageClickedOn["file_reference"] as? String{
                let storageRefPath = self.baseStorageReference.child(fileReference)
                
                
                
                //if the message has a file reference
                if (fileReference != ""){
                    
                    //determine if its an image
                    if ( fileReference.lowercased().contains("jpg") || fileReference.lowercased().contains("jpeg") || fileReference.lowercased().contains("png") ) {
                        // Fetch the download URL
                        storageRefPath.getData(maxSize: 5 * 1024 * 1024) { data, error in
                            if let error = error {
                                print("error", error)
                            } else {
                                var downloadedImage = UIImage(data: data!)
                                UIImageWriteToSavedPhotosAlbum(downloadedImage!, Any?.self, nil, nil)
                                //prompt the user with a dialog saying the image has been downloaded to the photos folder
                                let alert = UIAlertController(title: "Your photo has been saved to the camera roll!", message: .none , preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                                self.vc.present(alert, animated: true)
                            }
                        }
                    }else{
                        // Fetch the download URL
                        storageRefPath.downloadURL { url, error in
                            if let error = error {
                                // Handle any errors
                            } else {
                                print("else")
                                
                                // Get the download URL for 'images/stars.jpg'
                                DispatchQueue.main.async {
                                    //                            let url = URL(string: urlString)
                                    let pdfData = try? Data.init(contentsOf: url!)
                                    let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
                                    
                                    let pdfNameFromUrl = fileReference.components(separatedBy: "/").last!.replacingOccurrences(of: " ", with: "")
                                    
                                    let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
                                    do {
                                        try pdfData?.write(to: actualPath, options: .atomic)
                                        let alert = UIAlertController(title: "Your file has been saved to the files folder!", message: .none , preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                                        self.vc.present(alert, animated: true)
                                        
                                    } catch {
                                        print("Pdf could not be saved")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUp(msg: Dictionary<String, Any>, rulingVC: ChatRoom){
        messageClickedOn = msg
        vc = rulingVC
    }

}
