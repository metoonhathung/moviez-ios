//
//  DetailVC.swift
//  Moviez
//
//  Created by Trần Ngô Nhật Hưng on 12/3/21.
//

import UIKit
import CoreData

class DetailVC: UIViewController {

    @IBOutlet weak var posterImg: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var posterCenter = CGPoint()
    
    var detail: DetailModel? {
        willSet {
            OperationQueue.main.addOperation {
                self.navigationItem.title = newValue?.Title ?? ""
                self.descriptionLabel?.text = """
                \("str_title".localized()): \(newValue?.Title ?? "")
                \("str_year".localized()): \(newValue?.Year ?? "")
                \("str_rated".localized()): \(newValue?.Rated ?? "")
                \("str_released".localized()): \(newValue?.Released ?? "")
                \("str_runtime".localized()): \(newValue?.Runtime ?? "")
                \("str_genre".localized()): \(newValue?.Genre ?? "")
                \("str_director".localized()): \(newValue?.Director ?? "")
                \("str_writer".localized()): \(newValue?.Writer ?? "")
                \("str_actors".localized()): \(newValue?.Actors ?? "")
                \("str_plot".localized()): \(newValue?.Plot ?? "")
                \("str_language".localized()): \(newValue?.Language ?? "")
                \("str_country".localized()): \(newValue?.Country ?? "")
                \("str_awards".localized()): \(newValue?.Awards ?? "")
                \("str_rating".localized()): \(newValue?.imdbRating ?? "")
                \("str_votes".localized()): \(newValue?.imdbVotes ?? "")
                \("str_type".localized()): \(newValue?.Type ?? "")
                """
            }
        }
    }
    
    var image: UIImage? {
        willSet {
            OperationQueue.main.addOperation {
                self.activityIndicator?.stopAnimating()
                self.posterImg?.image = newValue
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        posterCenter = posterImg.center
        
        let downSwipeGR = UISwipeGestureRecognizer(target: self, action: #selector(handleDownSwipe(_:)))
        downSwipeGR.direction = .down
        view.addGestureRecognizer(downSwipeGR)
        
        let upSwipeGR = UISwipeGestureRecognizer(target: self, action: #selector(handleUpSwipe(_:)))
        upSwipeGR.direction = .up
        view.addGestureRecognizer(upSwipeGR)
        // Do any additional setup after loading the view.
    }
    
    func addActionSheet(title: String, completion: @escaping (UIAlertAction) -> Void) {
        let alertMsg = "\("str_add_msg".localized()) \(title)?"
        let alert = UIAlertController(title: "str_warning".localized(), message: alertMsg, preferredStyle: .actionSheet)
        
        let addAction = UIAlertAction(title: "str_add".localized(), style: .default, handler: completion)
        let cancelAction = UIAlertAction(title: "str_cancel".localized(), style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        alert.popoverPresentationController?.permittedArrowDirections = []
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.frame.midX, y: self.view.frame.midY, width: 0, height: 0)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func handleDownSwipe(_ gesture: UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 1.0, animations: {
            self.posterImg?.center = self.view.center
            self.posterImg?.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
        })
    }
    
    @objc func handleUpSwipe(_ gesture: UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 1.0, animations: {
            self.posterImg?.center = self.posterCenter
            self.posterImg?.transform = CGAffineTransform.identity
        })
    }
    
    @IBAction func onActionBtn(_ sender: Any) {
        addActionSheet(title: detail?.Title ?? "", completion: { _ in
            let dict: [String: Any] = ["movie": self.detail as Any]
            NotificationCenter.default.post(name: Notifications.movieAdded, object: nil, userInfo: dict)
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
