//
//  ViewController.swift
//  DaeguExhibitonFinder
//
//  Created by 정지원 on 2022/02/11.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    let url = "https://dgfc.or.kr/ajax/event/list.json?event_gubun=DP&start_date=2021-09"
    let param : Parameters = [
        "년" : "2022",
        "월" : "09"
    ]
    let header : HTTPHeaders = ["Content-Type" : "application/json", ]

    override func viewDidLoad() {
        super.viewDidLoad()
        AF.request(url, method: .get, parameters: param, headers: header).responseJSON
        {
            response in debugPrint(response)
        }
    }


}

