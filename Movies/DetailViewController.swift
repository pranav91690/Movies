//
//  DetailViewController.swift
//  Movies
//
//  Created by Pranav Achanta on 1/18/16.
//  Copyright © 2016 pranav. All rights reserved.
//

import UIKit
import SwiftyJSON

class DetailViewController: UIViewController{

    @IBOutlet weak var posterView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var overviewLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var infoView: UIView!
    
    
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var genres: UILabel!
    
    @IBOutlet weak var RevenueLabel: UILabel!
    @IBOutlet weak var revenue: UILabel!
    
    @IBOutlet weak var runTimeLabel: UILabel!
    @IBOutlet weak var runTime: UILabel!
    
    var movie : Movie!
    
    var summaryInFocus = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the additional Movie Details here
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(movie.id)?api_key=\(apiKey)")
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
                    let movie = JSON(data : data)
                    let revenue = movie["revenue"].int32Value
                    let numberFormatter = NSNumberFormatter()
                    numberFormatter.numberStyle = .DecimalStyle
                    let millions = numberFormatter.stringFromNumber(NSNumber(int: revenue))
                    self.revenue.text = "$" + millions!
                    let runtime = String(movie["runtime"].int16Value)
                    self.runTime.text = runtime + " mins"
                    var genres = [String]()
                    
                    for(_,genre) : (String, JSON) in movie["genres"] {
                       genres.append(genre["name"].stringValue)
                    }
                    
                    self.genres.text = genres.joinWithSeparator(" , ")
                }
        });
        task.resume()

        titleLabel.text = movie.movieTitle
        self.navigationItem.title = movie.movieTitle
        overviewLabel.text = movie.movieOverview
        overviewLabel.sizeToFit()
        
        let base_url = "https://image.tmdb.org/t/p/original"
        posterView.setImageWithURL(NSURL(string: base_url + movie.posterpath)!)
        
        
        // Set the Info view sizes programitically
        genres.frame.origin.y = overviewLabel.frame.origin.y + overviewLabel.frame.size.height
        genreLabel.frame.origin.y = overviewLabel.frame.origin.y + overviewLabel.frame.size.height
        
        revenue.frame.origin.y = genres.frame.origin.y + genres.frame.size.height
        RevenueLabel.frame.origin.y = genres.frame.origin.y + genres.frame.size.height
        
        runTime.frame.origin.y = revenue.frame.origin.y + revenue.frame.size.height
        runTimeLabel.frame.origin.y = revenue.frame.origin.y + revenue.frame.size.height
        
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height )
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTapSummary(sender: AnyObject) {
        summaryInFocus = !summaryInFocus

        // Animate the Scroll view to the Top
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            if(!self.summaryInFocus){
                self.scrollView.frame.origin.y = self.scrollView.frame.origin.y - 250
            }else{
                self.scrollView.frame.origin.y = self.scrollView.frame.origin.y + 250
            }
        })
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
