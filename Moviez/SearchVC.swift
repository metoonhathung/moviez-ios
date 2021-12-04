//
//  SearchVC.swift
//  Moviez
//
//  Created by Trần Ngô Nhật Hưng on 12/3/21.
//

import UIKit

protocol SearchDelegate: AnyObject {
    func updateSearch(title: String, type: String, year: String)
}

class SearchVC: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var typePickerView: UIPickerView!
    @IBOutlet weak var yearField: UITextField!
    
    weak var delegate: SearchDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func onCancelBtn(_ sender: Any) {
        presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func onGoBtn(_ sender: Any) {
        if let searchTitle = titleField?.text, let year = yearField?.text {
            let type = TypeEnum(rawValue: typePickerView.selectedRow(inComponent: 0))?.title() ?? ""
            delegate?.updateSearch(title: searchTitle, type: type, year: year)
        }
        presentingViewController?.dismiss(animated: true)
    }
    
}

extension SearchVC: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return TypeEnum.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return TypeEnum(rawValue: row)?.title()
    }
}
