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
    
    private var listen:Task<(), Never>?
    private(set) var listening:Bool = false
    
    var updateCount:Int {
        manager.flavorUpdatesCount
    }
    
    init() {
        //setUp()
    }
    
    deinit {
        print("IceCreamParlorVM deinit check")
    }
    
    func setUp()  {
        Task {
            await fetchFlavorsFromManager()
        }
        
        Task { @MainActor in
            let special = await manager.currentSpecial
            thisWeeksSpecial = special
            lastUpdate = Date.now
            print("finished special fetch")
        }
        
        initializePersistantListener()
    }
    
    func initializePersistantListener() {
        listening = true
        listen = Task {
            await watchForSpecial()
        }
        
    }
    
    func casualSetUp() async {
        Task {
            await fetchFlavorsFromManager()
        }
        
        Task {
            let special = await manager.currentSpecial
            thisWeeksSpecial = special
            lastUpdate = Date.now
            print("finished special fetch")
        }

        await watchForSpecial()
    
    }
    
    func tearDown() {
        if let listen {
            listen.cancel()
            listening = false
        }
    }
    
    
    func fetchFlavorsFromManager() async {
        let pendingAvailable = await manager.availableFlavors
        await MainActor.run {
            available = pendingAvailable
        }
        print("finished flavors fetch")
        lastUpdate = Date.now
    }
    
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
    
}


