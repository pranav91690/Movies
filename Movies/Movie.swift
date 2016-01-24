//
//  Movie.swift
//  Movies
//
//  Created by Pranav Achanta on 1/22/16.
//  Copyright © 2016 pranav. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class Movie {
    //Properties
    var id : Int16
    var movieTitle : String
    var movieOverview : String
    var posterpath : String
    var rating : Float
    var isAdult : Bool
    
    // How Do we check if the creation of the movie object fails
    init(movie : JSON){
        self.id = movie["id"].int16Value
        self.movieTitle = movie["title"].stringValue
        self.movieOverview = movie["overview"].stringValue
        self.posterpath = movie["poster_path"].stringValue
        self.rating = movie["vote_average"].floatValue
        self.isAdult = movie["adult"].boolValue
    }
}