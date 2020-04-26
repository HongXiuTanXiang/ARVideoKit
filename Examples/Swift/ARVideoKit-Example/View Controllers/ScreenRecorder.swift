//
//  ScreenRecorder.swift
//  SwiftDemo
//
//  Created by 李贺 on 2020/4/24.
//  Copyright © 2020 李贺. All rights reserved.
//

import UIKit
import ReplayKit

typealias CompleteBlock = (URL) -> Void
@available(iOS 12.0, *)
class ScreenRecorder: NSObject {
    
    let recorder = RPScreenRecorder.shared()
    var writer: RecorderWritr?
    var output: URL?
    private var completeBlock: CompleteBlock?
    let stopWindow = StopVideoRecordingWindow()
    
    
    override init() {
        super.init()
        stopWindow.onStopClick = { [weak self] in
            guard let self = self else {return}
            self.stopRecord()
        }
    }
    
    func startRecord(output: URL, width: Int, height: Int, adjustForSharing: Bool, orientaions:[RenderInputViewOrientation], contentMode: RenderFrameMode = .aspectRatio16To9, completeBlock: @escaping CompleteBlock) {
        self.output = output
        self.completeBlock = completeBlock
        
        if FileManager.default.fileExists(atPath: output.path) {
            do {
                try FileManager.default.removeItem(at: output)
            } catch let error {
                print(error)
                return
            }
        }
        
        self.writer = RecorderWritr.init(output: output, width: width, height: height, adjustForSharing: adjustForSharing, orientaions: orientaions,contentMode: .aspectRatio16To9, block: completeBlock)
        
        self.recorder.startCapture(handler: { (samBuffer, bufferType, error) in
            if error != nil {
                print(error.debugDescription)
                self.writer?.changeRecording(isrecord: false)
                self.writer?.cancel()
            }
            
            if bufferType == .video && self.recorder.isRecording {
                self.writer?.insert(sample: samBuffer)
            } else if bufferType == .audioApp {
                print("audio")
            } else if bufferType == .audioMic {
                print("audio mic")
            }
            
        }) {[weak self] (error) in
            guard let self = self else {return}
            if error != nil {
                print(error.debugDescription)
            }
            print("开始成功")
            DispatchQueue.main.async {
                self.stopWindow.show()
            }
        }
    }
    
    func stopRecord() {
        recorder.stopCapture {[weak self] (error) in
            guard let self = self else {return}
            self.writer?.finishWriting()
        }
        
        DispatchQueue.main.async {
            self.stopWindow.hide()
        }
    }



}
