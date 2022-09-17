//
//  FlavorNotificationService.swift
//  NotificationTasks
//
//  Created by Labtanza on 9/17/22.
//

import Foundation


struct FlavorNotificationService {
    
    let notificationCenter = NotificationCenter.default
    let flavorSpecial = Notification.Name(rawValue: "special.message")
    let newFlavors = Notification.Name(rawValue: "special.message")
    

    var specialWatcher: some AsyncSequence  //How can I make this an AsyncSequence of FLAVORS?
    { NotificationInfoWatcher(
        name: flavorSpecial,
        center: notificationCenter,
        type: Flavor.self
    )
    }
    
    
    func watchForSpecial() async -> Flavor {
        do {
            for try await flavor in specialWatcher {
                return (flavor as? Flavor) ?? Flavor(name: "Suprise", description: "Local yummy")
            }
        } catch {
            
        }
        return Flavor(name: "Suprise", description: "Local yummy")
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
