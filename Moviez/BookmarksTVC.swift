//
//  BookmarksTVC.swift
//  Moviez
//
//  Created by Trần Ngô Nhật Hưng on 12/3/21.
//

import UIKit
import CoreData

class BookmarksTVC: UITableViewController, SearchDelegate, DetailDelegate {

    var movies: [NSManagedObject] = []
    let imageHelper = ImageHelper()
    let detailHelper = DetailHelper()
    var editedIndexPath: IndexPath?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor(named: "primary")
        
        localized()
        NotificationCenter.default.addObserver(forName: Notifications.languageChanged, object: nil, queue: nil) { _ in
            self.localized()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(saveItem), name: Notifications.movieAdded, object: nil)
        readData()
    }
    
    func localized() {
        navigationItem.title = "str_bookmarks".localized()
        tableView.reloadData()
    }
    
    func moviesByType(type: TypeEnum) -> [NSManagedObject] {
        return movies.filter {($0 as? Movie)?.value(forKey: "type") as? String == type.title()}
    }
    
    func deletionAlert(title: String, completion: @escaping (UIAlertAction) -> Void) {
        let alertMsg = "\("str_delete_msg".localized()) \(title)?"
        let alert = UIAlertController(title: "str_warning".localized(), message: alertMsg, preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "str_delete".localized(), style: .destructive, handler: completion)
        let cancelAction = UIAlertAction(title: "str_cancel".localized(), style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        alert.popoverPresentationController?.permittedArrowDirections = []
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.frame.midX, y: self.view.frame.midY, width: 0, height: 0)
        
        present(alert, animated: true, completion: nil)
    }
    
    func updateSearch(title: String, type: String, year: String, isSearching: Bool) {
        if isSearching == true {
            var predicates = [NSPredicate]()
            predicates.append(NSPredicate(format: "type = %@", type))
            if !title.isEmpty {
                predicates.append(NSPredicate(format: "title CONTAINS[cd] %@", title))
            }
            if !year.isEmpty {
                predicates.append(NSPredicate(format: "year CONTAINS[cd] %@", year))
            }
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            readData(predicate: predicate)
        } else {
            let context = AppDelegate.cdContext
            if let oldType = TypeEnum(rawValue: editedIndexPath!.section) {
                let moviesFiltered = moviesByType(type: oldType)
                if let movie = moviesFiltered[editedIndexPath!.row] as? Movie {
                    movie.setValue(title, forKey: "title")
                    movie.setValue(type, forKey: "type")
                    movie.setValue(year, forKey: "year")
                    do {
                        try context.save()
                    } catch let error as NSError {
                        print("Could not update the item. \(error), \(error.userInfo)")
                    }
                }
            }
            readData()
        }
    }
    
    func updateDetail() {
        tableView.reloadData()
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
        return TypeEnum(rawValue: section)?.title().localized()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTVCell") as? MovieTVCell else {
            fatalError("Expected MovieTVCell")
        }
        cell.backgroundColor = UIColor(named: "secondary")
        
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

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            (action, sourceView, completionHandler) in
            if let type = TypeEnum(rawValue: indexPath.section) {
                let moviesFiltered = self.moviesByType(type: type)
                if let item = moviesFiltered[indexPath.row] as? Movie, let title = item.title {
                    self.deletionAlert(title: title, completion: { _ in
                        self.deleteItem(item: item)
                    })
                }
            }
            completionHandler(true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") {
            (action, sourceView, completionHandler) in
            self.editedIndexPath = indexPath
            self.performSegue(withIdentifier: "EditSegue", sender: indexPath)
            completionHandler(true)
        }
        editAction.backgroundColor = .green
        
        // SWIPE TO LEFT CONFIGURATION
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        // Delete should not delete automatically
         swipeConfiguration.performsFirstActionWithFullSwipe = false
        
        return swipeConfiguration
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
    
    func readData(predicate: NSPredicate? = nil) {
        let context = AppDelegate.cdContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Movie")
        if let _predicate = predicate {
            fetchRequest.predicate = _predicate
        }
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
                    detailVC.delegate = self
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
            case "PredicateSegue":
                if let searchVC = segue.destination as? SearchVC {
                    searchVC.delegate = self
                }
            case "EditSegue":
                if let searchVC = segue.destination as? SearchVC,
                   let type = TypeEnum(rawValue: editedIndexPath!.section) {
                    searchVC.delegate = self
                    let moviesFiltered = moviesByType(type: type)
                    if let movie = moviesFiltered[editedIndexPath!.row] as? Movie {
                        searchVC.movie = movie
                    }
                }
            default: break
        }
    }
    
}
