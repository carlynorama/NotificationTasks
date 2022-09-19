//
//  IceCreamParlorViewModel.swift
//  NotificationTasks
//
//  Created by Labtanza on 9/17/22.
//

import Foundation


@MainActor
class IceCreamParlorVM:ObservableObject {
    var manager = Services.flavorManager
    let flavorNotificationService = FlavorNotificationService()
    @Published var available: [Flavor] = []
    @Published var thisWeeksSpecial:Flavor = Flavor(name: "Suprise", description: "Local yummy")
    @Published var lastUpdate:Date = Date.now
    
    var updateCount:Int {
        manager.flavorUpdatesCount
    }
    
    deinit {
        print("IceCreamParlorVM deinit check")
    }
    
//    func fetchFlavorsFromManager() async {
//        let pendingAvailable = await manager.availableFlavors
//        await MainActor.run {
//            available = pendingAvailable
//        }
//        print("finished flavors fetch")
//        lastUpdate = Date.now
//    }
    
    //Note, this is not really a reccomended way if you actually have model, hanging out as the real source of truth.
    public func watchForSpecial() async {
        do {
            for try await flavor in flavorNotificationService.specialWatcher {
                print("got", flavor)
                    thisWeeksSpecial = (flavor as? Flavor) ?? Flavor(name: "Suprise", description: "Local yummy")
                    lastUpdate = Date.now
            }
        } catch {

        }
    }
    
    public func listenForFlavorList() async {
        defer { print("IFVM, lfFL:How about defer?") }
        //uard let manager = manager else { return }
        for await value in await manager.$availableFlavors.values {
            await MainActor.run { //[weak self] in
                self.available = value
            }
                    
        }
    }
    
}


