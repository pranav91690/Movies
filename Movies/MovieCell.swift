//
//  MovieCell.swift
//  Movies
//
//  Created by Pranav Achanta on 1/15/16.
//  Copyright © 2016 pranav. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var overviewLabel: UILabel!

    @IBOutlet weak var posterView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
