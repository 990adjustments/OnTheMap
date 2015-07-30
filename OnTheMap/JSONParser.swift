//
//  JSONParser.swift
//  OnTheMap
//
//  Created by Erwin Santacruz on 7/20/15.
//  Copyright (c) 2015 Erwin Santacruz. All rights reserved.
//

import Foundation

class JSONParser {
    
    class func parse(data: NSData, inout error: NSError?) -> JSON? {
        var parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &error)
        //println(parsedObject)

        if let obj: AnyObject = parsedObject {
            return JSON(parsedObject: obj)
        }

        // Error has occurred
        println("ERROR STATE")
        return nil

    }
    
}