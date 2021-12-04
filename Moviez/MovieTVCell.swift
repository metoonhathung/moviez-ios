//
//  MovieTVCell.swift
//  Moviez
//
//  Created by Trần Ngô Nhật Hưng on 12/3/21.
//

import UIKit

class MovieTVCell: UITableViewCell {

    @IBOutlet weak var posterImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet var starsArray: [UIImageView]!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let imageHelper = ImageHelper()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update(with movie: Movie) {
         
        if let _ = movie.value(forKey: "id") as? String,
            let title = movie.value(forKey: "title") as? String,
            let year = movie.value(forKey: "year") as? String,
            let _ = movie.value(forKey: "type") as? String,
            let poster = movie.value(forKey: "poster") as? String,
            let rating = movie.value(forKey: "rating") as? String {
            
            titleLabel?.text = title
            yearLabel?.text = year
            let imdbRating = Double(rating)
            for (i, starImg) in starsArray.enumerated() {
                starImg.isHidden = i >= Int(imdbRating?.rounded() ?? 10)
                
            }
            
            imageHelper.fetchImage(urlString: poster, completion: { result in
                
                guard case let .Success(imgData) = result else { return }
                
                OperationQueue.main.addOperation {
                    if let image = UIImage(data: imgData) {
                        self.activityIndicator?.stopAnimating()
                        self.posterImg.image = image
                    }
                }
            })
        }
    }

}
