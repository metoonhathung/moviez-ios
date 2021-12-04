//
//  TypeEnum.swift
//  Moviez
//
//  Created by Trần Ngô Nhật Hưng on 12/4/21.
//

import Foundation

enum TypeEnum: Int, CaseIterable {
    
    case movie, series
    
    func title() -> String {
        switch self {
            case .movie:
                return "movie"
            case .series:
                return "series"
        }
    }
    
    init(_ title: String) {
        switch title {
            case "movie": self = .movie
            case "series": self = .series
            default: self = .movie
        }
    }
}
