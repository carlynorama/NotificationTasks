//
//  FlipWatcer.swift
//  NotificationTasks
//
//  Created by Labtanza on 9/15/22.
//

import Foundation
import SwiftUI


struct FlipWatcher: AsyncSequence, AsyncIteratorProtocol {
    typealias Element = UIDeviceOrientation
    
    private var isActive = true
    
    mutating func next() async throws -> Element? {
        guard isActive else { return nil }
        let sequence = await NotificationCenter.default.notifications(named: UIDevice.orientationDidChangeNotification)
            .map { _ in await UIDevice.current.orientation }
        
        for await orientation in sequence {
            print("\(orientation)")
            return orientation
        }
        return nil
    }
    
    func makeAsyncIterator() -> FlipWatcher {
        self
    }
    
    
}
