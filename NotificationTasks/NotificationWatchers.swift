//
//  NotificationWatcher.swift
//  NotificationTasks
//
//  Created by Labtanza on 9/16/22.
//

import Foundation
import SwiftUI


public struct NotificationWatcher: AsyncSequence, AsyncIteratorProtocol {
    
    public typealias Element = Notification
    
    let name:Notification.Name
    let center:NotificationCenter
    
    public init(name: Notification.Name, center: NotificationCenter) {
        self.name = name
        self.center = center
    }
    
    private var isActive = true
    
    public mutating func next() async throws -> Element? {
        guard isActive else { return nil }
        let sequence = center.notifications(named: name)
        
        for await notification in sequence {
            return notification
        }
        return nil
    }
    
    public func makeAsyncIterator() -> NotificationWatcher {
        self
    }
}

public struct NotificationObjectWatcher<Element>: AsyncSequence, AsyncIteratorProtocol {
    
    let name:Notification.Name
    let center:NotificationCenter
    
    public init(name: Notification.Name, center: NotificationCenter, type: Element.Type) {
        self.name = name
        self.center = center
    }
    
    private var isActive = true
    
    mutating public func next() async throws -> Element? {
        guard isActive else { return nil }
        let sequence = center.notifications(named: name).compactMap { notification in
            notification.object as? Element
        }
        
        for await object in sequence {
            //print("what did I get?:\(object)")
            return object
        }
        return nil
    }
    
    public func makeAsyncIterator() -> NotificationObjectWatcher {
        self
    }
}
