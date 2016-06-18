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
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Album", style: .Plain, target: self, action: #selector(choosePhoto))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: #selector(takePhoto))
        self.title = "TACOMA"
    }
    
    //MARK: - Outlet Actions
    
    @IBAction func uploadCoordinates(sender: UIButton)
    {
        
    }
    
    //MARK: - VC Methods
    
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
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
