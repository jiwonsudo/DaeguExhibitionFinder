//
//  ViewController.swift
//  DaeguExhibitonFinder
//
//  Created by 정지원 on 2022/02/11.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    var targetURL = "https://dgfc.or.kr/ajax/event/list.json?event_gubun=DP&start_date=2021-10"
    let header : HTTPHeaders = ["Content-Type" : "application/json", ]

    var selectedYear = 2021
    var selectedMonth = 1
    
    var isDateVaild = false
    
    let setDatePicker = UIPickerView()
    let arrayYear = [2021, 2022]
    let arrayMonth = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
    
    var subjects : [String] = []
    
    @IBOutlet var tfSearchDate: UITextField!
    @IBOutlet var lblReqResult: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createPickerView()
        configToolbar()
    }
    
    func setDate(inputYear : Int, inputMonth : Int){
        if inputYear == 2021 && 1...6 ~= inputMonth {
            isDateVaild = false
            tfSearchDate.text = nil
            
            let alertUnvalidDate = UIAlertController(title: "유효하지 않은 날짜", message: "2021년 7월 이후부터 검색이 가능합니다. 날짜를 다시 선택해주세요.", preferredStyle: .alert)
            let actionOK = UIAlertAction(title: "확인", style: .default, handler: {action in })
            alertUnvalidDate.addAction(actionOK)
            present(alertUnvalidDate, animated: true, completion: nil)
        } else if 2021...2022 ~= inputYear && 1...12 ~= inputMonth{
            isDateVaild = true
            
            selectedYear = inputYear; selectedMonth = inputMonth
            tfSearchDate.text = "종료: \(selectedYear)년 \(selectedMonth)월"
        }
    }
    
    func searchDP() {
        subjects.removeAll() // 배열 초기화
        
        var selectedMonthStr = String(selectedMonth)
        
        if 1...9 ~= selectedMonth {
            selectedMonthStr = "0\(selectedMonth)"
        }
        
        targetURL = "https://dgfc.or.kr/ajax/event/list.json?event_gubun=DP&start_date=\(selectedYear)-\(selectedMonthStr)"
        AF.request(targetURL, method: .get).validate(statusCode: 200..<300).response
        {
            response in
            
            switch response.result {
            case .success(let resValue):
                let resJson = JSON(resValue!)
                
                if let resJsonArray = resJson.array {
                    for i in 0..<resJsonArray.count {
                        self.subjects.append(resJsonArray[i]["subject"].stringValue)
                    }
                }
            default:
                return
                
            }
            print(self.subjects) // TEST
            
            if 200..<300 ~= response.response!.statusCode {
                self.lblReqResult.text = "요청에 성공했습니다!"
                self.lblReqResult.textColor = UIColor.systemGreen
            } else {
                self.lblReqResult.text = "요청에 실패했습니다."
                self.lblReqResult.textColor = UIColor.systemRed
            }
            // futureUpdate : JSON decode 필요
        }
    }
    
    @IBAction func btnSearch(_ sender: UIButton) {
        if isDateVaild == true {
            searchDP()
        } else {
            let alertDateEmpty = UIAlertController(title: "경고", message: "전시의 종료 년도, 월을 입력해주세요.", preferredStyle: .alert)
            let actionOK = UIAlertAction(title: "확인", style: .default, handler: {action in })
            alertDateEmpty.addAction(actionOK)
            present(alertDateEmpty, animated: true, completion: nil)
        }
    }
    
}

extension ViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    
    func createPickerView() {
        tfSearchDate.tintColor = .clear
        setDatePicker.delegate = self
        setDatePicker.dataSource = self
        
        tfSearchDate.inputView = setDatePicker
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return arrayYear.count
        case 1:
            return arrayMonth.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(arrayYear[row])년"
        case 1:
            return "\(arrayMonth[row])월"
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            selectedYear = arrayYear[row]
        case 1:
            selectedMonth = arrayMonth[row]
        default:
            break
        }
    }
    
    func configToolbar() {
        let setDateToolbar = UIToolbar()
        setDateToolbar.barStyle = .default
        setDateToolbar.isTranslucent = true
        setDateToolbar.tintColor = UIColor.black
        setDateToolbar.sizeToFit()
        
        let btnDone = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(self.donePicker))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let btnCancel = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(self.cancelPicker))
        
        setDateToolbar.setItems([btnCancel, flexibleSpace, btnDone], animated: false)
        setDateToolbar.isUserInteractionEnabled = true
        
        tfSearchDate.inputAccessoryView = setDateToolbar
    }
        
    @objc func donePicker() {
        let yearRow = self.setDatePicker.selectedRow(inComponent: 0)
        let monthRow = self.setDatePicker.selectedRow(inComponent: 1)
        self.setDatePicker.selectRow(yearRow, inComponent: 0, animated: false)
        self.setDatePicker.selectRow(monthRow, inComponent: 1, animated: false)
        print(yearRow)
        self.tfSearchDate.resignFirstResponder()
        setDate(inputYear: selectedYear, inputMonth: selectedMonth)
        self.lblReqResult.text = "요청 결과가 여기에 표시됩니다."
        self.lblReqResult.textColor = UIColor.lightGray
    }
    
    @objc func cancelPicker() {
        self.tfSearchDate.text = nil
        self.tfSearchDate.resignFirstResponder()
        self.isDateVaild = false
        self.lblReqResult.text = "요청 결과가 여기에 표시됩니다."
        self.lblReqResult.textColor = UIColor.lightGray
    }
}


