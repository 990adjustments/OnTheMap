//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Erwin Santacruz on 7/13/15.
//  Copyright (c) 2015 Erwin Santacruz. All rights reserved.
//

import Foundation
import UIKit

class OTMClient: NSObject {
    
    var session: NSURLSession
    var appDelegate: AppDelegate!
    
    override init()
    {
        session = NSURLSession.sharedSession()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        super.init()
    }
    
    func GetParse(url: String, extra: String?, stripCharacters: Bool, completionHandler: (JSON?, NSError?) -> ())
    {
        let url = NSURL(string: url)
        
        var request = NSMutableURLRequest(URL: url!)
        request.addValue(OTMClient.Parse.Application_id, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(OTMClient.Parse.Key, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = createTask(request, stripCharacters: stripCharacters, completionHandler: completionHandler)
        task.resume()
    }
    
    func GetParseUser(url: String, extra: String?, stripCharacters: Bool, completionHandler: (JSON?, NSError?) -> ())
    {
        let url = NSURL(string: url)
        
        var request = NSMutableURLRequest(URL: url!)
        request.addValue(OTMClient.Parse.Application_id, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(OTMClient.Parse.Key, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = createTask(request, stripCharacters: stripCharacters, completionHandler: completionHandler)
        task.resume()
    }
    
    func PutParseUser(url: String, data: [String:AnyObject], stripCharacters: Bool, completionHandler: (JSON?, NSError?) -> ())
    {
        let url = NSURL(string: url)
        
        var request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        request.addValue(OTMClient.Parse.Application_id, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(OTMClient.Parse.Key, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var paramError: NSError?
        var paramData = NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions.allZeros, error: &paramError)
        
        request.HTTPBody = paramData
        
        let task = createTask(request, stripCharacters: stripCharacters, completionHandler: completionHandler)
        task.resume()
    }
    
    func PostParse(url: String, data: [String:AnyObject], stripCharacters: Bool, completionHandler:(JSON?, NSError?) -> ())
    {
        let url = NSURL(string: url)
        
        var request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.addValue(OTMClient.Parse.Application_id, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(OTMClient.Parse.Key, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var paramError: NSError?
        var paramData = NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions.allZeros, error: &paramError)
        
        request.HTTPBody = paramData
        
        let task = createTask(request, stripCharacters: stripCharacters, completionHandler: completionHandler)
        task.resume()
    }
    
    func Post(url: String, data: [String:AnyObject], stripCharacters: Bool, completionHandler:(JSON?, NSError?) -> ())
    {
        let url = NSURL(string: url)
        
        var request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var paramError: NSError?
        var paramData = NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions.allZeros, error: &paramError)
        
        request.HTTPBody = paramData
        
        let task = createTask(request, stripCharacters: stripCharacters, completionHandler: completionHandler)
        task.resume()
    }
    
    
    func LogOut(url: String, stripCharacters: Bool, completionHandler:(JSON?, NSError?) -> ())
    {
        let url = NSURL(string: url)
        
        var request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "DELETE"
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
        }
        
        let task = createTask(request, stripCharacters: stripCharacters, completionHandler: completionHandler)
        task.resume()
    }
    
    func createTask(request: NSURLRequest, stripCharacters: Bool, completionHandler:(JSON?, NSError?)->() ) -> NSURLSessionDataTask
    {
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            if let err = error {
                completionHandler(nil, err)
            }
            else {
                //println(response)
                
                // Parse the data
                var parseError: NSError?
                
                // First five characters are used for security purposes. Need to skip them
                var parsedData: JSON?
                
                if stripCharacters {
                    var newdata = self.skipFirstFiveCharacters(data)
                    parsedData = JSONParser.parse(newdata, error: &parseError)
                }
                else {
                    parsedData = JSONParser.parse(data, error: &parseError)
                }
                
                if let err = parseError {
                    completionHandler(nil, err)
                }
                else {
                    println("PARSING DATA SUCCESSFUL")
                    completionHandler(parsedData, nil)
                }
            }
        })
        
        return task
    }
    
    func StoreUserData(data: JSON?)
    {
        if let jsonData = data {
            if let key = jsonData[OTMClient.ResponseKeys.Account]?[OTMClient.ResponseKeys.Key]?.stringValue {
                var method = "\(OTMClient.Methods.UserId)\(key)"

                self.GetParse(method, extra: nil, stripCharacters: true) { (json, error) -> () in
                    if let jdata = json {
                        self.appDelegate.userDetails["key"] = jdata["user"]?["key"]?.stringValue
                        self.appDelegate.userDetails["lastName"] = jdata["user"]?["last_name"]?.stringValue
                        self.appDelegate.userDetails["firstName"] = jdata["user"]?["first_name"]?.stringValue
                    }
                }
            }
        }
    }

    func skipFirstFiveCharacters(data: NSData!) -> NSData
    {
        return data.subdataWithRange(NSMakeRange(5, data.length - 5))
    }
    
    // MARK: - Class Functions
    
    class func sharedInstance() -> OTMClient {
        
        struct Singleton {
            static let sharedInstance: OTMClient = OTMClient()
        }
        
        return Singleton.sharedInstance
    }
    
    class func LoginJSONKeys(data: JSON?) -> (Int?, String?)
    {
        if let jsonData = data {
            // Get JSON key values
            if let registered: Int = jsonData[OTMClient.ResponseKeys.Account]?[OTMClient.ResponseKeys.Registered]?.intValue {
                //println("LOGIN SUCCESSFUL")
                return (registered, nil)
            }
            
            // Authentication error
            if let errorString: String = jsonData["error"]?.stringValue {
                println(errorString)
                return (nil, errorString)
            }
        }
        return (nil, nil)
    }

    class func MapJSONKeys(data: JSON?) -> [StudentInformation]?
    {
        var students:[StudentInformation]?
        
        if let jsonData = data {
            var results = jsonData.parsedObject.valueForKey("results") as! NSArray
            students = StudentInformation.studentsFromResults(results)
        }
        
        return students
    }

}
