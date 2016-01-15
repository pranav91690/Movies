//
//  MoviesViewController.swift
//  Movies
//
//  Created by Pranav Achanta on 1/15/16.
//  Copyright © 2016 pranav. All rights reserved.
//

import UIKit
import AFNetworking
import EZLoadingActivity

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    
    // Declare an instance of the UI Refesh Controller
    var refreshController : UIRefreshControl!
    
    // Declare a array of dictionaries to store the movies
    var movies : [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self

        // Do any additional setup after loading the view.
        

        // Creat an instance of the refresh control and add it at the lowest index 
        // to the table view
        refreshController = UIRefreshControl()
        refreshController.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshController, atIndex: 0)
        
        // Setup the initial "loading" pop-up
        //        EZLoadingActivity.show("Loading...", disableUI: false)
        EZLoadingActivity.show("Loading", disableUI: true)
        
        // Network Connection
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
//                    EZLoadingActivity.hide()
                    print("Upload Complete")
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
//                            NSLog("response: \(responseDictionary)")
                            
                            // Put the Data into the Movies array
                            self.movies = responseDictionary["results"] as! [NSDictionary]
                            self.tableView.reloadData()
                            
                    }
                }
        });
        task.resume()
    }
    
    // Refresh Control Methods
    
    // Test Funtion for ProtopType
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        delay(2, closure: {
            self.refreshController.endRefreshing()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let movies = movies{
            return movies.count
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath:indexPath) as! MovieCell
        
        let base_url = "https://image.tmdb.org/t/p/w342"
        
        if let movie = movies?[indexPath.row]{
            if let title = movie["title"] as? String{
                if let overview = movie["overview"] as? String{
                    if let poster_path = movie["poster_path"] as? String{
                        let imageUrl = NSURL(string: base_url + poster_path)
                        cell.titleLabel.text = title
                        cell.overviewLabel.text = overview
                        cell.posterView.setImageWithURL(imageUrl!)
                    }
                }
            }

        }
        
//        cell.textLabel!.text = title
        
        return cell
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
