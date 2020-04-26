//
//  PlayerViewController.swift
//  SwiftDemo
//
//  Created by 李贺 on 2020/4/25.
//  Copyright © 2020 李贺. All rights reserved.
//

import UIKit
import AVKit

class PlayerViewController: UIViewController {
    
    var url: URL!
    
    init(url: URL) {
        super.init(nibName: nil, bundle: nil)
        self.url = url
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let player = AVPlayerViewController.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white

        player.player = AVPlayer.init(url: url)
        player.view.frame = self.view.bounds
        self.view.addSubview(player.view)
        player.player?.play()
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
