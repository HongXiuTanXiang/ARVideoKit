//
//  MainViewController.swift
//  ARVideoKit-Example
//
//  Created by Ahmed Bekhit on 11/21/17.
//  Copyright © 2017 Ahmed Fathi Bekhit. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet var skBtn: UIButton!
    @IBOutlet var scnBtn: UIButton!
    lazy var senceButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("SenceViewController", for: UIControl.State.normal)
        btn.addTarget(self, action: #selector(senceButtonClick), for: UIControl.Event.touchUpInside)
        btn.setTitleColor(UIColor.black, for: UIControl.State.normal)
        btn.backgroundColor = UIColor.white
        return btn
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        skBtn.layer.cornerRadius = skBtn.bounds.height/2
        scnBtn.layer.cornerRadius = scnBtn.bounds.height/2
        
        self.view.addSubview(senceButton)
        senceButton.frame = CGRect.init(x: 20, y: 450, width: 380, height: 60)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc dynamic func senceButtonClick() {
        let senceVc = SenceViewController()
        self.present(senceVc, animated: true, completion: nil)
    }


}
