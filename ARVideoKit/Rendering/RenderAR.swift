//
//  RenderAR.swift
//  ARVideoKit
//
//  Created by Ahmed Bekhit on 1/7/18.
//  Copyright © 2018 Ahmed Fathit Bekhit. All rights reserved.
//

import Foundation
import ARKit

@available(iOS 11.0, *)
struct RenderAR {
    private var view: Any?
    private var renderEngine: SCNRenderer!
    var ARcontentMode: ARFrameMode!
    var renderScale: CGFloat = 1.5
    
    init(_ ARview: Any?, renderer: SCNRenderer, contentMode: ARFrameMode) {
        view = ARview
        renderEngine = renderer
        ARcontentMode = contentMode
    }
    
    let pixelsQueue = DispatchQueue(label: "com.ahmedbekhit.PixelsQueue", attributes: .concurrent)
    var time: CFTimeInterval { return CACurrentMediaTime()}
    var rawBuffer: CVPixelBuffer? {
        if let view = view as? ARSCNView {
            guard let rawBuffer = view.session.currentFrame?.capturedImage else { return nil }
            return rawBuffer
        } else if let view = view as? ARSKView {
            guard let rawBuffer = view.session.currentFrame?.capturedImage else { return nil }
            return rawBuffer
        } else if view is SCNView {
            return buffer
        }
        return nil
    }
    
    var bufferSize: CGSize? {
        guard let raw = rawBuffer else { return nil }
        var width = CVPixelBufferGetWidth(raw)
        var height = CVPixelBufferGetHeight(raw)
        
        if let contentMode = ARcontentMode {
            switch contentMode {
            case .auto:
                if UIScreen.main.isiPhone10 {
                    width = Int(UIScreen.main.nativeBounds.width)
                    height = Int(UIScreen.main.nativeBounds.height)
                }
            case .aspectFit:
                width = CVPixelBufferGetWidth(raw)
                height = CVPixelBufferGetHeight(raw)
            case .aspectFill:
                width = Int(UIScreen.main.nativeBounds.width)
                height = Int(UIScreen.main.nativeBounds.height)
            case .viewAspectRatio where view is UIView:
                let bufferWidth = CVPixelBufferGetWidth(raw)
                let bufferHeight = CVPixelBufferGetHeight(raw)
                let viewSize = (view as! UIView).bounds.size
                let targetSize = AVMakeRect(aspectRatio: viewSize, insideRect: CGRect(x: 0, y: 0, width: bufferWidth, height: bufferHeight)).size
                width = Int(targetSize.width)
                height = Int(targetSize.height)
            case .aspectRatio16To9:
                width = Int(UIScreen.main.nativeBounds.width * renderScale)
                height = Int(UIScreen.main.nativeBounds.height * renderScale)
            default:
                if UIScreen.main.isiPhone10 {
                    width = Int(UIScreen.main.nativeBounds.width)
                    height = Int(UIScreen.main.nativeBounds.height)
                }
            }
        }
        
        if width > height {
            return CGSize(width: height, height: width)
        } else {
            return CGSize(width: width, height: height)
        }
    }
    
    var bufferSizeFill: CGSize? {
        guard let raw = rawBuffer else { return nil }
        let width = CVPixelBufferGetWidth(raw)
        let height = CVPixelBufferGetHeight(raw)
        if width > height {
            return CGSize(width: height, height: width)
        } else {
            return CGSize(width: width, height: height)
        }
    }
    
    var buffer: CVPixelBuffer? {
        if view is ARSCNView {
            guard let size = bufferSize else { return nil }
            //UIScreen.main.bounds.size
            var renderedFrame: UIImage?
            pixelsQueue.sync {
                renderedFrame = renderEngine.snapshot(atTime: self.time, with: size, antialiasingMode: .none)
            }
            if let _ = renderedFrame {
            } else {
                renderedFrame = renderEngine.snapshot(atTime: time, with: size, antialiasingMode: .none)
            }
            
            renderedFrame = self.cropImageWithcontentMode(contentMode: ARcontentMode, renderedFrame: renderedFrame)
            guard let buffer = renderedFrame!.buffer else { return nil }
            return buffer
        } else if view is ARSKView {
            guard let size = bufferSize else { return nil }
            var renderedFrame: UIImage?
            pixelsQueue.sync {
                renderedFrame = renderEngine.snapshot(atTime: self.time, with: size, antialiasingMode: .none).rotate(by: 180)
            }
            if renderedFrame == nil {
                renderedFrame = renderEngine.snapshot(atTime: time, with: size, antialiasingMode: .none).rotate(by: 180)
            }
            renderedFrame = self.cropImageWithcontentMode(contentMode: ARcontentMode, renderedFrame: renderedFrame)
            guard let buffer = renderedFrame!.buffer else { return nil }
            return buffer;
        } else if view is SCNView {
            var size = UIScreen.main.bounds.size
            let width = Int(UIScreen.main.nativeBounds.width * renderScale)
            let height = Int(UIScreen.main.nativeBounds.height * renderScale)
            size = CGSize.init(width: width, height: height)

            var renderedFrame: UIImage?
            pixelsQueue.sync {
                renderedFrame = renderEngine.snapshot(atTime: self.time, with: size, antialiasingMode: .none)
            }
            if let _ = renderedFrame {
            } else {
                renderedFrame = renderEngine.snapshot(atTime: time, with: size, antialiasingMode: .none)
            }
            renderedFrame = self.cropImageWithcontentMode(contentMode: ARcontentMode, renderedFrame: renderedFrame)
            guard let buffer = renderedFrame!.buffer else { return nil }
            return buffer
        }
        return nil
    }
    
    func cropImageWithcontentMode(contentMode: ARFrameMode, renderedFrame: UIImage?) -> UIImage? {
        switch contentMode {
        case .aspectRatio16To9:
            guard let image =  renderedFrame else {
                return nil
            }
            let img = image.cropping(to: CGRect.init(x: 0, y: (image.size.height - image.size.width * 1.778) / 2, width: image.size.width, height: image.size.width * 1.778))
            return img
        default:
            return renderedFrame
        }
    }
}
