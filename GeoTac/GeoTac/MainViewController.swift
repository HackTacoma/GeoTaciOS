//
//  MainViewController.swift
//  GeoTac
//
//  Created by Ace_Rimmer on 6/18/16.
//  Copyright © 2016 HackTacoma. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CryptoSwift

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    var imageData: NSData?
    @IBOutlet weak var uiImageView: UIImageView!
    @IBOutlet weak var uploadButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.uiImageView.image = nil
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Album", style: .Plain, target: self, action: #selector(choosePhoto))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: #selector(takePhoto))
        self.title = "TACOMA"
        
        self.configureButton()
    }
    
    //MARK: - Outlet Actions
    
    @IBAction func uploadCoordinates(sender: UIButton)
    {
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
    
    //MRK: - UIImagePicker Delegates
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            self.imageData = UIImageJPEGRepresentation(image, 0.0)
            self.uiImageView.image = image
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
