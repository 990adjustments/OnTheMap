//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Erwin Santacruz on 7/2/15.
//  Copyright (c) 2015 Erwin Santacruz. All rights reserved.
//
//  Login image by Wojtek Witkowski under Creative Commons http://www.pexels.com/photo/city-streets-skyline-buildings-1329/

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var client:OTMClient!
    var appDelegate: AppDelegate!
    var data: [String:AnyObject]?
    var activityIndicator: UIActivityIndicatorView!
    var tapGesture: UITapGestureRecognizer!
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        client = OTMClient.sharedInstance()
        
        tapGesture = UITapGestureRecognizer(target: self, action: Selector("screenTapped:"))
        view.addGestureRecognizer(tapGesture)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loginButton.titleLabel?.text = "Login"
        errorLabel.text = ""
    }
    
    @IBAction func loginAction()
    {
        data = ["udacity":["username": emailTextField.text, "password": passwordTextField.text]]

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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func screenTapped(recognizer: UITapGestureRecognizer)
    {
        dismissKeyboard()
    }
    
    func dismissKeyboard()
    {
        view.endEditing(true)
    }

}
