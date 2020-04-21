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
    
    public var renderScale: CGFloat = 1.5
    
    public var waterImage: UIImage?
    
    private var view: Any?
    private var renderEngine: SCNRenderer!
    var ARcontentMode: ARFrameMode!
    
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
                if UIScreen.main.isNotch {
                    width = Int(UIScreen.main.nativeBounds.width * renderScale)
                    height = Int(UIScreen.main.nativeBounds.height * renderScale)
                }
            case .aspectFit:
                width = CVPixelBufferGetWidth(raw)
                height = CVPixelBufferGetHeight(raw)
            case .aspectFill:
                width = Int(UIScreen.main.nativeBounds.width * renderScale)
                height = Int(UIScreen.main.nativeBounds.height * renderScale)
            case .viewAspectRatio where view is UIView:
                width = Int(UIScreen.main.nativeBounds.width * renderScale)
                height = Int(UIScreen.main.nativeBounds.height * renderScale)
            case .aspectRatio16To9:
                width = Int(UIScreen.main.nativeBounds.width * renderScale)
                height = Int(UIScreen.main.nativeBounds.height * renderScale)
            default:
                if UIScreen.main.isNotch {
                    width = Int(UIScreen.main.nativeBounds.width * renderScale)
                    height = Int(UIScreen.main.nativeBounds.height * renderScale)
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
    
    var clipSize: CGSize {
        if self.ARcontentMode == .aspectRatio16To9 {
            return CGSize.init(width: UIScreen.main.nativeBounds.width * renderScale, height: UIScreen.main.nativeBounds.width * renderScale * 1.778)
        }
        return CGSize.init(width: UIScreen.main.nativeBounds.width * renderScale, height: UIScreen.main.nativeBounds.height * renderScale)
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
            guard let mainImg = renderedFrame else {
                return nil
            }
            guard let buffer = self.bufferWithWaterImage(mainImg: mainImg, water: self.waterImage,clipSize) else {
                return nil
            }
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
            guard let mainImg = renderedFrame else {
                return nil
            }
            guard let buffer = self.bufferWithWaterImage(mainImg: mainImg, water: self.waterImage,clipSize) else {
                return nil
            }
            return buffer;
        } else if view is SCNView {
            let size = CGSize.init(width: UIScreen.main.nativeBounds.width * renderScale, height: UIScreen.main.nativeBounds.height * renderScale)
            var renderedFrame: UIImage?
            pixelsQueue.sync {
                renderedFrame = renderEngine.snapshot(atTime: self.time, with: size, antialiasingMode: .none)
            }
            if let _ = renderedFrame {
            } else {
                renderedFrame = renderEngine.snapshot(atTime: time, with: size, antialiasingMode: .none)
            }
            guard let mainImg = renderedFrame else {
                return nil
            }
            guard let buffer = self.bufferWithWaterImage(mainImg: mainImg, water: self.waterImage,clipSize) else {
                return nil
            }
            return buffer
        }
        return nil
    }
    
    func bufferWithWaterImage(mainImg: UIImage, water: UIImage?,_ clipSize: CGSize) -> CVPixelBuffer? {
        
        
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(clipSize.width), Int(clipSize.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(clipSize.width), height: Int(clipSize.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        UIGraphicsPushContext(context!)
        
        if UIScreen.main.isNotch && self.ARcontentMode == .aspectRatio16To9 { // iphonex
            
            var imageRef: CGImage? = nil
            imageRef = mainImg.cgImage?.cropping(to: CGRect.init(x: 0, y: 0, width: clipSize.width, height: clipSize.height))
            
            guard let cgimg = imageRef else {
                return nil
            }
            
            context?.draw(cgimg, in: CGRect.init(x: 0, y: 0, width: clipSize.width, height: clipSize.height))
            if let wat = water {
                context?.translateBy(x: 0, y: clipSize.height)
                context?.scaleBy(x: 1.0, y: -1.0)
                let watHei: CGFloat = wat.size.height / wat.size.width * mainImg.size.width
                wat.draw(in: CGRect(x: 0, y: clipSize.height - watHei, width: mainImg.size.width, height: watHei))
            }
            
        } else {
            context?.translateBy(x: 0, y: clipSize.height)
            context?.scaleBy(x: 1.0, y: -1.0)
            mainImg.draw(in: CGRect(x: 0, y: 0, width: clipSize.width, height: clipSize.height))
            if let wat = water {
                let watHei: CGFloat = wat.size.height / wat.size.width * clipSize.width
                wat.draw(in: CGRect(x: 0, y: clipSize.height - watHei, width: clipSize.width, height: watHei))
            }
        }
        
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        return pixelBuffer
    }
}
