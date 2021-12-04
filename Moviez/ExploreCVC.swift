//
//  ExploreCVC.swift
//  Moviez
//
//  Created by Trần Ngô Nhật Hưng on 12/4/21.
//

import UIKit

private let reuseIdentifier = "PosterCVCell"

class ExploreCVC: UICollectionViewController {
    
    var cvVertical = true
    var cvPadding: CGFloat = 8.0
    var cvColumns: CGFloat = 2
    var cvOffset: CGFloat = 0.0
    
    var items = [Item]()
    let imageHelper = ImageHelper()
    let searchHelper = SearchHelper()
    
    var text = "Marvel" {
        didSet {
            updateImages()
        }
    }
    var type = "" {
        didSet {
            updateImages()
        }
    }
    
    var year = "" {
        didSet {
            updateImages()
        }
    }
    
    var page = 1 {
        didSet {
            updateImages()
        }
    }
    
    var totalResults = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "str_explore"
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        updateImages()
        // Do any additional setup after loading the view.
    }
    
    func updateImages() {
        
        searchHelper.fetchMovies(for: text, type: type, year: year, page: page) { result in
            switch result {
                case let .Success(collection):
                    self.items = collection.Search ?? []
                    self.totalResults = Int(collection.totalResults ?? "") ?? 0
                case let .Failure(error):
                    print("fetch error; \(error)")
                    self.items.removeAll()
            }
            
            OperationQueue.main.addOperation {
                self.collectionView?.reloadData()
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return items.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PosterCVCell else {
            return UICollectionViewCell()
        }
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let item = items[indexPath.row]
        imageHelper.fetchImage(urlString: item.Poster, completion: { result in
            
            guard let index = self.items.firstIndex(of: item), case let .Success(imgData) = result else { return }
            
            OperationQueue.main.addOperation {
                if let image = UIImage(data: imgData) {
                    let indexPath = IndexPath(item: index, section: 0)
                    if let cell = collectionView.cellForItem(at: indexPath) as? PosterCVCell {
                        cell.update(image: image, title: item.Title)
                    }
                }
            }
        })
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    @IBAction func onPrevBtn(_ sender: Any) {
        if page > 1 {
            page -= 1
        }
    }
    
    @IBAction func onNextBtn(_ sender: Any) {
        if page * Constants.itemsPerPage < totalResults {
            page += 1
        }
    }
    
}

extension ExploreCVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = collectionView.bounds.width
        width -= (cvColumns + 1) * cvPadding
        return CGSize(width: width/cvColumns, height: width/cvColumns)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: cvPadding, left: cvPadding, bottom: cvPadding, right: cvPadding)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cvPadding
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cvPadding
    }
}
