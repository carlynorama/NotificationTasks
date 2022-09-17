//
//  NotificationService.swift
//  NotificationTasks
//
//  Created by Labtanza on 9/13/22.
//
// https://developer.apple.com/documentation/foundation/nsnotification/name

import Foundation
import SwiftUI

//extension Notification.Name {
//
//    static let MySpecialNotification = Notification.Name("MySpecialNotification")
//
//}


final class NotificationService {
    let notificationCenter = NotificationCenter.default
    
    let messageNotificationName = Notification.Name(rawValue: "special.message")
    
    private var flipObserver:NSObjectProtocol?
    private var messageObserver:NSObjectProtocol?
    
    //Does this need to be weak? Does everyone need to resign?
    private var observers:[NSObjectProtocol] = []
    
    init () {
        setFlipObserver()
        setCustomMessageObserver()
    }
    
    private func setFlipObserver() {
        flipObserver = NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil, queue: nil) { [weak self] notification in   //if Service becomes a class ?
                print(notification)
                self?.orientationChanged(notification: notification)
            }
    }
    
    private func setCustomMessageObserver() {
        messageObserver = NotificationCenter.default.addObserver(
            forName: messageNotificationName,
            object: nil, queue: nil) { [weak self] notification in
                print(notification)
                self?.recievedMessage(notification: notification)
            }
    }
    
    deinit {
        if let flipObserver {
            notificationCenter.removeObserver(flipObserver)
            print("removed \(flipObserver.description)")
        }
        
        if let messageObserver {
            notificationCenter.removeObserver(messageObserver)
            print("removed \(messageObserver.description)")
        }
        
        for observer in observers {
            notificationCenter.removeObserver(observer)
            print("removed \(observer.description)")
        }
    }
    
    func publishMessage(_ message:String) {
        notificationCenter.post(name: messageNotificationName, object: nil, userInfo: ["myMessage":message])
    }
    
    func orientationChanged(notification: Notification) {
        print("Whoopsie Daisy")
    }
    
    func recievedMessage(notification: Notification) {
        if let message:String = notification.object as? String {
            print("recieved message: \(message)")
        }
    }

    //An example.
    func addObserver(forName name:NSNotification.Name?, object:Any?, queue: OperationQueue?, using: @escaping (Notification) -> Void) {
        let newObserver = notificationCenter.addObserver(
            forName: name, //e.g.  .batteryLevelDidChangeNotification,
            object: object,  // The object that sends notifications to the observer block.  a Notifier Class
            queue: queue,  // e.g. NSOperationQueue.mainQueue()
            using: using)  //  e.g. {}
        observers.append(newObserver)
    }
    
}

extension NotificationService {
    var flipWatcher:some AsyncSequence
    { NotificationWatcher(
        name: UIDevice.orientationDidChangeNotification,
        center: notificationCenter)
    }
    
//    var messageWatcher: some AsyncSequence
//    { NotificationObjectWatcher(
//        name: messageNotificationName,
//        center: notificationCenter,
//        type: String.self
//    )
//    }

    var messageWatcher: some AsyncSequence
    { NotificationInfoWatcher(
        name: messageNotificationName,
        center: notificationCenter,
        key: "myMessage",
        type: String.self
    )
    }
    
    
    func watchForFlip() async {
        do {
            for try await notification in flipWatcher {
                print("notification:\(notification)")
            }
        } catch {
            
        }
    }
    
    func watchForMessage(_ continuation:(String) -> Void) async {
        do {
            for try await object in messageWatcher {
                print("message:\(object)")
                
                if let s = object as? String{
                    continuation(s)
                }
                
            }
        } catch {
            
        }
    }
    
//    func makeWatcher<Object>(for name:Notification.Name, ofType object:Object) -> some AsyncSequence {
//        NotificationObjectWatcher(name: name, center: notificationCenter, object: Object.self)
//    }
//    
//    func makeFlipWatcher() -> AsyncStream<UIDeviceOrientation> {
//        makeWatcher(for: UIDevice.orientationDidChangeNotification, ofType: UIDeviceOrientation.self) as! AsyncStream<UIDeviceOrientation>
//    }
    
}

//    func notifications(
//        named name: Notification.Name,
//        object: AnyObject? = nil
//    ) -> NotificationCenter.Notifications

//    let observer = NotificationCenter.default.addObserver(
//        forName: NSNotification.Name.UIDeviceBatteryLevelDidChange,
//        object: nil, queue: nil,
//        using: batteryLevelChanged)
//
//    let observer = NotificationCenter.default.addObserver(
//            forName: NSNotification.Name.UIDeviceBatteryLevelDidChange,
//            object: nil, queue: nil) { _ in print("🔋") }
//
//    NotificationCenter.default.removeObserver(observer)
    
//    let center = NSNotificationCenter.defaultCenter()
//    let mainQueue = NSOperationQueue.mainQueue()
//    var token: NSObjectProtocol?
//    token = center.addObserverForName("OneTimeNotification", object: nil, queue: mainQueue) { (note) in
//        print("Received the notification!")
//        center.removeObserver(token!)
//    }


