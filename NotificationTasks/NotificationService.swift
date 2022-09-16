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
    let notifiationCenter = NotificationCenter.default
    
    let messageNotificationName = Notification.Name(rawValue: "special.message")
    
    private var flipObserver:NSObjectProtocol?
    private var messageObserver:NSObjectProtocol?
    
    //Does this need to be weak? Does everyone need to resign?
    private var observers:[NSObjectProtocol] = []
    
    init () {
        setFlipObserver()
        setCustomMessageObserver()
    }
    
    func setFlipObserver() {
        flipObserver = NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil, queue: nil) { [weak self] notification in   //if Service becomes a class ?
               print(notification)
                self?.orientationChanged(notification: notification)
            }
    }
    
    func setCustomMessageObserver() {
        messageObserver = NotificationCenter.default.addObserver(
            forName: messageNotificationName,
            object: nil, queue: nil) { [weak self] notification in
               print(notification)
                self?.recievedMessage(notification: notification)
            }
    }
    
    deinit {
        if let flipObserver {
            notifiationCenter.removeObserver(flipObserver)
            print("removed \(flipObserver.description)")
        }
        
        if let messageObserver {
            notifiationCenter.removeObserver(messageObserver)
            print("removed \(messageObserver.description)")
        }
        
        for observer in observers {
            notifiationCenter.removeObserver(observer)
            print("removed \(observer.description)")
        }
    }
    
    func publishMessage(_ message:String) {
        notifiationCenter.post(name: messageNotificationName, object: message)
    }
    
    func batteryLevelChanged(notification: Notification) {
        // do something useful with this information
    }
    
    func orientationChanged(notification: Notification) {
        print("Whoopsie Daisy")
    }
    
    func recievedMessage(notification: Notification) {
        if let message:String = notification.object as? String {
            print("recieved message: \(message)")
        }
    }
    
    func addObserver(forName name:NSNotification.Name?, object:Any?, queue: OperationQueue?, using: @escaping (Notification) -> Void) {
       let newObserver = notifiationCenter.addObserver(
            forName: name,///.batteryLevelDidChangeNotification,
            object: object, queue: queue,
            using: using)
        observers.append(newObserver)
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
}



