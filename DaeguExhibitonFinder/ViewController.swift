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
    
    // DP검색 API URL
    var targetURL = "https://dgfc.or.kr/ajax/event/list.json?event_gubun=DP&start_date=2021-10"

    // 초기 년/월 설정
    var selectedYear = 2021
    var selectedMonth = 1
    
    // 검색 가능한 날짜인지 Bool타입으로 저장
    var isDateVaild : Bool = false
    
    // 년/월 선택 PickerView 설정
    let setDatePicker = UIPickerView()
    let arrayYear = [2021, 2022]
    let arrayMonth = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
    
    // JSON key별 Array
    var subjects : [String] = [] // 전시명
    var pay_gubuns : [String] = [] // 관람비용 유형 (free : 무료, pay : 유료, invitation : 초대)
    var places : [String] = [] // 장소
    var start_dates : [String] = [] // 시작일
    
    // 첫 검색인지 Bool 타입으로 저장
    var isFirstSearch : Bool = true
    
    // contentView 높이
    var heightOfContentView : Int = 100
    
    // 바탕 UIScrollView
    let scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    // scrollView 위 bgView
    let bgView : UIView = { // scrollView 위에 올라갈 바탕 UIView
        let bgView = UIView()
        bgView.translatesAutoresizingMaskIntoConstraints = false
        return bgView
    }()
    
    @IBOutlet var tfSearchDate: UITextField!
    @IBOutlet var lblReqResult: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createPickerView()
        configToolbar()
        createScrollView()
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
    
    func searchDP() { // 검색, 레이아웃 설정 함수 실행
        // 배열 초기화
        subjects.removeAll()
        pay_gubuns.removeAll()
        places.removeAll()
        start_dates.removeAll()
        
        var selectedMonthStr = String(selectedMonth)
        
        if 1...9 ~= selectedMonth {
            selectedMonthStr = "0\(selectedMonth)"
        }
        
        targetURL = "https://dgfc.or.kr/ajax/event/list.json?event_gubun=DP&start_date=\(selectedYear)-\(selectedMonthStr)"
        AF.request(targetURL, method: .get).validate(statusCode: 200..<300).response
        { [self]
            response in
            
            switch response.result {
            case .success(let resValue):
                let resJson = JSON(resValue!)
                
                if let resJsonArray = resJson.array {
                    for i in 0..<resJsonArray.count {
                        self.subjects.append(resJsonArray[i]["subject"].stringValue) // subjects에 key: subject의 value 저장
                        self.places.append(resJsonArray[i]["place"].stringValue) // places에 key: place의 value 저장
                        self.start_dates.append(resJsonArray[i]["start_date"].stringValue) // start_dates에 key: start_date의 value 저장
                        switch resJsonArray[i]["pay_gubun"].stringValue { // pay_gubuns에 key: pay_gubun의 value 한글로 저장
                        case "free":
                            self.pay_gubuns.append("무료")
                        case "pay":
                            self.pay_gubuns.append("유료")
                        case "invitation":
                            self.pay_gubuns.append("초대 전용")
                        default:
                            return
                        }
                    }
                    if 200..<300 ~= response.response!.statusCode {
                        if subjects.count == 0 {
                            self.lblReqResult.text = "조건과 일치하는 검색결과가 없습니다."
                            self.lblReqResult.textColor = UIColor.systemBlue
                        } else {
                            self.lblReqResult.text = "검색에 성공했습니다!"
                            self.lblReqResult.textColor = UIColor.systemGreen
                        }
                    } else {
                        self.lblReqResult.text = "검색에 실패했습니다."
                        self.lblReqResult.textColor = UIColor.systemRed
                    }
                    
                    //TEST
                    print("검색된 항목의 수: \(self.subjects.count)")
                    print(self.subjects)
                    print(self.pay_gubuns)
                    print(self.start_dates)
                    print(self.places)
                    //TEST
                    
                    createBgView(numberOfContents: self.subjects.count)
                    createContentLayout(numberOfContents: self.subjects.count)
                    
                }
            default:
                break
            }
            return
        }
    }
    
    func createScrollView() { // scrollView 뷰에 추가
        self.view.addSubview(scrollView)
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    }
    
    func createBgView(numberOfContents : Int){
        scrollView.addSubview(bgView)
        bgView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor).isActive = true
        bgView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor).isActive = true
        bgView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor).isActive = true
        bgView.bottomAnchor .constraint(equalTo:scrollView.contentLayoutGuide.bottomAnchor).isActive = true
        
        bgView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true
        bgView.heightAnchor.constraint(equalToConstant: CGFloat(numberOfContents * (heightOfContentView + 20) + 20)).isActive = true
    }
    
    func createContentLayout(numberOfContents : Int){
        var verticalAxisCounter = 20 // contentView topAnchor

        for i in 0..<numberOfContents { // 항목 수(numberOfContents) 만큼 UIView 박스 생성

            let contentView : UIView = {
                let contentView = UIView()
                contentView.layer.cornerRadius = 10
                contentView.backgroundColor = .clear
                contentView.layer.borderWidth = 2
                contentView.layer.borderColor = UIColor.systemGray.cgColor
                contentView.translatesAutoresizingMaskIntoConstraints = false
                return contentView
            }()
            let lblTitle : UILabel = {
                let lblTitle = UILabel()
                lblTitle.text = "\(self.subjects[i])"
                lblTitle.textColor = .black
                lblTitle.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
                lblTitle.translatesAutoresizingMaskIntoConstraints = false
                return lblTitle
            }()
            
            bgView.addSubview(contentView)
            bgView.addSubview(lblTitle)

            contentView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 20).isActive = true
            contentView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -20).isActive = true
            contentView.topAnchor.constraint(equalTo: bgView.topAnchor, constant: CGFloat(verticalAxisCounter)).isActive = true
            
            lblTitle.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 30).isActive = true
            lblTitle.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -30).isActive = true
            lblTitle.topAnchor.constraint(equalTo: bgView.topAnchor, constant: CGFloat(verticalAxisCounter - 45)).isActive = true

            verticalAxisCounter = verticalAxisCounter + heightOfContentView

            contentView.bottomAnchor .constraint(equalTo:bgView.topAnchor, constant: CGFloat(verticalAxisCounter)).isActive = true
            
            lblTitle.bottomAnchor.constraint(equalTo: bgView.topAnchor, constant: CGFloat(verticalAxisCounter - 10)).isActive = true

            verticalAxisCounter = verticalAxisCounter + 20
        }
    }
    
    func resetLayout(numberOfContents : Int) {
        
        for a in bgView.constraints {
            bgView.removeConstraint(a)
        }
        bgView.removeFromSuperview()
    }
    
    @IBAction func btnSearch(_ sender: UIButton) {
        if isDateVaild == true {
            if isFirstSearch == true {
                isFirstSearch = false
            } else {
                resetLayout(numberOfContents: subjects.count)
            }
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
        self.lblReqResult.text = "검색 성공 여부가 여기에 표시됩니다."
        self.lblReqResult.textColor = UIColor.lightGray
    }
    
    @objc func cancelPicker() {
        self.tfSearchDate.text = nil
        self.tfSearchDate.resignFirstResponder()
        self.isDateVaild = false
        self.lblReqResult.text = "검색 성공 여부가 여기에 표시됩니다."
        self.lblReqResult.textColor = UIColor.lightGray
    }
}


