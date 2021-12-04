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
    
    let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "str_settings"
        
        let darkMode = defaults.bool(forKey: dDarkMode)
        darkModeSwitch.isOn = darkMode
        if #available(iOS 13, *) {
            let appDelegate = UIApplication.shared.windows.first
            appDelegate?.overrideUserInterfaceStyle = darkMode ? .dark : .light
        }
        
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
        
        // Do any additional setup after loading the view.
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
            return LanguageEnum(rawValue: row)?.title()
        case directionPicker:
            return DirectionEnum(rawValue: row)?.title()
        default: return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case languagePicker:
            print(LanguageEnum(rawValue: row)?.title() ?? "")
        case directionPicker:
            let vertical = DirectionEnum(rawValue: row) == .vertical
            defaults.set(vertical, forKey: dVertical)
            let dict: [String: Bool] = ["vertical": vertical]
            NotificationCenter.default.post(name: Notifications.directionChanged, object: nil, userInfo: dict)
        default: break
        }
    }
}
