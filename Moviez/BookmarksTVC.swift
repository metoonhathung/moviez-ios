//
//  BookmarksTVC.swift
//  Moviez
//
//  Created by Trần Ngô Nhật Hưng on 12/3/21.
//

import UIKit
import CoreData

class BookmarksTVC: UITableViewController {

    var movies: [NSManagedObject] = []
    let imageHelper = ImageHelper()
    let detailHelper = DetailHelper()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "str_bookmarks"
        NotificationCenter.default.addObserver(self, selector: #selector(saveItem), name: Notifications.movieAdded, object: nil)
        readData()
    }
    
    func moviesByType(type: TypeEnum) -> [NSManagedObject] {
        return movies.filter {($0 as? Movie)?.value(forKey: "type") as? String == type.title()}
    }
    
    func deletionAlert(title: String, completion: @escaping (UIAlertAction) -> Void) {
        let alertMsg = "\(NSLocalizedString("str_delete_msg", comment: "")) \(title)?"
        let alert = UIAlertController(title: NSLocalizedString("str_warning", comment: ""), message: alertMsg, preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: NSLocalizedString("str_delete", comment: ""), style: .destructive, handler: completion)
        let cancelAction = UIAlertAction(title: NSLocalizedString("str_cancel", comment: ""), style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        alert.popoverPresentationController?.permittedArrowDirections = []
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.frame.midX, y: self.view.frame.midY, width: 0, height: 0)
        
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return TypeEnum.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let type = TypeEnum(rawValue: section) {
            return moviesByType(type: type).count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return TypeEnum(rawValue: section)?.title()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTVCell") as? MovieTVCell else {
            fatalError("Expected MovieTVCell")
        }
        
        if let type = TypeEnum(rawValue: indexPath.section) {
            let moviesFiltered = moviesByType(type: type)
            if let item = moviesFiltered[indexPath.row] as? Movie {
                cell.update(with: item)
            }
        }
        return cell
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let type = TypeEnum(rawValue: indexPath.section) {
                let moviesFiltered = moviesByType(type: type)
                if let item = moviesFiltered[indexPath.row] as? Movie, let title = item.title {
                    deletionAlert(title: title, completion: { _ in
                        self.deleteItem(item: item)
                    })
                }
            }
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    // MARK: - CoreData
    
    func readData() {
        let context = AppDelegate.cdContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Movie")
        do {
            movies = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch requested item. \(error), \(error.userInfo)")
        }
        tableView.reloadData()
    }
    
    func deleteItem(item: Movie) {
        let context = AppDelegate.cdContext
        if let _ = movies.firstIndex(of: item)  {
            context.delete(item)
            do {
                try context.save()
            } catch let error as NSError {
                print("Could not delete the item. \(error), \(error.userInfo)")
            }
        }
        readData()
    }
    
    @objc func saveItem(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary?, let detail = dict["movie"] as? DetailModel {
            if movies.filter({($0 as? Movie)?.value(forKey: "id") as? String == detail.imdbID}).count == 0 {
                let context = AppDelegate.cdContext
                if let entity = NSEntityDescription.entity(forEntityName: "Movie", in: context) {
                    let item = NSManagedObject(entity: entity, insertInto: context)
                    item.setValue(detail.imdbID ?? "", forKeyPath: "id")
                    item.setValue(detail.Title ?? "", forKeyPath: "title")
                    item.setValue(detail.Type ?? "", forKeyPath: "type")
                    item.setValue(detail.Year ?? "", forKeyPath: "year")
                    item.setValue(detail.Poster ?? "", forKeyPath: "poster")
                    item.setValue(detail.imdbRating ?? "", forKeyPath: "rating")
                    do {
                        try context.save()
                    } catch let error as NSError {
                        print("Could not save the item. \(error), \(error.userInfo)")
                    }
                }
                readData()
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onEditBtn(_ sender: Any) {
        setEditing(!isEditing, animated: true)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "TableDetailSegue":
                if let selectedIndexPath = tableView.indexPathForSelectedRow,
                   let detailVC = segue.destination as? DetailVC,
                   let type = TypeEnum(rawValue: selectedIndexPath.section) {
                    let moviesFiltered = moviesByType(type: type)
                    if let movie = moviesFiltered[selectedIndexPath.row] as? Movie {
                        imageHelper.fetchImage(urlString: movie.value(forKey: "poster") as! String) { result in
                            switch result {
                            case let .Success(imgData):
                                if let image = UIImage(data: imgData) {
                                    detailVC.image = image
                                }
                            case let .Failure(error):
                                print("Error fetching image: \(error)")
                            }
                        }
                        detailHelper.fetchDetail(for: movie.value(forKey: "id") as! String) { result in
                            switch result {
                                case let .Success(detail):
                                    detailVC.detail = detail
                                case let .Failure(error):
                                    print("fetch error; \(error)")
                            }
                        }
                    }
                }
            default: break
        }
    }
    
}
