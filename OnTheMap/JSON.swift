//
//  JSON.swift
//  OnTheMap
//
//  Created by Erwin Santacruz on 7/20/15.
//  Copyright (c) 2015 Erwin Santacruz. All rights reserved.
//

import Foundation

class JSON {
    var error: NSError?
    
     var parsedObject: AnyObject
    
    init(parsedObject: AnyObject)
    {
        self.parsedObject = parsedObject
    }
    
    subscript(index: Int) -> JSON? {
        if let item = parsedObject as? NSArray {
            return JSON(parsedObject: item[index])
        }
        else {
            return nil
        }
    }
    
    subscript(key: String) -> JSON? {
        if let item = parsedObject as? NSDictionary {
            if item[key] != nil {
                return JSON(parsedObject: item[key]!)
            }
        }
        
        return nil
    }
    
    var stringValue: String {
        get {
            return parsedObject as! String
        }
    }
    
    var intValue: Int {
        get {
            return parsedObject as! Int
        }
    }

}