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
    
    func cropImage(to rect: CGRect) -> UIImage? {
        let originalsize = self.size
        //原图长宽均小于标准长宽的，不作处理返回原图
        let clipSize = rect.size
        
        if originalsize.width < clipSize.width && originalsize.height < clipSize.height  {
            return self
        } else if originalsize.width > clipSize.width && originalsize.height > clipSize.height {
            //原图长宽均大于标准长宽的，按比例缩小至最大适应值
            var rate:CGFloat = 1.0
            let widthRate = originalsize.width / clipSize.width
            let heightRate = originalsize.height / clipSize.height
            if widthRate > heightRate {
                rate = heightRate
            } else {
                rate = widthRate
            }
            var imageRef: CGImage? = nil
            
            if (heightRate>widthRate) {
                imageRef = self.cgImage?.cropping(to: CGRect.init(x: 0, y: originalsize.height/2-clipSize.height*rate/2, width: originalsize.width, height: clipSize.height*rate))
            } else {
                imageRef = self.cgImage?.cropping(to: CGRect.init(x: originalsize.width/2-clipSize.width*rate/2, y: 0, width: clipSize.width*rate, height: originalsize.height))
            }
            
            guard let cgimg = imageRef else {
                return self
            }
            
            UIGraphicsBeginImageContext(clipSize)
            let context = UIGraphicsGetCurrentContext()
            context?.translateBy(x: 0.0, y: clipSize.height)
            context?.scaleBy(x: 1.0, y: -1.0)
            context?.draw(cgimg, in: CGRect.init(x: 0, y: 0, width: clipSize.width, height: clipSize.height))
            let standardImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return standardImage
        } else if originalsize.height>clipSize.height || originalsize.width>clipSize.width {
            //原图长宽有一项大于标准长宽的，对大于标准的那一项进行裁剪，另一项保持不变
            var imageRef: CGImage? = nil
            
            if(originalsize.height > clipSize.height)
            {
                imageRef = self.cgImage?.cropping(to: CGRect.init(x: 0, y: 0, width: originalsize.width, height: clipSize.height))
            }
            else if (originalsize.width > clipSize.width)
            {
                imageRef = self.cgImage?.cropping(to: CGRect.init(x: originalsize.width/2-clipSize.width/2, y: 0, width: clipSize.width, height: originalsize.height))
            }
            
            guard let cgimg = imageRef else {
                return self
            }
            UIGraphicsBeginImageContext(clipSize)
            let context = UIGraphicsGetCurrentContext()
            context?.translateBy(x: 0.0, y: clipSize.height)
            context?.scaleBy(x: 1.0, y: -1.0)
            context?.draw(cgimg, in: CGRect.init(x: 0, y: 0, width: clipSize.width, height: clipSize.height))
            let standardImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return standardImage
        } else {
            //原图为标准长宽的，不做处理
            return self
        }
    }


}
