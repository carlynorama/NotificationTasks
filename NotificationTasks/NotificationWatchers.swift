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


//OBJECT in this context is the SENDER returns the sender
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
            //note this filters out nil responses which will prevent this seqiuence from
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


//Information send by a notification is in the UserInfo dictionary.
public struct NotificationInfoWatcher<Element>: AsyncSequence, AsyncIteratorProtocol {
    
    let name:Notification.Name
    let center:NotificationCenter
    let keyString:String?
    
    public init(name: Notification.Name, center: NotificationCenter, keyString:String? = nil, type: Element.Type) {
        self.name = name
        self.center = center
        self.keyString = keyString
    }
    
    private var isActive = true
    
    mutating public func next() async throws -> Element? {
        guard isActive else { return nil }
        let keyS = self.keyString
        let sequence = center.notifications(named: name).compactMap { notification in
            //note this filters out nil responses which will prevent this seqiuence from
            //terminating.
            if let keyS {
                return notification.userInfo?[keyS] as? Element
            } else {
                let values = notification.userInfo?.values
                //values.first as? Element
                if let values {
                    for value in values {
                        if let item = value as? Element {
                            return item
                        }
                    }
                }
            }
            return nil
        }
        
        for await object in sequence {
            //print("what did I get?:\(object)")
            return object
        }
        return nil
    }
    
    public func makeAsyncIterator() -> NotificationInfoWatcher {
        self
    }
}

