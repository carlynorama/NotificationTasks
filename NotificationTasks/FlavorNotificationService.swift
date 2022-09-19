//
//  FlavorNotificationService.swift
//  NotificationTasks
//
//  Created by Labtanza on 9/17/22.
//

import Foundation


struct FlavorNotificationService {
    
   private let notificationCenter = NotificationCenter.default
    private let flavorSpecial = Notification.Name(rawValue: "flavorSpecial")
    private let flavorSpecialKey = "flavorSpecial"
    
    private let newFlavors = Notification.Name(rawValue: "thisWeeksFlavors")

    var specialWatcher: some AsyncSequence  //How can I make this an AsyncSequence of FLAVORS?
    { NotificationInfoWatcher(
        name: flavorSpecial,
        center: notificationCenter,
        type: Flavor.self
    )
    }
    
    public func postNewSpecial(_ special:Flavor, object:Any? = nil) {
        notificationCenter.post(name: flavorSpecial, object: object ?? self, userInfo: [flavorSpecialKey : special])
    }
    
//    public func watchForSpecial() async -> Flavor {
//        do {
//            for try await flavor in specialWatcher {
//                return (flavor as? Flavor) ?? Flavor(name: "Suprise", description: "Local yummy")
//            }
//        } catch {
//            
//        }
//        return Flavor(name: "Suprise", description: "Local yummy")
//    }
    
    public func postUpdatedFlavorsNotification(object:Any? = nil) {
        notificationCenter.post(name:newFlavors, object: object ?? self)
    }
    
//    func watchForMessage(_ continuation:(String) -> Void) async {
//        do {
//            for try await object in messageWatcher {
//                print("message:\(object)")
//
//                if let s = object as? String{
//                    continuation(s)
//                }
//
//            }
//        } catch {
//
//        }
//    }
}
