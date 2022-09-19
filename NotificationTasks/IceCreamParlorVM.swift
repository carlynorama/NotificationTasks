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
    

    
    //Note, this is not really a reccomended way if you actually have model, hanging out as the real source of truth.
    public func watchForSpecial() async {
        do {
            for try await flavor in flavorNotificationService.specialWatcher {
                print("IPVM, wfS: got", flavor)
                    thisWeeksSpecial = (flavor as? Flavor) ?? Flavor(name: "Suprise", description: "Local yummy")
                    lastUpdate = Date.now
            }
        } catch {

        }
    }
    
    //When manager.$availableFlavors is published
    public func listenForFlavorList() async {
        defer { print("IPVM, lfFL:How about defer?") }
        //uard let manager = manager else { return }
        for await value in await manager.$availableFlavors.values {
            await MainActor.run { //[weak self] in
                self.available = value
            }
                    
        }
    }
    
    public func updateFlavorsOnNotificationPing() async {
        if available.isEmpty {
            await fetchFlavorsFromManager()
        }
        do {
            for try await _ in flavorNotificationService.avaibleFlavorsWatcher {
                await fetchFlavorsFromManager()
            }
        } catch {

        }
    }
        func fetchFlavorsFromManager() async {
            let pendingAvailable = await manager.unpublishedFlavorsExample
            await MainActor.run {
                available = pendingAvailable
            }
            print("IPVM, fffM: finished flavors fetch")
            lastUpdate = Date.now
        }
    
}


