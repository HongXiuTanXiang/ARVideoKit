//
//  ReplayKitDemoViewController.swift
//  ARVideoKit-Example
//
//  Created by 李贺 on 2020/4/26.
//  Copyright © 2020 Ahmed Fathi Bekhit. All rights reserved.
//


import UIKit
import ARKit
import ARVideoKit
import Photos


@available(iOS 12.0, *)
class ReplayKitDemoViewController: UIViewController, ARSCNViewDelegate  {
    
    
    @objc dynamic private lazy var sceneView: ARSCNView = {
        let view = ARSCNView()
        return view
    }()

    
    lazy var recordBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("录制", for: .normal)
        btn.addTarget(self, action: #selector(recordBtnClick), for: UIControl.Event.touchUpInside)
        btn.setTitleColor(UIColor.black, for: UIControl.State.normal)
        btn.backgroundColor = UIColor.white
        return btn
    }()
    
    lazy var pauseBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("停止", for: .normal)
        btn.addTarget(self, action: #selector(pauseBtnClick), for: UIControl.Event.touchUpInside)
        btn.setTitleColor(UIColor.black, for: UIControl.State.normal)
        btn.backgroundColor = UIColor.white
        return btn
    }()
    
    lazy var takePhotoBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("拍照", for: .normal)
        btn.addTarget(self, action: #selector(takePhotoBtnClick), for: UIControl.Event.touchUpInside)
        btn.setTitleColor(UIColor.black, for: UIControl.State.normal)
        btn.backgroundColor = UIColor.white
        return btn
    }()
    
    lazy var goback: UIButton = {
        let btn = UIButton()
        btn.setTitle("goback", for: .normal)
        btn.addTarget(self, action: #selector(gobackClick), for: UIControl.Event.touchUpInside)
        btn.setTitleColor(UIColor.black, for: UIControl.State.normal)
        btn.backgroundColor = UIColor.white
        return btn
    }()
    
    let recordingQueue = DispatchQueue(label: "recordingThread", attributes: .concurrent)
    let caprturingQueue = DispatchQueue(label: "capturingThread", attributes: .concurrent)

    let recorder = ScreenRecorder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.scene.rootNode.scale = SCNVector3(0.2, 0.2, 0.2)
        //
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
        self.view.addSubview(sceneView)
        sceneView.frame = self.view.bounds
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Pause the view's session
        sceneView.session.pause()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Hide Status Bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc dynamic func setupUI() {

        self.view.backgroundColor = UIColor.white
        self.title = "ReplayKitDemoViewController"

        self.view.addSubview(goback)
        goback.frame = CGRect.init(x: 20, y: 20, width: 100, height: 50)

        self.recordBtn.frame = CGRect.init(x: 20, y: 80, width: 200, height: 50)
        self.pauseBtn.frame = CGRect.init(x: 20, y: 140, width: 200, height: 50)
        self.view.addSubview(self.recordBtn)
        self.view.addSubview(self.pauseBtn)

        self.takePhotoBtn.frame = CGRect.init(x: 20, y: 200, width: 200, height: 50)
        self.view.addSubview(self.takePhotoBtn)

    }

}

//MARK: - Button Action Methods
@available(iOS 12.0, *)
extension ReplayKitDemoViewController {
    
    @objc dynamic func gobackClick() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc dynamic func recordBtnClick() {
        
        print("开始录制")
        
        let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first as NSString?
        let finialPath = cachePath?.appendingPathComponent("recordVideo.mp4") ?? ""
        let output = URL.init(fileURLWithPath: finialPath)
        
        let width = UIScreen.main.nativeBounds.size.width
        let height = UIScreen.main.nativeBounds.size.height
        recorder.startRecord(output: output, width: Int(width), height: Int(height), adjustForSharing: false, orientaions: [.portrait], completeBlock: {[weak self] url in
            guard let self = self else {return}
            DispatchQueue.main.async {
                let player = PlayerViewController.init(url: url)
                self.present(player, animated: true, completion: nil)
            }
        })
    }
    
    @objc dynamic func pauseBtnClick() {
        
        print("录制结束")
    }
    
    @objc dynamic func takePhotoBtnClick() {
        
    }
}



