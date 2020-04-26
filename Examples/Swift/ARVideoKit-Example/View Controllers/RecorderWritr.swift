//
//  ScreenRecorder.swift
//  SwiftDemo
//
//  Created by 李贺 on 2020/4/24.
//  Copyright © 2020 李贺. All rights reserved.
//

import AVFoundation
import CoreImage
import UIKit

@available(iOS 12.0, *)
class RecorderWritr: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {
    private var assetWriter: AVAssetWriter!
    var videoInput: AVAssetWriterInput!
    private var audioInput: AVAssetWriterInput!
    
    public var contentMode: RenderFrameMode = .aspectRatio16To9
    
    private var videoOutputSettings: Dictionary<String, Any>!
    private var audioSettings: [String: Any]?

    let audioBufferQueue = DispatchQueue(label: "com.ahmedbekhit.AudioBufferQueue")
    let audioSampleDataQueue = DispatchQueue(label: "com.ahmedbekhit.audioSampleDataQueue")

    var isRecording: Bool = false
    let lock = NSLock()
    var videoInputOrientation: RenderVideoOrientation = .auto
    
    var output: URL?
    
    private var completeBlock: CompleteBlock?

    init(output: URL, width: Int, height: Int, adjustForSharing: Bool, orientaions:[RenderInputViewOrientation], contentMode: RenderFrameMode = .aspectRatio16To9, block: @escaping CompleteBlock) {
        super.init()
        
        self.completeBlock = block
        self.output = output
        do {
            assetWriter = try AVAssetWriter(outputURL: output, fileType: AVFileType.mp4)
        } catch {
            return
        }
        
        self.contentMode = contentMode
        
        var hei: Int = height
        if self.contentMode == .aspectRatio16To9 {
            hei = Int(CGFloat(width) * 1.778)
        }
        
        videoOutputSettings = [
            AVVideoCodecKey: AVVideoCodecType.h264 ,
            AVVideoWidthKey: width ,
            AVVideoHeightKey: hei,
            ] as [String: Any]
        
        videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoOutputSettings)
        
        videoInput.expectsMediaDataInRealTime = true
        
        var angleEnabled: Bool {
            for v in orientaions {
                if UIDevice.current.orientation.rawValue == v.rawValue {
                    return true
                }
            }
            return false
        }
        
        var recentAngle: CGFloat = 0
        var rotationAngle: CGFloat = 0
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            rotationAngle = -90
            recentAngle = -90
        case .landscapeRight:
            rotationAngle = 90
            recentAngle = 90
        case .faceUp, .faceDown, .portraitUpsideDown:
            rotationAngle = recentAngle
        default:
            rotationAngle = 0
            recentAngle = 0
        }
        
        if !angleEnabled {
            rotationAngle = 0
        }
        
        var t = CGAffineTransform.identity

        switch videoInputOrientation {
        case .auto:
            t = t.rotated(by: ((rotationAngle*CGFloat.pi) / 180))
        case .alwaysPortrait:
            t = t.rotated(by: 0)
        case .alwaysLandscape:
            if rotationAngle == 90 || rotationAngle == -90 {
                t = t.rotated(by: ((rotationAngle * CGFloat.pi) / 180))
            } else {
                t = t.rotated(by: ((-90 * CGFloat.pi) / 180))
            }
        }
        
        videoInput.transform = t
        if assetWriter.canAdd(videoInput) {
            assetWriter.add(videoInput)
        }
        assetWriter.shouldOptimizeForNetworkUse = adjustForSharing
    }
    
    func prepareAudioDevice(with queue: DispatchQueue) {
    
        audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
        audioInput.expectsMediaDataInRealTime = true
        
        if assetWriter.canAdd(audioInput) {
            assetWriter.add(audioInput)
        }
    }
    
    var startingVideoTime: CMTime?
    
    func changeRecording(isrecord: Bool) {
        lock.lock()
        self.isRecording = isrecord
        lock.unlock()
    }

    public func insert(sample buffer: CMSampleBuffer) {
        
        if assetWriter.status == .unknown {
            guard startingVideoTime == nil else {
                return
            }
            
            if assetWriter.startWriting() {
                startingVideoTime = CMSampleBufferGetPresentationTimeStamp(buffer)
                assetWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(buffer))
                self.changeRecording(isrecord: true)
            } else {
                self.changeRecording(isrecord: false)
            }
        } else if assetWriter.status == .failed {
            logAR.message("An error occurred while recording the video, status: \(assetWriter.status.rawValue), error: \(assetWriter.error!.localizedDescription)")
            self.changeRecording(isrecord: false)
            return
        }
        
        if videoInput.isReadyForMoreMediaData && self.isRecording {
            self.videoInput.append(buffer)
        }
    }
    
    func pause() {
        isRecording = false
    }
    
    func finishWriting() {
        if assetWriter.status == .writing {
            assetWriter.finishWriting { [weak self] in
                guard let self = self else {return}
                if let complete = self.completeBlock,let url = self.output {
                    complete(url)
                    print("主动结束成功\n \(url)")
                }
            }
        }
    }
    
    func cancel() {
        assetWriter.cancelWriting()
    }
}


//Simple Logging to show logs only while debugging.
class logAR {
    class func message(_ message: String) {
        #if DEBUG
            print("ARVideoKit @ \(Date().timeIntervalSince1970):- \(message)")
        #endif
    }
    
    class func remove(from path: URL?) {
        if let file = path?.path {
            let manager = FileManager.default
            if manager.fileExists(atPath: file) {
                do{
                    try manager.removeItem(atPath: file)
                    self.message("Successfuly deleted media file from cached after exporting to Camera Roll.")
                } catch let error {
                    self.message("An error occurred while deleting cached media: \(error)")
                }
            }
        }
    }
}
