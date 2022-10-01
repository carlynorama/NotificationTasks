//
//  FlavorModel.swift
//  AsyncPublisherTests
//
//  Created by Labtanza on 9/9/22.
//

import Foundation
import SwiftUI


struct Flavor:Identifiable {
    let name:String
    let id = UUID()
    let description:String
}

let flavors = [
    Flavor(name: "Vanilla", description: "Yummy"),
    Flavor(name: "Strawberry", description: "Yummy"),
    Flavor(name: "Chocolate", description: "Yummy"),
    Flavor(name: "Butter Pecan", description: "Yummy"),
    Flavor(name: "Mint Chocolate Chip", description: "Yummy"),
    Flavor(name: "Orange Sherbert", description: "Yummy"),
    Flavor(name: "Rocky Road", description: "Yummy"),
    Flavor(name: "Lemon Sorbet", description: "Yummy"),
    Flavor(name: "Cookie Dough", description: "Yummy"),
    Flavor(name: "Fudge Ripple", description: "Yummy"),
]


actor FlavorManager {
    let notificationService = FlavorNotificationService()
    
    //for publisher paradigm
    @MainActor @Published var availableFlavors:[Flavor] = [] {
        didSet {
            //not named and filed b/c should be allowed to finish. 
            Task { await updateFlavors(to: availableFlavors) }
        }
    }
    
    //For notification service paradigm
    var unpublishedFlavorsExample:[Flavor] = []
    
    func updateFlavors(to flavors:[Flavor]) {
        unpublishedFlavorsExample = flavors
        notificationService.postUpdatedFlavorsNotification(object:self)
    }
    
    
    var currentSpecial:Flavor = Flavor(name: "Apple Pie", description: "Seasonal Yummy") {
        didSet {
            notificationService.postNewSpecial(currentSpecial, object:self)
        }
    }
    
    
    //Should I be running?
    private(set) var checkingForUpdates:Bool = true
    
    //Am I running?
    @MainActor @Published var flavorUpdatesCount = 0
    
    
    //MARK: - Mock Data Creation, in a real set up would be getting from server.
    func generateSpecials() async {
        //Start the task.
        let  randomSpecialFlavorUpdates = Task {
            await specialFlavorsEngine()
        }
        
        //Put the task under management.
        await updateManagedTasks(randomSpecialFlavorUpdates)
    }
    
    func generateAvailable() async {
        //Start the task.
        let randomAvailable = Task {
            await availableFlavorsEngine()
        }
        
        //Put the task under management.
        await updateManagedTasks(randomAvailable)
    }
    
    
    func availableFlavorsEngine() async {
        while checkingForUpdates {
            await MainActor.run { availableFlavors = Array(flavors.shuffled().prefix(5)) }
            //await print("New Flavors:", availableFlavors)
            try? await  Task.sleep(nanoseconds: 6_000_000_000)
        }
        print("availableFlavors loop done.")
        printTasks()
    }
    
    func specialFlavorsEngine() async {
        while checkingForUpdates {
            currentSpecial = flavors.randomElement() ?? Flavor(name: "Apple Pie", description: "Seasonal Yummy")
            await MainActor.run  { flavorUpdatesCount += 1 }
            //print("New Special:", currentSpecial.name)
            try? await  Task.sleep(nanoseconds: 4_000_000_000)
        }
        print("specialFlavors loop done.")
        printTasks()
    }
    
    //MARK: - Scene Change Handler
    public func updateMode(scenePhase:ScenePhase) async {
        print(scenePhase)
        switch (scenePhase) {
        
        case .background:
            checkingForUpdates = false
            cancelManagedTasks()
            printTasks()
        case .inactive:
            checkingForUpdates = false
            cancelManagedTasks()
            printTasks()
        case .active:
            checkingForUpdates = true
            await generateSpecials()
            await generateAvailable()
            printTasks()
        @unknown default:
            checkingForUpdates = false
            cancelManagedTasks()
            printTasks()
        }
    }
    
    //MARK: - Task Management
    
    //Arrays hold onto values strongly.
    //Must delete canceled tasks mannually or design a weak Collection type.
    //https://stackoverflow.com/a/60707942/5946596
    //https://stackoverflow.com/a/70791320/5946596
    private var unstructuredTasks:[Task<(), Never>] = []
    
    func updateManagedTasks(_ task:Task<(), Never>) async {
        unstructuredTasks.append(task)
    }
    
    func cancelManagedTasks() {
        for task in unstructuredTasks {
            task.cancel()
        }
        deleteCancelledTasks()
    }
    
    func deleteCancelledTasks() {
        unstructuredTasks.removeAll(where: { $0.isCancelled })
    }
    
    func printTasks() {
        for (i, task) in unstructuredTasks.enumerated() {
            print(task, "at Number: \(i), isCancelled: \(task.isCancelled)")
        }
    }
    
}

