//
//  SearchHelper.swift
//  Moviez
//
//  Created by Trần Ngô Nhật Hưng on 12/3/21.
//

import Foundation

enum SearchHelperResult: Error {
    case Success(SearchModel)
    case Failure(Error)
}

class SearchHelper {
    

    let omdbUrl = "https://www.omdbapi.com/"
    
    private func getMovies(from data: Data) -> SearchHelperResult {
        do {
            let decoder = JSONDecoder()
            let movies = try decoder.decode(SearchModel.self, from: data)
            return .Success(movies)
        } catch let error {
            return .Failure(error)
        }
    }
    
    func omdbUrl(parameters: [String : String]) -> URL? {
        
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

    func fetchMovies(for title: String, type: String, year: String, page: Int, completion: @escaping (SearchHelperResult) -> Void) {
        
        let params = [
            "apikey": apikey,
            "s": title,
            "type": type,
            "y": year,
            "page": String(page)
        ]
        if let url = omdbUrl(parameters: params) {
            
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let moviesData = data else {
                    if let err = error {
                        completion(.Failure(err))
                    }
                    return
                }
                completion(self.getMovies(from: moviesData))
            }
            task.resume()
        } else {
            completion(.Failure(URLError.badURL as! Error))
        }
    }
}
