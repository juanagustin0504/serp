//
//  LaunchViewController.swift
//  serp-sample
//
//  Created by Webcash on 2019/11/28.
//  Copyright © 2019 WebCash. All rights reserved.
//

import UIKit

/**
 * 앱이 실행될 때 앱 초기 설정 데이터 받아오는 뷰컨
 */
class LaunchViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainActivity")
        self.navigationController?.pushViewController(mainVC!, animated: true)
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
