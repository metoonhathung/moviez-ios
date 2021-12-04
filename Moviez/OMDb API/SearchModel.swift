//
//  SearchModel.swift
//  Moviez
//
//  Created by Trần Ngô Nhật Hưng on 12/3/21.
//

import Foundation

struct Item: Decodable {
    var Title: String
    var Year: String
    var imdbID: String
    var `Type`: String
    var Poster: String
}

struct SearchModel: Decodable {
    var Search: [Item]?
    var totalResults: String?
    var Response: String?
}
