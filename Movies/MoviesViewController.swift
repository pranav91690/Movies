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
import SwiftyJSON

class MoviesViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchResultsUpdating, UISearchBarDelegate{
    
//    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    @IBOutlet weak var searchBarLabel: UIView!
    
    // End Point to get either the NowPlaying Movies/Top Rated Movies
    var endPoint : String!

    @IBAction func onTap2(sender: AnyObject) {
        self.viewDidLoad()
    }
    
    
    // Declare an instance of the UI Refesh Controller
    var refreshController : UIRefreshControl!
    
    // Declare a Search Controller
    var searchController  : UISearchController!
    
    // Declare a array of Movie Objects to store the movie Details
    var movies : [Movie]?
    var filteredData : [Movie]?

    
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
        
        // Customize the Navigation Bar Controller
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.setBackgroundImage(UIImage(named: "movies_cover"), forBarMetrics: .Default)
            navigationBar.tintColor = UIColor(red: 1.0, green: 0.25, blue: 0.25, alpha: 0.8)

            let shadow = NSShadow()
            shadow.shadowColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
            shadow.shadowOffset = CGSizeMake(2, 2);
            shadow.shadowBlurRadius = 4;
            navigationBar.titleTextAttributes = [
                NSFontAttributeName : UIFont.boldSystemFontOfSize(18),
                NSForegroundColorAttributeName : UIColor.blackColor(),// UIColor(red: 0.5, green: 0.15, blue: 0.15, alpha: 0.8),
                NSShadowAttributeName : shadow
            ]
        }
        
        
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
        
        // Setup the Flow control of the Collection View --> Check out more on this!!
        flowLayout.scrollDirection = .Vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 0)
        
        
        //Setup the Search Controller
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.translucent = true
        searchController.searchBar.barTintColor = UIColor.darkGrayColor()
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        navigationItem.titleView = searchController.searchBar
        automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true
        
        
        // Setup the Refresh Controller --> May be you can this to implement that search functionality
        refreshController = UIRefreshControl()
        refreshController.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        refreshController.backgroundColor = UIColor.darkGrayColor()
        refreshController.tintColor = UIColor.whiteColor()
        collectionView.insertSubview(refreshController, atIndex: 0)
        
        
        // Setup the initial "loading" pop-up
        activityIndicator.startAnimating()
        collectionView.hidden = true
        
        // Network Connection
        networkCall()
    }
    
    func networkCall(){
        if(checkForConnection()){
            let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
            let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endPoint)?api_key=\(apiKey)")
            let request = NSURLRequest(URL: url!)
            let session = NSURLSession(
                configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
                delegate:nil,
                delegateQueue:NSOperationQueue.mainQueue()
            )
            
            let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
                completionHandler: { (dataOrNil, response, error) in
                    if let data = dataOrNil {
                        
                        // Using the JSON Library
                        let responseDictionary = JSON(data : data)
                        self.activityIndicator.stopAnimating()
                        self.collectionView.hidden = false
                        
                        var movies = [Movie]()
                        // Create the Movie Objects and add them to the movie array
                        for(_,movie) : (String, JSON) in responseDictionary["results"]{
                            // Create an movie object for each json
                            if let _ = movie["title"].string{
                                let movie = Movie(movie: movie)
                                movies.append(movie)
                            }else{
                                print(movie["titile"].error)
                            }
                        }
                        
                        self.movies = movies
                        self.filteredData = self.movies
                        self.collectionView.reloadData()
                    }
            });
            task.resume()
        }
    }
    
    // Add a programmatic delay to simualate the reload functionality
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
    

    
    func setMovieCell(cell : MovieCellCView, row : Int) -> MovieCellCView{
        let base_url_small = "https://image.tmdb.org/t/p/w45"
        if let movie = filteredData?[row]{
            let imageRequest = NSURLRequest(URL: NSURL(string: base_url_small + movie.posterpath)!)
            cell.posterView.setImageWithURLRequest(imageRequest,placeholderImage: nil,
                success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                    if (smallImageResponse != nil){
                        cell.posterView.alpha = 0.0
                        cell.posterView.image = smallImage
                        UIView.animateWithDuration(0.5, animations: { () -> Void in
                            cell.posterView.alpha = 1.0
                        
                            // Set the Large image only after the small image is loaded
                        },completion : { (success) ->  Void in
                            // Image large image fails to set, set the small image as the image
                            if(!self.setLargeImage(cell, movie: movie)){
                                cell.posterView.image = smallImage
                            }
                        })
                    }else{
                        // Set the Image to Small Image only if getting large image fails
                        if(!self.setLargeImage(cell, movie: movie)){
                            cell.posterView.image = smallImage
                        }
                    }
                },
                failure: { (imageRequest, imageResponse, image) -> Void in
                    // Code to handle failure goes here --> We can say something like
                    // poster not available
            })
            cell.overviewLabel.text = movie.movieTitle
            cell.adult.hidden = !movie.isAdult
            cell.movieRating.text = String(movie.rating)
        }
    
        return cell
    }
        
    
        
    func setLargeImage(cell : MovieCellCView, movie : Movie) -> Bool{
        let base_url_large = "https://image.tmdb.org/t/p/original"
        let imageRequestLarge = NSURLRequest(URL: NSURL(string: base_url_large + movie.posterpath)!)
        var status = false
        cell.posterView.setImageWithURLRequest(imageRequestLarge,placeholderImage: nil,
            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                if largeImageResponse != nil {
                    cell.posterView.alpha = 0.0
                    cell.posterView.image = largeImage
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        cell.posterView.alpha = 1.0
                    })
                } else {
                    cell.posterView.image = largeImage
                }
                status = true
            }, failure: {(largeImageRequest, largeImageResponse, largeImage) -> Void in
                status = false
        })
        
        return status
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
                filteredData = movies.filter({(movie : Movie) -> Bool in
                    return movie.movieTitle.rangeOfString(searchText!, options: .CaseInsensitiveSearch) != nil
                })
            }
        }
        
        collectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar){
        filteredData = movies
        collectionView.reloadData()
    }
    
    
    // Method to hande highlight functionality
    func collectionView(collectionView: UICollectionView,
        didHighlightItemAtIndexPath indexPath: NSIndexPath){
    }
    
    
    // Method to handle selected functionality
    func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath){
            // DeSelect the the itw of the index view
            collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Basic Way of Moving data from one screen to another
        
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
    }
    

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
