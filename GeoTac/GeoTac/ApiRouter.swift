//
//  ApiRouter.swift
//  GeoTac
//
//  Created by Ace_Rimmer on 6/18/16.
//  Copyright © 2016 HackTacoma. All rights reserved.
//

import Alamofire
import Foundation

enum ApiRouter: URLRequestConvertible
{
    case Admin(String)
    
    static let adminURL = "https://\(Constants.cloudinaryAPI!.key):\(Constants.cloudinaryAPI!.secret)@api.cloudinary.com/v1_1/hacktacoma/resources/image/upload/"
    
    var URLRequest: NSMutableURLRequest
    {
        let result: (path: String, method: Alamofire.Method, parameters: [String: AnyObject]?, headerValue: String) = {
            switch self
            {
                case .Admin(let imageID):
                    let credentialData = "\(Constants.cloudinaryAPI?.key):\(Constants.cloudinaryAPI?.secret)".dataUsingEncoding(NSUTF8StringEncoding)!
                    let base64Credentials = credentialData.base64EncodedStringWithOptions([])
                    let headerV = "Basic \(base64Credentials)"
                    let parameter = ["image_metadata": 1, "coordinates": 1]
                    return ("\(imageID)", .GET, parameter, headerV)
            }
        }()
        
        let URL = NSURL(string: ApiRouter.adminURL)!
        let URLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(result.path))
        
        URLRequest.HTTPMethod = result.method.rawValue
        URLRequest.setValue(result.headerValue, forHTTPHeaderField: "Authorization")
        URLRequest.timeoutInterval = NSTimeInterval(10 * 1000)
        
        let encoding = Alamofire.ParameterEncoding.URL
        return encoding.encode(URLRequest, parameters: result.parameters).0
    }
}