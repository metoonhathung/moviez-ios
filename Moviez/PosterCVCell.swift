//
//  PosterCVCell.swift
//  Moviez
//
//  Created by Trần Ngô Nhật Hưng on 12/4/21.
//

import UIKit

class PosterCVCell: UICollectionViewCell {
    
    @IBOutlet weak var posterImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        update(image: nil, title: "")
    }
    
    func update(image: UIImage?, title: String) {
        activityIndicator?.stopAnimating()
        posterImg?.image = image
        titleLabel?.text = title
        
        if let displayImage = image {
            activityIndicator?.stopAnimating()
            posterImg?.image = displayImage
            titleLabel?.text = title
        } else {
            activityIndicator?.startAnimating()
            posterImg?.image = nil
            titleLabel?.text = ""
        }
    }
}
