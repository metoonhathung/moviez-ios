//
//  DetailModel.swift
//  Moviez
//
//  Created by Trần Ngô Nhật Hưng on 12/3/21.
//

import Foundation

struct Rating: Decodable {
    var Source: String
    var Value: String
}

struct DetailModel: Decodable {
    var Title: String?
    var Year: String?
    var Rated: String?
    var Released: String?
    var Runtime: String?
    var Genre: String?
    var Director: String?
    var Writer: String?
    var Actors: String?
    var Plot: String?
    var Language: String?
    var Country: String?
    var Awards: String?
    var Poster: String?
    var Ratings: [Rating]?
    var Metascore: String?
    var imdbRating: String?
    var imdbVotes: String?
    var imdbID: String?
    var `Type`: String?
    var DVD: String?
    var BoxOffice: String?
    var Production: String?
    var Website: String?
    var Response: String?
}
