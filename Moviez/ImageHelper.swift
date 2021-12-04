//
//  ImageHelper.swift
//  Moviez
//
//  Created by Trần Ngô Nhật Hưng on 12/4/21.
//

import Foundation

enum ImageResult {
    case Success(Data)
    case Failure(Error)
}

class ImageHelper {
    
    func fetchImage(urlString: String, completion: @escaping (ImageResult) -> Void) {
        
        if let url = URL(string: urlString) {
            
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let imgData = data else {
                    if let err = error {
                        completion(.Failure(err))
                    }
                    return
                }
                completion(.Success(imgData))
            }
            task.resume()
        }
    }
}


