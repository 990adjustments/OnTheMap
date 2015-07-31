//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Erwin Santacruz on 7/25/15.
//  Copyright (c) 2015 Erwin Santacruz. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let cellIdentifier = "ListViewTableCell"
    
    var students: Students!
    var client: OTMClient!
    
    @IBOutlet weak var studentListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        client = OTMClient.sharedInstance()
        getParseData()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        getParseData()
    }
    
    func getParseData()
    {
        client.GetParse(OTMClient.Methods.Student_Location, extra: nil, stripCharacters: false, completionHandler: { (json, error) -> () in
            if let err = error {
                self.errorAlert(err.localizedDescription)

                return
            }
            else {
                if let jsonData = json {
                    self.students = Students(students: OTMClient.MapJSONKeys(jsonData)!)
                    self.loadData()
                }
            }
        })
    }
    
    func loadData()
    {
        dispatch_async(dispatch_get_main_queue()) {
            self.studentListTableView.reloadData()
        }
    }
    
    func errorAlert(error:String?)
    {
        let alertController = UIAlertController(title: "Connection Error" , message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if students == nil {
            return 0
        }
        else {
            return students.students!.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ListViewTableCell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! UITableViewCell
        var student = students.students![indexPath.row]
        
        if cell.textLabel!.text != nil {
            cell.textLabel!.text = "\(student.firstName) \(student.lastName)"
            cell.detailTextLabel?.text = "\(student.mediaURL)"
        }

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student = students.students![indexPath.row]
        println(student.mediaURL)
        
        // Check to see if media URL is in a valid format
        let subString = (student.mediaURL as NSString).containsString("://")
        
        if subString {
            var mediaURL = NSURL(string: student.mediaURL)
            
            if let url = mediaURL {
                UIApplication.sharedApplication().openURL(url)
            }
            else {
                errorAlert("Sorry, could not load the specified link.")
                //tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
        else {
            errorAlert("Please enter a valid URL link. ( e.g. http://udacity.com )")
            
            
            // Trying to see if I could create a valid url by adding http://
            /*
            var s = "http://\(student.mediaURL)"
            var u = NSURL(string: s)
            
            if let mu = u {
                UIApplication.sharedApplication().openURL(mu)
            }
            else {
                errorAlert("Please enter a valid URL link. ( e.g. http://udacity.com )")
            }
            */
            
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}
