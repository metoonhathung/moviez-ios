//
//  LanguageEnum.swift
//  Moviez
//
//  Created by Trần Ngô Nhật Hưng on 12/4/21.
//

import Foundation

enum LanguageEnum: Int, CaseIterable {
    
    case en, vi
    
    func title() -> String {
        switch self {
            case .en:
                return "en"
            case .vi:
                return "vi"
        }
    }
    
    init(_ title: String) {
        switch title {
            case "en": self = .en
            case "vi": self = .vi
            default: self = .en
        }
    }
}
