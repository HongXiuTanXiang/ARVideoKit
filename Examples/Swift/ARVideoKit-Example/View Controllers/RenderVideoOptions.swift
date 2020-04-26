//
//  ScreenRecorder.swift
//  SwiftDemo
//
//  Created by 李贺 on 2020/4/24.
//  Copyright © 2020 李贺. All rights reserved.
//

import Foundation
import UIKit

/// Allows specifying the final video orientation.
@objc public enum RenderFrameMode: Int {
    case aspectRatio16To9
}

/// Allows specifying the video rendering frame per second `FPS` rate.
@objc public enum RenderVideoFrameRate: Int {
    /// The framework automatically sets the most appropriate `FPS` based on the device support.
    case auto = 0
    /// Sets the `FPS` to 30 frames per second.
    case fps30 = 30
    /// Sets the `FPS` to 60 frames per second.
    case fps60 = 60
}

/// Allows specifying the final video orientation.
@objc public enum RenderVideoOrientation: Int {
    /// The framework automatically sets the video orientation based on the active `ARInputViewOrientation` orientations.
    case auto
    /// Sets the video orientation to always portrait.
    case alwaysPortrait
    /// Sets the video orientation to always landscape.
    case alwaysLandscape
}

/// Allows specifying when to request Microphone access.
@objc public enum RecordRenderMicrophonePermission: Int {
    /// The framework automatically requests Microphone access when needed.
    case auto
    /// Allows manual permission request.
    case manual
}

/// An object that returns the AR recorder current status.
@objc public enum RecordRenderStatus: Int {
    /// The current status of the recorder is unknown.
    case unknown
    /// The current recorder is ready to record.
    case readyToRecord
    /// The current recorder is recording.
    case recording
    /// The current recorder is paused.
    case paused
}

/// An object that returns the current Microphone status.
@objc public enum RecordRenderMicrophoneStatus: Int {
    // The current status of the Microphone access is unknown.
    case unknown
    // The current status of the Microphone access is enabled.
    case enabled
    // The current status of the Microphone access is disabled.
    case disabled
}

/// Allows specifying the accepted orientaions in a `UIViewController` with AR scenes.
@objc public enum RenderInputViewOrientation: Int {
    /// Enables the portrait input views orientation.
    case portrait = 1
    /// Enables the landscape left input views orientation.
    case landscapeLeft = 3
    /// Enables the landscape right input views orientation.
    case landscapeRight = 4
}

