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
import SystemConfiguration

class MoviesViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchResultsUpdating{
    
//    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    @IBOutlet weak var searchBarLabel: UIView!
    

    @IBAction func onTap2(sender: AnyObject) {
        self.viewDidLoad()
    }
    
    
    // Declare an instance of the UI Refesh Controller
    var refreshController : UIRefreshControl!
    
    // Declare a Search Controller
    var searchController  : UISearchController!
    
    // Declare a array of dictionaries to store the movies
    var movies : [NSDictionary]?
    var filteredData : [NSDictionary]!
    
    func checkForConnection() -> Bool{
        // Check for the Internet Connection
        let status = Reachability.isConnectedToNetwork()
        if(status){
            errorMessageLabel.hidden = true
        }else{
            errorMessageLabel.hidden = false
        }
        
        return status
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add the Error Image and TextLabel to the error View
        let errorMessage = UILabel(frame: CGRectMake(130, 5, 100, 20))
        errorMessage.font = UIFont.systemFontOfSize(15)
        errorMessage.text  = "Network Error"
        errorMessageLabel.addSubview(errorMessage)
        
        let imageName = "error.png"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: 105, y: 5, width: 20, height: 20)
        errorMessageLabel.addSubview(imageView)
        
        // Set the data source of the collection view
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        // Setup the Flow control of the Collection View
        flowLayout.scrollDirection = .Vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 0)
        
        // Create a gesture recognizer to be added to the collection view
        let tapGesture : UITapGestureRecognizer!
        tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        collectionView.userInteractionEnabled = true
        collectionView.addGestureRecognizer(tapGesture)
        
        
        //Setup the Search Controller
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.translucent = true
        searchController.searchBar.barTintColor = UIColor.darkGrayColor()
        
        searchBarLabel.addSubview(searchController.searchBar)
        automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true
        
        
        // Setup the Flow Controller
        refreshController = UIRefreshControl()
        refreshController.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        refreshController.backgroundColor = UIColor.darkGrayColor()
        refreshController.tintColor = UIColor.whiteColor()
        //        tableView.insertSubview(refreshController, atIndex: 0)
        collectionView.insertSubview(refreshController, atIndex: 0)
        
        
        // Setup the initial "loading" pop-up
        activityIndicator.startAnimating()
//        tableView.hidden = true
        collectionView.hidden = true
        
        // Network Connection
        networkCall()
    }
    
    func networkCall(){
        if(checkForConnection()){
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
                        if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                            data, options:[]) as? NSDictionary {
                                //                            NSLog("response: \(responseDictionary)")
                                // Bring the Table view back
                                self.activityIndicator.stopAnimating()
                                //                            self.tableView.hidden = false
                                self.collectionView.hidden = false
                                // Put the Data into the Movies array
                                self.movies = responseDictionary["results"] as! [NSDictionary]
                                //                            self.tableView.reloadData()
                                
                                // Store the Original Data into the filtered data
                                self.filteredData = self.movies
                                
                                self.collectionView.reloadData()
                                
                        }
                    }
            });
            task.resume()
        }
    }
    
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
            self.networkCall()
            self.refreshController.endRefreshing()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Implementation of the CollectionView Data Source Protocol Methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies = filteredData{
            return movies.count
        }else{
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("movieCell", forIndexPath: indexPath) as! MovieCellCView
        
        return setMovieCell(cell, row: indexPath.row)

    }
    
    func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath){
            print("Selected")
    }
    
    func setMovieCell(cell : MovieCellCView, row : Int) -> MovieCellCView{
        let base_url = "https://image.tmdb.org/t/p/w342"
        
        if let movie = filteredData?[row]{
            if let _ = movie["title"] as? String{
                if let overview = movie["overview"] as? String{
                    if let poster_path = movie["poster_path"] as? String{
                        let imageRequest = NSURLRequest(URL: NSURL(string: base_url + poster_path)!)
                        cell.posterView.setImageWithURLRequest(
                            imageRequest,
                            placeholderImage: nil,
                            success: { (imageRequest, imageResponse, image) -> Void in
                                // Code to handle success goes here
                                
                                if (imageResponse != nil){
                                    cell.posterView.alpha = 0.0
                                    cell.posterView.image = image
                                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                                        cell.posterView.alpha = 1.0
                                    })
                                }else{
                                    cell.posterView.image = image
                                }
                                
//                                cell.overviewLabel.text = overview
                            },
                            failure: { (imageRequest, imageResponse, image) -> Void in
                                // Code to handle failure goes here --> We can say something like
                                // poster not available
                        })
                        cell.overviewLabel.hidden = true
                    }
                    
                    // Use the Desciption and animate the picture out of focus and show the description
                }
            }
            
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let totalwidth = collectionView.bounds.size.width;
        let numberOfCellsPerRow = 2
        let dimensions = CGFloat(Int(totalwidth) / numberOfCellsPerRow)

        return CGSizeMake(dimensions, 240)
    }
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        
        if(searchText?.isEmpty == false){
            // Update the filtered data using the seachText
            if let movies = movies {
                filteredData = movies.filter({(movie : NSDictionary) -> Bool in
                    let title = movie["title"] as! String
                    return title.rangeOfString(searchText!, options: .CaseInsensitiveSearch) != nil
                })
            }
        }
        
        collectionView.reloadData()
    }
    
    func handleTap(sender : UITapGestureRecognizer){
        let tapLocation = sender.locationInView(view)
        let indexPath:NSIndexPath = self.collectionView.indexPathForItemAtPoint(tapLocation)!
        let rowNumber = indexPath.row
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        print(indexPath.item)
    }
//
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
//        if let movies = movies{
//            return movies.count
//        }else{
//            return 0
//        }
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
//        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath:indexPath) as! MovieCell
//        
//        let base_url = "https://image.tmdb.org/t/p/w342"
//        
//        if let movie = movies?[indexPath.row]{
//            if let title = movie["title"] as? String{
//                if let overview = movie["overview"] as? String{
//                    if let poster_path = movie["poster_path"] as? String{
//                        let imageUrl = NSURL(string: base_url + poster_path)
//                        cell.titleLabel.text = title
//                        cell.overviewLabel.text = overview
//                        cell.posterView.setImageWithURL(imageUrl!)
//                    }
//                }
//            }
//
//        }
//        
////        cell.textLabel!.text = title
//        
//        return cell
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


public class Reachability {
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}
