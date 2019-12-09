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

let images = ["intro_bg_1125x2436.png", "intro_bg_1242.png", "intro_bg_1280.png", "intro_bg.png"]
class LaunchViewController: UIViewController {

    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.frame = self.view.frame
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Thread.sleep(forTimeInterval: 2.0)
        let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainVC")
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
