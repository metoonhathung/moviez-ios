//
//  DirectionEnum.swift
//  Moviez
//
//  Created by Trần Ngô Nhật Hưng on 12/4/21.
//

import Foundation

enum DirectionEnum: Int, CaseIterable {
    
    case vertical, horizontal
    
    func title() -> String {
        switch self {
            case .vertical:
                return "vertical"
            case .horizontal:
                return "horizontal"
        }
    }
    
    init(_ title: String) {
        switch title {
            case "vertical": self = .vertical
            case "horizontal": self = .horizontal
            default: self = .vertical
        }
    }
}
