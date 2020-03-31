//
//  SenceViewController.swift
//  ARVideoKit-Example
//
//  Created by 李贺 on 2020/3/30.
//  Copyright © 2020 Ahmed Fathi Bekhit. All rights reserved.
//

import UIKit
import ARVideoKit
import SceneKit

class SenceViewController: UIViewController,SCNSceneRendererDelegate {
    
    lazy var sceneView: SCNView = {
        let view = SCNView()
        return view
    }()

    var node: SCNNode?
    
    var recorder:RecordAR?
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @objc dynamic func setupUI() {
        
        self.view.backgroundColor = UIColor.white
        self.title = "SenceViewController"
        
        makeScence()
        makeNode()

        
        recorder = RecordAR.init(SceneKit: sceneView)
        /*----👇---- ARVideoKit Configuration ----👇----*/
        
        // Set the recorder's delegate
        recorder?.delegate = self

        recorder?.renderScale = 2.0
        
        // Configure the renderer to perform additional image & video processing 👁
        recorder?.onlyRenderWhileRecording = false
        
        // Configure ARKit content mode. Default is .auto
        recorder?.contentMode = .aspectRatio16To9
        
        recorder?.fps = .auto
        
        //record or photo add environment light rendering, Default is false
        recorder?.enableAdjustEnvironmentLighting = true
        
        // Set the UIViewController orientations
        recorder?.inputViewOrientations = [.landscapeLeft, .landscapeRight, .portrait]
        // Configure RecordAR to store media files in local app directory
        recorder?.deleteCacheWhenExported = false
        
        

        self.view.addSubview(goback)
        goback.frame = CGRect.init(x: 20, y: 20, width: 100, height: 50)
        
        self.recordBtn.frame = CGRect.init(x: 20, y: 80, width: 200, height: 50)
        self.pauseBtn.frame = CGRect.init(x: 20, y: 140, width: 200, height: 50)
        self.view.addSubview(self.recordBtn)
        self.view.addSubview(self.pauseBtn)
        
        self.takePhotoBtn.frame = CGRect.init(x: 20, y: 200, width: 200, height: 50)
        self.view.addSubview(self.takePhotoBtn)
        
    }
    
    @objc dynamic func makeScence() -> Void {
        
        self.sceneView = SCNView.init(frame: self.view.bounds)
        self.sceneView.backgroundColor = UIColor.white
        self.sceneView.backgroundColor = UIColor.black
        
    
        self.view.addSubview(sceneView)
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        self.sceneView.scene = scene
        self.node = scene.rootNode
        self.node?.eulerAngles = SCNVector3Make(Float(-CGFloat.pi*2), 0, 0)
        return
    }
    
    
    @objc dynamic func makeNode() -> Void {
    
        let camersNode = SCNNode.init()
        camersNode.camera = SCNCamera.init()
        self.sceneView.scene?.rootNode.addChildNode(camersNode)
        self.sceneView.allowsCameraControl = true
        // 相机z轴的位置会影响AR物体的大小
        camersNode.position = SCNVector3Make(0, 1, 3)
        
        return
    }

    
    @objc dynamic func gobackClick() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc dynamic func recordBtnClick() {
        recorder?.record()
        print("开始录制")
    }
    
    @objc dynamic func pauseBtnClick() {
        recorder?.stop()
        print("录制结束")
    }
    
    @objc dynamic func takePhotoBtnClick() {
        let image = recorder?.photo()
        recorder?.export(image: nil, UIImage: image, { (success, status) in
            print("保存照片")
        })
        
    }


    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recorder?.prepare(nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if recorder?.status == .recording {
            recorder?.stopAndExport()
        }
        recorder?.onlyRenderWhileRecording = true
        recorder?.prepare(nil)
        
        // Switch off the orientation lock for UIViewControllers with AR Scenes
        recorder?.rest()
    }
}

extension SenceViewController: RecordARDelegate {
    
    func recorder(didEndRecording path: URL, with noError: Bool) {
        if noError {
            self.recorder?.export(video: path) { saved, status in
                print("保存到相册")
            }
        }
    }
    
    func recorder(didFailRecording error: Error?, and status: String) {
        
    }
    
    func recorder(willEnterBackground status: RecordARStatus) {
        
    }
    
    
}
