//
//  ViewController.swift
//  DaeguExhibitonFinder
//
//  Created by 정지원 on 2022/02/11.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    var selectedYear = 2021
    var selectedMonth = 07
    
    let url = "https://dgfc.or.kr/ajax/event/list.json?event_gubun=DP&start_date=2021-10"
    let header : HTTPHeaders = ["Content-Type" : "application/json", ]

    override func viewDidLoad() {
        super.viewDidLoad()
        AF.request(url, method: .get, headers: header).responseJSON
        {
            response in debugPrint(response)
        }
    }
    
    func setSearchDate(inputYear : Int, inputMonth : Int){
        if 2021...2022 ~= inputYear && 1...12 ~= inputMonth{
            selectedYear = inputYear; selectedMonth = inputMonth
        }
    }

}

