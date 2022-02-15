//
//  ViewController.swift
//  DaeguExhibitonFinder
//
//  Created by 정지원 on 2022/02/11.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    let url = "https://dgfc.or.kr/ajax/event/list.json?event_gubun=DP&start_date=2021-10"
    let header : HTTPHeaders = ["Content-Type" : "application/json", ]

    override func viewDidLoad() {
        super.viewDidLoad()
        AF.request(url, method: .get, headers: header).responseJSON
        {
            response in debugPrint(response)
        }
    }


}

