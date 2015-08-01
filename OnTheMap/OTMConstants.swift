//
//  OTMConstants.swift
//  OnTheMap
//
//  Created by Erwin Santacruz on 7/21/15.
//  Copyright (c) 2015 Erwin Santacruz. All rights reserved.
//

extension OTMClient {
    
    struct Methods {
        static let Session = "https://www.udacity.com/api/session"
        static let UserId = "https://www.udacity.com/api/users/"
        static let Student_Location = "https://api.parse.com/1/classes/StudentLocation"
    }
    
    struct ResponseKeys {
        static let Account = "account"
        static let Registered = "registered"
        static let Key = "key"
        static let Session = "session"
        static let Id = "id"
        static let Expiration = "expiration"
        static let Error = "error"
        static let Status = "status"
    }
    
    struct Parse {
        static let Application_id = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let Key = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
}
