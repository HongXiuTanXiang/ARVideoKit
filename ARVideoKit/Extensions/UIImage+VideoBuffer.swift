//
//  UIImage+VideoBuffer.swift
//  AR Video
//
//  Created by Ahmed Bekhit on 10/18/17.
//  Copyright © 2017 Ahmed Fathi Bekhit. All rights reserved.
//

import CoreVideo
import UIKit

extension UIImage
{
    func rotate(by degrees: CGFloat, flip: Bool? = nil) -> UIImage
    {
        let radians = CGFloat(degrees * (CGFloat.pi / 180.0))
        
        let bufferView = UIView(frame: CGRect(origin: CGPoint.zero, size: self.size))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: radians)
        bufferView.transform = t
        let bufferSize = bufferView.frame.size
        
        UIGraphicsBeginImageContextWithOptions(bufferSize, false, self.scale)
        let bitmap = UIGraphicsGetCurrentContext()
        bitmap?.translateBy(x: bufferSize.width / 2, y: bufferSize.height / 2)
        bitmap?.rotate(by: radians)
        if let isFlipped = flip {
            if !isFlipped {
                bitmap?.scaleBy(x: 1.0, y: -1.0)
            } else {
                bitmap?.scaleBy(x: -1.0, y: -1.0)
            }
        } else {
            bitmap?.scaleBy(x: -1.0, y: -1.0)
        }
        bitmap?.draw(self.cgImage!, in: CGRect(origin: CGPoint(x: -self.size.width / 2, y: -self.size.height / 2), size: self.size))
        
        let finalBuffer = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalBuffer!
    }
    
    var buffer: CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    func bufferAndClick(clipRect: CGRect, sholdClip: Bool) -> CVPixelBuffer? {
        if !sholdClip {
            return self.buffer
        }
        
        guard let img = self.cropping(to: clipRect) else {
            return self.buffer
        }
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(clipRect.size.width), Int(clipRect.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(clipRect.size.width), height: Int(clipRect.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: clipRect.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        img.draw(in: CGRect(x: 0, y: 0, width: clipRect.size.width, height: clipRect.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer

    }

}


extension UIImage {

    /// 截取图片的指定区域，并生成新图片
    /// - Parameter rect: 指定的区域
    func cropping(to rect: CGRect) -> UIImage? {
        let scale = UIScreen.main.scale
        let x = rect.origin.x * scale
        let y = rect.origin.y * scale
        let width = rect.size.width * scale
        let height = rect.size.height * scale
        let croppingRect = CGRect(x: x, y: y, width: width, height: height)
        // 截取部分图片并生成新图片
        guard let sourceImageRef = self.cgImage else { return nil }
        guard let newImageRef = sourceImageRef.cropping(to: croppingRect) else { return nil }
        let newImage = UIImage(cgImage: newImageRef, scale: scale, orientation: .up)
        return newImage
    }

}


extension UIImage {
    //将图片缩放成指定尺寸（多余部分自动删除）
    func scaled(to newSize: CGSize) -> UIImage {
        //计算比例
        let aspectWidth  = newSize.width/size.width
        let aspectHeight = newSize.height/size.height
        let aspectRatio = max(aspectWidth, aspectHeight)
        
        //图片绘制区域
        var scaledImageRect = CGRect.zero
        scaledImageRect.size.width  = size.width * aspectRatio
        scaledImageRect.size.height = size.height * aspectRatio
        scaledImageRect.origin.x    = 0
        scaledImageRect.origin.y    = 0
        
        //绘制并获取最终图片
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)//图片不失真
        draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    //将图片缩放成指定尺寸（多余部分自动删除）
    func scaled(to newSize: CGSize, origin: CGPoint) -> UIImage {
        //计算比例
        let aspectWidth  = newSize.width/size.width
        let aspectHeight = newSize.height/size.height
        let aspectRatio = max(aspectWidth, aspectHeight)
        
        //图片绘制区域
        var scaledImageRect = CGRect.zero
        scaledImageRect.size.width  = size.width * aspectRatio
        scaledImageRect.size.height = size.height * aspectRatio
        scaledImageRect.origin.x    = origin.x
        scaledImageRect.origin.y    = origin.y
        
        //绘制并获取最终图片
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)//图片不失真
        draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
}
