//
//  InsistantPopover.swift
//  AsyncPublisherTests
//
//  Created by Labtanza on 9/9/22.
//

import Foundation
import SwiftUI


struct InsistantFlavorsView: View {
    //there is a task creator IN THE INIT of this VM. The tasks will last with the VM or longer. Watch for leaks.
    @EnvironmentObject private var viewModel:InsistantFlavorVM
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack {
            Text(viewModel.thisWeeksSpecial)
            ScrollView {
                VStack {
                    ForEach(viewModel.flavorsToDisplay) {
                        Text($0.name)
                    }
                }
            }
        }
        .task {
            print(scenePhase)
        }
        //Each must be its own seperate task to run concurently.

        .task {
            //This runs it's defer on view dismiss.
            await viewModel.listenForFlavorOfTheWeek()
        }
    }


}

struct InsistantFlavorsView_Previews: PreviewProvider {
    static var previews: some View {
        InsistantFlavorsView().environmentObject(InsistantFlavorVM())
    }
}


class InsistantFlavorVM:ObservableObject {
    @MainActor @Published var flavorsToDisplay: [Flavor] = []
    @MainActor @Published var thisWeeksSpecial:String = ""
    
    
    //var observers: [IndexPath: Task<Void, Never>] = [:]
    

    //I believe the awaiting on its @Published will keep this
    //instance alive? And then therefore the calling IFVM alive.
    //Tasks run in background, YAY! But is this a memory leak?
    //What if I DON'T want it to run on the background.
    // can this be weak? it needs to also have a task killer?
    //weak var manager:FlavorManager?
    
    let manager = FlavorManager()
    var dataAdder:Task<(), Never>?
    var watcher:Task<(), Never>?
    
    @MainActor @Published var showMe:Bool = false
    @MainActor @Published var acceptingAlerts = false

    init() {
        print("background hello")
        
        //self.manager = manager
        
        //spinning up tasks in the init of a ViewModel instead of the
        //view means they will likely persist for longer than the view.
        //inside the listen function set the instance variable instead.
        
        listen()
    }
    
    deinit {
        print("never say goodbye...")
    }
    
    


    //Who owns tasks called here? Who kills them?
    private func listen() {
        //One cannot put one loop after another. Each loop needs
        //it's own task.
        //Use this pattern if you want the task to have to complete.
        //They appear to run even when App is in the background.
        
        //Note: Assigning a task to a variable does not "save it for later"
        //this task starts running now.
        dataAdder = Task { await manager.slowAddData() }

        
        //Not sure weak self actually does anything here.
        watcher = Task { [weak self] in
            //This DOES NOT run its defer on view dismiss.
            await self?.listenForFlavorList()
            //No code here will execute because this function never
            //finishes.
        }

    }
    
//    //moving this to the VM didn't change leak.
//    func slowAddData() async {
//        for flavor in flavors {
//            await manager.append(flavor: flavor)
//            try? await  Task.sleep(nanoseconds: 4_000_000_000)
//            await manager.updateCurrent(flavor: flavor)
//        }
//    }
//
    
    
    public func tearDown() {
        dataAdder?.cancel()
        watcher?.cancel()
        
    }
    
    public func listenForFlavorOfTheWeek() async {
        defer { print("IFVM, lfFtW:How about defer?") }
        //guard let manager = manager else { return }
        for await value in await manager.$currentFlavor.values {
            await MainActor.run { //[weak self] in
                self.thisWeeksSpecial = "\(value.name): \(value.description)"
            }
        }
    }

    public func listenForFlavorList() async {
        defer { print("IFVM, lfFL:How about defer?") }
        //uard let manager = manager else { return }
        for await value in await manager.$myFlavors.values {
            await MainActor.run { //[weak self] in
                if self.acceptingAlerts {
                    self.showMe = true
                }
                self.flavorsToDisplay = value
            }
                    
        }
    }
    
    
}


