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
    
    func update(image: UIImage, title: String) {
        activityIndicator?.stopAnimating()
        posterImg?.image = image
        titleLabel?.text = title
    }
}
