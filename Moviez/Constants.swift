//
//  Constants.swift
//  Moviez
//
//  Created by Trần Ngô Nhật Hưng on 12/3/21.
//

import Foundation
import UIKit

let apikey = "14795466"
let itemsPerPage = 10
let kMaxColumns = 10
let kMaxPadding = 32

let dWasLaunchedBefore = "was_launched_before"
let dDarkMode = "dark_mode"
let dLanguage = "language"
let dVertical = "vertical"
let dColumns = "columns"
let dPadding = "padding"
let dOffset = "offset"

var lang = "en"

public struct Notifications {
    public static let movieAdded = Notification.Name(rawValue: "MovieAdded")
    public static let directionChanged = Notification.Name(rawValue: "DirectionChanged")
    public static let columnsChanged = Notification.Name(rawValue: "ColumnsChanged")
    public static let paddingChanged = Notification.Name(rawValue: "PaddingChanged")
    public static let bottomChanged = Notification.Name(rawValue: "BottomChanged")
    public static let languageChanged = Notification.Name(rawValue: "LanguageChanged")
}
