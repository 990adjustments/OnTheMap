//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Erwin Santacruz on 7/2/15.
//  Copyright (c) 2015 Erwin Santacruz. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    var client:OTMClient!
    var appDelegate: AppDelegate!
    var data: [String:AnyObject]?
    var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    //@IBOutlet weak var bgImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        client = OTMClient.sharedInstance()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loginButton.titleLabel?.text = "Login"
        errorLabel.text = ""
    }
    
    @IBAction func loginAction()
    {
        //data = ["udacity":["username": emailTextField.text, "password": passwordTextField.text]]
        data = ["udacity":["username": "hi@990adjustments.com", "password": "just-l3arn-1t-uda"]]

        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        activityIndicator.center = CGPointMake(CGRectGetMidX(view.frame), CGRectGetMidY(view.frame) - 100)
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        client.Post(OTMClient.Methods.Session, data: data!, stripCharacters: true) { (json, error) in
            if let err = error {
                println(err.localizedDescription)
                self.displayError(err.localizedDescription)

                return
            }
            
            if let jsonData = json {
                var result = OTMClient.LoginJSONKeys(jsonData)
                
                if let errorString = result.1 {
                    self.displayError(errorString)
                }
                
                if let success = result.0 {
                    if success == 1 {
                        self.client.StoreUserData(jsonData)
                        self.activityIndicator.stopAnimating()
                        self.completeLogin()
                    }
                }
            }
        }
    }
    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.errorLabel.text = ""
            self.loginButton.titleLabel?.text = "Login"
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("NavController") as! UINavigationController
            self.presentViewController(vc, animated: true, completion: nil)
        })
    }
    
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            self.loginButton.titleLabel?.text = "Login"
            self.activityIndicator.stopAnimating()
            
            if let errorString = errorString {
                self.showAlert(errorString)
            }
        })
    }
    
    func showAlert(error:String?)
    {
        let alertController = UIAlertController(title: "Authentication Error" , message: error, preferredStyle: UIAlertControllerStyle.Alert)
        let retryAction = UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default) { (action) in
            self.loginAction()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(retryAction)
        presentViewController(alertController, animated: true, completion: nil)

    }

}
