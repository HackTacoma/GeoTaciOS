//
//  Constants.swift
//  GeoTac
//
//  Created by Ace_Rimmer on 6/18/16.
//  Copyright © 2016 HackTacoma. All rights reserved.
//

import Foundation

struct Constants
{
    static let uploadURL = "https://api.cloudinary.com/v1_1/hacktacoma/image/upload"
    
    static private(set) var cloudinaryAPI: (key: String, secret: String)? = {
        if let path = NSBundle.mainBundle().pathForResource("keys", ofType: "plist")
        {
            let apiDictionary = NSDictionary(contentsOfFile: path)
            return (key: apiDictionary!["api_key"]! as! String, secret: apiDictionary!["api_secret"]! as! String)
        }
        else
        {
            return nil
        }
    }()
}