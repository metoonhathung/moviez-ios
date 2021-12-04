//
//  DetailHelper.swift
//  Moviez
//
//  Created by Trần Ngô Nhật Hưng on 12/3/21.
//

import Foundation

enum DetailHelperResult: Error {
    case Success(DetailModel)
    case Failure(Error)
}

class DetailHelper {
    

    let omdbUrl = "https://www.omdbapi.com/"
    
    private func getDetail(from data: Data) -> DetailHelperResult {
        do {
            let decoder = JSONDecoder()
            let detail = try decoder.decode(DetailModel.self, from: data)
            return .Success(detail)
        } catch let error {
            return .Failure(error)
        }
    }
    
    private func omdbUrl(parameters: [String : String]) -> URL? {
        
        var queryItems = [URLQueryItem]()
        for (key, value) in parameters {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        guard var components = URLComponents(string: omdbUrl) else {
            return nil
        }
        
        components.queryItems = queryItems
        return components.url
    }

    func fetchDetail(for id: String, completion: @escaping (DetailHelperResult) -> Void) {
        
        let params = [
            "apikey": Constants.apikey,
            "i": id
        ]
        if let url = omdbUrl(parameters: params) {
            
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let detailData = data else {
                    if let err = error {
                        completion(.Failure(err))
                    }
                    return
                }
                completion(self.getDetail(from: detailData))
            }
            task.resume()
        } else {
            completion(.Failure(URLError.badURL as! Error))
        }
    }
}
