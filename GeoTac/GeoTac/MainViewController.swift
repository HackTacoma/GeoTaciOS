//
//  MainViewController.swift
//  GeoTac
//
//  Created by Ace_Rimmer on 6/18/16.
//  Copyright © 2016 HackTacoma. All rights reserved.
//

import UIKit
import Firebase
import Photos
import Alamofire
import SwiftyJSON
import CryptoSwift

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    var imageData: NSData?
    var imageExif: [String: AnyObject]?
    var FirebaseRef: FIRDatabaseReference!
    
    @IBOutlet weak var uiImageView: UIImageView!
    @IBOutlet weak var uploadButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.uiImageView.image = nil
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Album", style: .Plain, target: self, action: #selector(choosePhoto))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: #selector(takePhoto))
        self.title = "TACOMA"
        
        // Firebase
        FirebaseRef = FIRDatabase.database().reference()
        
        self.configureButton()
    }
    
    //MARK: - Outlet Actions
    
    @IBAction func uploadCoordinates(sender: UIButton)
    {
        var imageID: String!
        
        let timeStamp = Int(NSDate().timeIntervalSince1970)
        let authString = "timestamp=\(timeStamp)\(Constants.cloudinaryAPI!.secret)"
        let authSignature = authString.sha1()
        
        let parameters = [
            "timestamp" : "\(timeStamp)",
            "api_key" : "\(Constants.cloudinaryAPI!.key)",
            "signature" : authSignature
        ]
        
        Alamofire.upload(.POST, Constants.uploadURL,
                         multipartFormData: { [unowned self] (multi) -> Void in
                            
                            multi.appendBodyPart(data: self.imageData!, name: "file", fileName: "file", mimeType: "image/jpeg")
                            
                            for (key, value) in parameters
                            {
                                multi.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
                            }
            
            },
                         encodingCompletion: { [unowned self] (encodingResult) -> Void in
                            
                            switch encodingResult
                            {
                                case .Success(let upload, _, _):
                                    upload.responseJSON() { [unowned self] (response) -> Void in
                                        
                                        if let data = response.result.value
                                        {
                                            let json = JSON(data)
                                            let imageID = json["public_id"].stringValue
                                            
                                            self.requestExif(imageID)
                                            
                                            self.delay(3) {
                                                self.FirebaseRef.child("imageMetaData").childByAutoId().setValue(self.imageExif)
                                            }
                                            
                                        }
                                        
                                        let modal = UIAlertController(title: "Success", message: "Thank you for being a good Citizen of Tacoma", preferredStyle: .Alert)
                                        let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                                        modal.addAction(okAction)
                                        self.uiImageView.image = nil
                                        self.uploadButton.backgroundColor = UIColor.whiteColor()
                                        self.uploadButton.layer.cornerRadius = 0
                                        self.configureButton()
                                        self.presentViewController(modal, animated: true, completion: nil)
                                }
                                
                                case .Failure(let error):
                                    print(error)
                            }
        })
    }
    
    private func requestExif(publicID: String)
    {
        Alamofire.request(ApiRouter.Admin(publicID)).responseJSON() { (response) -> Void in
            if let data = response.result.value
            {
                let json = JSON(data)
                self.imageExif = json.dictionaryObject! as [String: AnyObject]
            }
        }
    }
    
    //MARK: - VC Methods
    
    @objc private func configureButton()
    {
        self.uploadButton.enabled = (uiImageView.image == nil) ? false : true
        
        if self.uploadButton.enabled
        {
            UIView.animateWithDuration(1.5) { [unowned self] () -> Void in
                self.uploadButton.alpha = 1.0
                self.uploadButton.backgroundColor = UIColor.redColor()
                self.uploadButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                self.uploadButton.layer.cornerRadius = self.uploadButton.frame.size.width / 2
            }
        }
    }
    
    @objc private func choosePhoto()
    {
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)
        {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .PhotoLibrary
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    @objc private func takePhoto()
    {
        if UIImagePickerController.isSourceTypeAvailable(.Camera)
        {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .Camera
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let modal = UIAlertController(title: "Sorry", message: "This device does not support camera use", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            modal.addAction(okAction)
            self.presentViewController(modal, animated: true, completion: nil)
        }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    //MRK: - UIImagePicker Delegates
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        
        if let image = info[UIImagePickerControllerReferenceURL] as? NSURL
        {
            let asset = PHAsset.fetchAssetsWithALAssetURLs([image], options: nil)
            
            if let firstAsset = asset.firstObject as? PHAsset
            {
                let manager = PHImageManager()
                manager.requestImageDataForAsset(firstAsset, options: nil) { (data) -> Void in
                    
                    self.imageData = data.0!
                    self.uiImageView.image = UIImage(data: self.imageData!)
                }
            }
            
            self.uiImageView.layoutIfNeeded()
            self.configureButton()
            self.dismissViewControllerAnimated(true) { [unowned self] () -> Void in
                self.uploadButton.alpha = 0
                var timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(self.configureButton), userInfo: nil, repeats: false)
                
                timer.fire()
            }
            
        }
    }
}
