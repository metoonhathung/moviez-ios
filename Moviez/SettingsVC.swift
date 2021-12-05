//
//  SettingsVC.swift
//  Moviez
//
//  Created by Trần Ngô Nhật Hưng on 12/3/21.
//

import UIKit

class SettingsVC: UIViewController {
    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var languagePicker: UIPickerView!
    @IBOutlet weak var directionPicker: UIPickerView!
    @IBOutlet weak var columnsStepper: UIStepper!
    @IBOutlet weak var columnsLabel: UILabel!
    @IBOutlet weak var paddingStepper: UIStepper!
    @IBOutlet weak var paddingLabel: UILabel!
    @IBOutlet weak var bottomSwitch: UISwitch!
    @IBOutlet weak var infoLabel: UILabel!
    
    let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
    let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    let defaults = UserDefaults.standard

    @IBOutlet weak var constDarkModeLabel: UILabel!
    @IBOutlet weak var constLanguageLabel: UILabel!
    @IBOutlet weak var constDirectionLabel: UILabel!
    @IBOutlet weak var constColumnsLabel: UILabel!
    @IBOutlet weak var constPaddingLabel: UILabel!
    @IBOutlet weak var constBottomLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "primary")
        
        let darkMode = defaults.bool(forKey: dDarkMode)
        darkModeSwitch.isOn = darkMode
        
        let vertical = defaults.bool(forKey: dVertical)
        directionPicker?.selectRow(vertical ? DirectionEnum.vertical.rawValue : DirectionEnum.horizontal.rawValue, inComponent: 0, animated: false)
        
        let language = defaults.string(forKey: dLanguage)
        languagePicker?.selectRow(LanguageEnum(language ?? "") == .en ? LanguageEnum.en.rawValue : LanguageEnum.vi.rawValue, inComponent: 0, animated: false)
        
        columnsStepper?.value = Double(defaults.integer(forKey: dColumns))
        columnsLabel?.text = String(Int(columnsStepper.value))
        
        paddingStepper?.value = Double(defaults.integer(forKey: dPadding))
        paddingLabel?.text = String(Int(paddingStepper.value))
        
        let offset = defaults.bool(forKey: dOffset)
        bottomSwitch.isOn = offset
        
        localized()
        NotificationCenter.default.addObserver(forName: Notifications.languageChanged, object: nil, queue: nil) { _ in
            self.localized()
        }
        
        // Do any additional setup after loading the view.
    }
    
    func localized() {
        navigationItem.title = "str_settings".localized()
        constDarkModeLabel?.text = "str_darkmode".localized()
        constLanguageLabel?.text = "str_language".localized()
        constDirectionLabel?.text = "str_direction".localized()
        constColumnsLabel?.text = "str_columns".localized()
        constPaddingLabel?.text = "str_padding".localized()
        constBottomLabel?.text = "str_bottom".localized()
        infoLabel?.text = """
        \("str_app_name".localized()): \(appName ?? "")
        \("str_app_version".localized()): \(appVersion ?? "")
        """
        languagePicker?.reloadAllComponents()
        directionPicker?.reloadAllComponents()
    }
    
    @IBAction func onDarkModeChanged(_ sender: UISwitch) {
        let value = sender.isOn
        defaults.set(value, forKey: dDarkMode)
        if #available(iOS 13, *) {
            let appDelegate = UIApplication.shared.windows.first
            appDelegate?.overrideUserInterfaceStyle = value ? .dark : .light
        }
    }
    
    @IBAction func onColumnsChanged(_ sender: UIStepper) {
        var value = Int(sender.value)
        if value > kMaxColumns {
            value -= 1
        }
        if value < 1 {
            value += 1
        }
        columnsLabel?.text = String(value)
        defaults.set(value, forKey: dColumns)
        let dict: [String: Int] = ["columns": value]
        NotificationCenter.default.post(name: Notifications.columnsChanged, object: nil, userInfo: dict)
    }
    
    @IBAction func onPaddingChanged(_ sender: UIStepper) {
        var value = Int(sender.value)
        if value > kMaxPadding {
            value -= 8
        }
        if value < 0 {
            value += 8
        }
        paddingLabel?.text = String(value)
        defaults.set(value, forKey: dPadding)
        let dict: [String: Int] = ["padding": value]
        NotificationCenter.default.post(name: Notifications.paddingChanged, object: nil, userInfo: dict)
    }
    
    @IBAction func onBottomChanged(_ sender: UISwitch) {
        let value = sender.isOn
        defaults.set(value, forKey: dOffset)
        let dict: [String: Bool] = ["offset": value]
        NotificationCenter.default.post(name: Notifications.bottomChanged, object: nil, userInfo: dict)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SettingsVC: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case languagePicker:
            return LanguageEnum.allCases.count
        case directionPicker:
            return DirectionEnum.allCases.count
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case languagePicker:
            return LanguageEnum(rawValue: row)?.title().localized()
        case directionPicker:
            return DirectionEnum(rawValue: row)?.title().localized()
        default: return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case languagePicker:
            lang = LanguageEnum(rawValue: row)?.title() ?? ""
            defaults.set(lang, forKey: dLanguage)
            let dict: [String: String] = ["language": lang]
            NotificationCenter.default.post(name: Notifications.languageChanged, object: nil, userInfo: dict)
            
        case directionPicker:
            let vertical = DirectionEnum(rawValue: row) == .vertical
            defaults.set(vertical, forKey: dVertical)
            let dict: [String: Bool] = ["vertical": vertical]
            NotificationCenter.default.post(name: Notifications.directionChanged, object: nil, userInfo: dict)
        default: break
        }
    }
}

extension String {
    func localized() -> String {
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}
