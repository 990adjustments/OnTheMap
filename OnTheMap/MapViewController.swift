//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Erwin Santacruz on 7/24/15.
//  Copyright (c) 2015 Erwin Santacruz. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate {
    let annotationIdentifier = "ANNOT"
    let animationDuration = 0.4
    
    var client: OTMClient!
    var students: Students!
    var pin: MapPin!
    var appDelegate: AppDelegate!
    var studentStruct: StudentInformation!
    var params:[String: AnyObject]!
    var tapGesture: UITapGestureRecognizer!
    var annotationTapGesture: UITapGestureRecognizer!
    var activityIndicator: UIActivityIndicatorView!
    var logOutButton: UIBarButtonItem!
    var addButton: UIBarButtonItem!
    var refreshButton: UIBarButtonItem!
    var overwrite: Bool!
    var pinImg: UIImage?
    var newPin: Bool!
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var infoTextField: UITextField!
    @IBOutlet weak var mediaURLTextField: UITextField!
    @IBOutlet weak var userInfoView: UIView!
    @IBOutlet weak var userInfoViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            self.mapView.mapType = .Standard
            self.mapView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        client = OTMClient.sharedInstance()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        params = [String: AnyObject]()
        pinImg = UIImage(named: "pin")
        overwrite = false
        
        tapGesture = UITapGestureRecognizer(target: self, action: Selector("screenTapped:"))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        configureUI()
        mapsRequest()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Deselect any callouts
        var annot = mapView.annotations
        
        for i in annot {
            if let a = i as? MKAnnotation {
                mapView.deselectAnnotation(a, animated: true)
            }
        }
        
        overwrite = false
        newPin = false
        resetInfoView()
    }
    
    func configureUI()
    {
        // Tint the tabbar icons
        tabBarController?.tabBar.tintColor = UIColor(red: 235.0/255, green: 175.0/255, blue: 45.0/255, alpha: 1.0)
        
        userInfoViewConstraint.constant = 0.0
        overwrite = false
        newPin = false
        
        infoTextField.delegate = self
        mediaURLTextField.delegate = self
        
        // textfield for mediaURL
        mediaURLTextField.enabled = false
        mediaURLTextField.hidden = true
        
        // Set UIBar items
        logOutButton = tabBarController?.navigationItem.leftBarButtonItem
        logOutButton?.target = self
        logOutButton?.action = Selector("logoutAction:")
        
        addButton = tabBarController?.navigationItem.rightBarButtonItem
        addButton?.target = self
        addButton?.action = Selector("addAction:")
        
        refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: Selector("mapsRequest"))
        
        tabBarController?.navigationItem.setRightBarButtonItems([addButton,refreshButton], animated: true)
    }
    
    func geocodeAddress(location: String, handler: (CLPlacemark?, NSError?) -> ())
    {
        var geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location, completionHandler: { (placemarks, error) -> Void in
            if let err = error {
                return handler(nil, err)
            }
            else {
                if let placemark = placemarks[0] as? CLPlacemark {
                    return handler(placemark, nil)
                }
            }
            
            return handler(nil, nil)
        })
    }

    func logoutAction(sender: AnyObject)
    {
        // Switch back to MapViewController
        //if tabBarController?.selectedViewController != self {
        //    tabBarController?.selectedViewController = self
        //}
        
        client.LogOut(OTMClient.Methods.Session, stripCharacters: true, completionHandler: { (json, error) -> () in
            if let err = error {
                println(err.localizedDescription)
                return
            }
            
            if let jsonData = json {
                dispatch_async(dispatch_get_main_queue()) {
                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("LoginController") as! LoginViewController
                    self.parentViewController?.presentViewController(vc, animated: true, completion: nil)
                }
            }
        })
    }
    
    func addAction(sender: AnyObject)
    {
        // Switch back to MapViewController
        if tabBarController?.selectedIndex == 1 {
            tabBarController?.selectedIndex = 0
        }
        
        var uniqueKeyString = appDelegate.userDetails["key"] as! String
        var stringmethod = "\(OTMClient.Methods.Student_Location_User)\(uniqueKeyString)%22%7D"
        
        client.GetParseUser(stringmethod, extra: nil, stripCharacters: false) { (json, error) -> ()  in
            if let err = error {
                println(err.localizedDescription)
                return
            }
            
            var exists = false
            self.overwrite = false
            self.newPin = false
            
            if let jsonData = json {
                var results = jsonData.parsedObject.valueForKey("results") as! NSArray
                
                for i in results {
                    if let key = i["uniqueKey"] as? String where key == self.appDelegate.userDetails["key"] as! String {
                        //println(i["mapString"])
                        //println(i["objectId"])
                        //println(i["mediaURL"])
                        self.params["objectId"] = i["objectId"] as? String
                        println("User Already Exists.")
                        exists = true
                        break
                    }
                }
                
                // If user has existing pins
                if exists {
                    dispatch_async(dispatch_get_main_queue()) {
                        var message = "User already exists. Would you like to overwrite the current pin?"
                        self.overwriteAlert(message, completionHandler: { (bool) -> () in
                            if bool {
                                println("Will overwrite location")
                                self.overwrite = true
                            }
                        })
                    }
                }
                else {
                    // No pins so a new one will be created
                    self.newPin = true
                    
                    dispatch_async(dispatch_get_main_queue()) {
                    UIView.animateWithDuration(self.animationDuration, delay: 0, options: .CurveEaseOut, animations: {
                        self.userInfoViewConstraint.constant += -212.0
                        self.view.layoutIfNeeded()
                        }, completion: nil)
                    
                    self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: Selector("cancelAction:"))
                    }
                }
            }
        }
    }
    
    func cancelAction(sender: AnyObject)
    {
        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: pinImg, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("addAction:"))

        if let pin = pin {
            mapView.removeAnnotation(pin)
        }
        
        overwrite = false
        newPin = false
        resetInfoView()
    }
    
    @IBAction func locateAction(sender: AnyObject)
    {
        // Setup parameters
        var location = infoTextField.text!
        var firstName = appDelegate.userDetails["firstName"] as! String
        var lastName = appDelegate.userDetails["lastName"] as! String
        var fullName = "\(firstName) \(lastName)"
        
        params["firstName"] = firstName
        params["lastName"] = lastName
        params["mapString"] = location
        
        // Indicate Activity
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        activityIndicator.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(view.frame))
        activityIndicator.hidesWhenStopped = true
        
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        mapView.alpha = 0.5
        
        geocodeAddress(location, handler: { (placemark, error) -> () in
            if let err = error {
                println(err.localizedDescription)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.retryAlert(err.localizedDescription, completionHandler: { (bool) -> () in
                        if bool {
                            self.locateAction(self)
                        }
                        else {
                            return
                        }
                    })
                }
            }
            
            // Create annotation from location
            if let placemark = placemark {
                var coordinates:CLLocationCoordinate2D = placemark.location.coordinate
                self.pin = MapPin(coordinate: coordinates, title: location, subtitle: "")
                self.mapView.addAnnotation(self.pin)
                self.mapView.centerCoordinate = coordinates
                self.mapView.selectAnnotation(self.pin, animated: true)
                self.mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude), MKCoordinateSpanMake(15.0, 15.0)), animated: true)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                // Change action on UIButton
                self.actionButton.removeTarget(self, action: Selector("locateAction:"), forControlEvents: UIControlEvents.TouchUpInside)
                self.actionButton.setTitle("Submit", forState: UIControlState.Normal)
                self.actionButton.addTarget(self, action: Selector("submitAction:"), forControlEvents: UIControlEvents.TouchUpInside)
                
                // Enable/Disable textfields
                self.infoLabel.text = "Add URL"
                self.infoTextField.enabled = false
                self.infoTextField.hidden = true
                self.mediaURLTextField.enabled = true
                self.mediaURLTextField.hidden = false
                self.view.layoutIfNeeded()
            })
            
            self.activityIndicator.stopAnimating()
            self.mapView.alpha = 1.0
        })
    }
    
    func submitAction(sender: AnyObject)
    {
        params["mediaURL"] = mediaURLTextField.text!
        params["uniqueKey"] = appDelegate.userDetails["key"]
        params["latitude"] = pin.coordinate.latitude
        params["longitude"] = pin.coordinate.longitude
        
        // We are going to overwrite existing info
        if overwrite! {
            var objectId = params["objectId"] as! String
            var stringmethod = "\(OTMClient.Methods.Student_Location_Put)\(objectId)"
            
            view.alpha = 0.5
            
            client.PutParseUser(stringmethod, data: params, stripCharacters: false) { (json, error) -> ()  in
                if let err = error {
                    println(err.localizedDescription)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.retryAlert(err.localizedDescription, completionHandler: { (bool) -> () in
                            if bool {
                                self.submitAction(self)
                            }
                            else {
                                return
                            }
                        })
                    }
                }
                
                if let jsonData = json {
                    println("Data has been updated.")
                    println(jsonData.parsedObject)
                    self.mapsRequest()
                    self.resetInfoView()
                }
            }
        }
        // Putting new info on the server
        else {
            var uniqueKeyString = appDelegate.userDetails["key"] as! String
            var stringmethod = "\(OTMClient.Methods.Student_Location_User)\(uniqueKeyString)%22%7D"
            
            self.client.PostParse(OTMClient.Methods.Student_Location_Post, data: self.params, stripCharacters: false) { (json, error) -> () in
                if let err = error {
                    println(err.localizedDescription)
                    return
                }
                
                if let jsonData = json {
                    self.mapsRequest()
                    self.resetInfoView()
                }
            }
        }
    }
    
    func mapsRequest()
    {
        // Get all student locations
        client.GetParse(OTMClient.Methods.Student_Location, extra: "limit=100", stripCharacters: false, completionHandler: { (json, error) -> () in
            if let err = error {
                dispatch_async(dispatch_get_main_queue()) {
                    self.retryAlert(err.localizedDescription, completionHandler: { (bool) -> () in
                        if bool {
                            self.mapsRequest()
                        }
                        else {
                            return
                        }
                    })
                }
            }
            
            if let jsonData = json {
                self.students = Students(students: OTMClient.MapJSONKeys(jsonData)!)
                self.loadData()
            }
        })
    }
    
    func loadData()
    {
        
        dispatch_async(dispatch_get_main_queue()) {
            self.view.alpha = 1.0
            
            var annotations = self.students.getMKAnnotation()
            self.mapView.removeAnnotations(annotations)
            self.mapView.addAnnotations(annotations)
            self.mapView.showAnnotations(annotations, animated: true)
            
            // Check if we are overwriting or creating new annotation
            if self.overwrite! || self.newPin! {
                var coordinates = CLLocationCoordinate2D(latitude: self.params["latitude"] as! Double, longitude: self.params["longitude"] as! Double)
                var span = MKCoordinateSpanMake(5.0, 5.0)
                var region = MKCoordinateRegionMake(coordinates, span)
                self.mapView.centerCoordinate = coordinates
                self.mapView.setRegion(region, animated: true)
                self.mapView.removeAnnotation(self.pin)
                
                var firstName = self.appDelegate.userDetails["firstName"] as! String
                var lastName = self.appDelegate.userDetails["lastName"] as! String
                var fullName = "\(firstName) \(lastName)"
                
                // Show callout on updated annotation
                var mapAnnotations = self.mapView.annotations as! [MKAnnotation]
                for userAnnotation in mapAnnotations {
                    if (userAnnotation.title == fullName) && (userAnnotation.coordinate.latitude == coordinates.latitude) && (userAnnotation.coordinate.latitude == coordinates.latitude){
                        self.mapView.selectAnnotation(userAnnotation as MKAnnotation, animated: true)
                        break
                    }
                }
            }
            else {
                self.geocodeAddress("USA"){ (placemark, error) -> () in
                    if let err = error {
                        println(err.localizedDescription)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.retryAlert(err.localizedDescription, completionHandler: { (bool) -> () in
                                if bool {
                                    self.loadData()
                                }
                                else {
                                    return
                                }
                            })
                        }
                    }
                    
                    // Create annotation from location
                    if let placemark = placemark {
                        var coordinates:CLLocationCoordinate2D = placemark.location.coordinate
                        self.mapView.centerCoordinate = coordinates
                        self.mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude), MKCoordinateSpanMake(100.0, 100.0)), animated: true)
                    }
                }
            }
        }
    }
    
    func resetInfoView()
    {
        dispatch_async(dispatch_get_main_queue()) {
            UIView.animateWithDuration(self.animationDuration, delay: 0, options: .CurveEaseOut, animations: {
                self.userInfoViewConstraint.constant += 212.0
                self.view.layoutIfNeeded()
                }, completion: nil)
            
            // Reset to default
            self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: self.pinImg, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("addAction:"))

            
            // Change action on UIButton
            self.actionButton.removeTarget(self, action: Selector("submitAction:"), forControlEvents: UIControlEvents.TouchUpInside)
            self.actionButton.setTitle("Locate", forState: UIControlState.Normal)
            self.actionButton.addTarget(self, action: Selector("locateAction:"), forControlEvents: UIControlEvents.TouchUpInside)
            
            // Enable/Disable textfields
            self.infoLabel.text = "Add Location"
            self.infoTextField.text = nil
            self.infoTextField.enabled = true
            self.infoTextField.hidden = false
            self.mediaURLTextField.text = nil
            self.mediaURLTextField.enabled = false
            self.mediaURLTextField.hidden = true
            
            self.view.layoutIfNeeded()
            self.dismissKeyboard()
        }
    }
    
    func annotionViewTapped(recognizer: UITapGestureRecognizer)
    {
        // Can't get this to work!
        
        /*
        if let view = recognizer.view as? MKAnnotationView {
            var mediaURL = NSURL(string: view.annotation.subtitle!)
            UIApplication.sharedApplication().openURL(mediaURL!)

        }
        */
    }
    
    func screenTapped(recognizer: UITapGestureRecognizer)
    {
        dismissKeyboard()
    }
    
    func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    func retryAlert(error:String?, completionHandler:(Bool) -> ())
    {
        let alertController = UIAlertController(title: "Connection Error" , message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        let retryAction = UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default) { (action) in
            completionHandler(true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(retryAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func overwriteAlert(error:String?, completionHandler:(Bool) -> ())
    {
        let alertController = UIAlertController(title: "Existing Pin" , message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        let overwriteAlert = UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.Default) { (action) in
            UIView.animateWithDuration(self.animationDuration, delay: 0, options: .CurveEaseOut, animations: {
                self.userInfoViewConstraint.constant += -212.0
                self.view.layoutIfNeeded()
                }, completion: nil)
            
            self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: Selector("cancelAction:"))
            completionHandler(true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(overwriteAlert)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func errorAlert(error:String?)
    {
        let alertController = UIAlertController(title: "Connection Error" , message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: MapView
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var view: MKPinAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(annotationIdentifier) as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        }
        else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            view.canShowCallout = true
            view.pinColor = MKPinAnnotationColor.Purple
            view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView

        }

        return view
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        var studentLink = view.annotation.subtitle!
        
        // Simple check if media link is a valid url.
        let subString = (studentLink as NSString).containsString("://")
        
        if subString {
            var mediaURL = NSURL(string: studentLink)
            
            if let url = mediaURL {
                UIApplication.sharedApplication().openURL(url)
            }
            else {
                errorAlert("Sorry, could not load the specified link.")
            }
        }
        else {
            errorAlert("Please enter a valid URL link. ( e.g. http://udacity.com )")
        }
    }
    
    func mapViewDidFailLoadingMap(mapView: MKMapView!, withError error: NSError!) {
        var errorString = "Maps failed to load. \(error.localizedDescription)"
        retryAlert(errorString, completionHandler: { (bool) -> () in
            if bool {
                self.mapsRequest()
            }
        })
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        // Add gesture to allow tap on callout view
        //annotationTapGesture = UITapGestureRecognizer(target: self, action: Selector("annotionViewTapped:"))
        //view.addGestureRecognizer(annotationTapGesture)
    }
    
}