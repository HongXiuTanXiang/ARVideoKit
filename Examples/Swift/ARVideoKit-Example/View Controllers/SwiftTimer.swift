//
//  SwiftTimer.swift
//  DuFoundation
//
//  Created by 刘立夫 on 2019/7/30.
//  Copyright © 2019 DuApp. All rights reserved.
//

import Foundation

public class SwiftTimer {
    private let internalSourceTimer: DispatchSourceTimer
    private var isRunning = false
    public let repeats: Bool
    private var handler: (SwiftTimer) -> Void
    
    public init(interval: DispatchTimeInterval,
                repeats: Bool = false,
                leeway: DispatchTimeInterval = .seconds(0),
                queue: DispatchQueue = .main ,
                handler: @escaping (SwiftTimer) -> Void) {
        self.handler = handler
        self.repeats = repeats
        internalSourceTimer = DispatchSource.makeTimerSource(queue: queue)
        internalSourceTimer.setEventHandler { [weak self] in
            guard let wSelf = self else { return }
            handler(wSelf)
        }
        
        if repeats {
            internalSourceTimer.schedule(deadline: .now() + interval, repeating: interval, leeway: leeway)
        } else {
            internalSourceTimer.schedule(deadline: .now() + interval, leeway: leeway)
        }
    }
    
    public func fire() {
        if repeats {
            handler(self)
        } else {
            handler(self)
            internalSourceTimer.cancel()
        }
    }
    
    public func start() {
        if !isRunning {
            internalSourceTimer.resume()
            isRunning = true
        }
    }
    
    public func suspend() {
        if isRunning {
            internalSourceTimer.suspend()
            isRunning = false
        }
    }
    
    deinit {
        if !self.isRunning {
            internalSourceTimer.resume()
        }
    }
}

