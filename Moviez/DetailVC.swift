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
    
    var detail: DetailModel? {
        willSet {
            OperationQueue.main.addOperation {
                self.title = newValue?.Title ?? ""
                self.descriptionLabel?.text = """
                Title: \(newValue?.Title ?? "")
                Year: \(newValue?.Year ?? "")
                Rated: \(newValue?.Rated ?? "")
                Released: \(newValue?.Released ?? "")
                Runtime: \(newValue?.Runtime ?? "")
                Genre: \(newValue?.Genre ?? "")
                Director: \(newValue?.Director ?? "")
                Writer: \(newValue?.Writer ?? "")
                Actors: \(newValue?.Actors ?? "")
                Plot: \(newValue?.Plot ?? "")
                Language: \(newValue?.Language ?? "")
                Country: \(newValue?.Country ?? "")
                Awards: \(newValue?.Awards ?? "")
                Rating: \(newValue?.imdbRating ?? "")
                Votes: \(newValue?.imdbVotes ?? "")
                Type: \(newValue?.Type ?? "")
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

        // Do any additional setup after loading the view.
    }
    
    func addActionSheet(title: String, completion: @escaping (UIAlertAction) -> Void) {
        let alertMsg = "\(NSLocalizedString("str_add_msg", comment: "")) \(title)?"
        let alert = UIAlertController(title: NSLocalizedString("str_warning", comment: ""), message: alertMsg, preferredStyle: .actionSheet)
        
        let addAction = UIAlertAction(title: NSLocalizedString("str_add", comment: ""), style: .default, handler: completion)
        let cancelAction = UIAlertAction(title: NSLocalizedString("str_cancel", comment: ""), style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        alert.popoverPresentationController?.permittedArrowDirections = []
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.frame.midX, y: self.view.frame.midY, width: 0, height: 0)
        
        present(alert, animated: true, completion: nil)
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
