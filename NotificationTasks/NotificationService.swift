//
//  NotificationService.swift
//  NotificationTasks
//
//  Created by Labtanza on 9/13/22.
//

import Foundation
import SwiftUI

extension Notification.Name {

    static let MySpecialNotification = Notification.Name("MySpecialNotification")

}


final class NotificationService {
    let notifiationCenter = NotificationCenter.default
    
    let messageNotificationName = Notification.Name(rawValue: "special.message")
    private var observer:NSObjectProtocol?
    
    private var observer2:NSObjectProtocol?
    
    private var observers:[NSObjectProtocol] = []
    
    init () {
        setFlipObserver()
        setCustomMessageObserver()
    }
    
    func setFlipObserver() {
        observer = NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil, queue: nil) { [weak self] notification in   //if Service becomes a class ?
               print(notification)
                self?.orientationChanged(notification: notification)
            }
    }
    
    func setCustomMessageObserver() {
        observer2 = NotificationCenter.default.addObserver(
            forName: messageNotificationName,
            object: nil, queue: nil) { [weak self] notification in
               print(notification)
                self?.recievedMessage(notification: notification)
            }
    }
    
    deinit {
        if let observer {
            notifiationCenter.removeObserver(observer)
            print("removed 1")
        }
        
        if let observer2 {
            notifiationCenter.removeObserver(observer2)
            print("removed 2")
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
    
    func addObserver() {
       let newObserver = notifiationCenter.addObserver(
            forName: UIDevice.orientationDidChangeNotification,///.batteryLevelDidChangeNotification,
            object: nil, queue: nil,
            using: batteryLevelChanged)
        observers.append(newObserver)
    }

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



