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

enum iPhoneDeviceName: String {
    
    case iPhone5s       = "iPhone 5s"
    case iPhone6        = "iPhone 6"
    case iPhone6p       = "iPhone 6Plus"
    case iPhone6s       = "iPhone 6s"
    case iPhone6sp      = "iPhone 6s Plus"
    case iPhoneX        = "iPhone X"
    case iPhoneXmax     = "iPhone X Max"
    case iPhone11ProMax = "iPhone 11 Pro Max"
}

class LaunchViewController: UIViewController {

    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(UIDevice.current.name)
        switch UIDevice.current.name {
        case iPhoneDeviceName.iPhone5s.rawValue:
            imageView.image = UIImage(named: "intro_bg_5s.png")
        case iPhoneDeviceName.iPhone6.rawValue, iPhoneDeviceName.iPhone6p.rawValue, iPhoneDeviceName.iPhone6s.rawValue, iPhoneDeviceName.iPhone6sp.rawValue:
            imageView.image = UIImage(named: "intro_bg_6s.png")
        case iPhoneDeviceName.iPhoneX.rawValue:
            imageView.image = UIImage(named: "intro_bg_x.png")
        case iPhoneDeviceName.iPhoneXmax.rawValue:
            imageView.image = UIImage(named: "intro_bg_xmax.png")
        case iPhoneDeviceName.iPhone11ProMax.rawValue:
            imageView.image = UIImage(named: "intro_bg_11.png")
        default:
            imageView.image = UIImage(named: "intro_bg_x.png")
        }
        
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
