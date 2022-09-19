//
//  WelcomeView.swift
//  NotificationTasks
//
//  Created by Labtanza on 9/17/22.
//

import SwiftUI



struct WelcomeView: View {
    
    @State var showMe:Bool = false
    
    let notificationCenter = FlavorNotificationService()
    
    @State var specialUpdateTime:Date = Date.now
    @State var availbeUpdateTime:Date = Date.now
    
    @State var specialCallOut:String = ""
    
    var body: some View {
        VStack {
            Text("Welcome View")
            Text("New Flavors: \(availbeUpdateTime.formatted(date: .abbreviated, time: .standard))")
            Text("New Special: \(specialUpdateTime.formatted(date: .abbreviated, time: .standard))")
            Text("Special Name: \(specialCallOut)")
            Button("Toggle Parlor View") { showMe.toggle() }
            if showMe {
                IceCreamParlorView().border(.blue)
            }
        }
        .padding()
        .task {
            await watchSpecial()
        }
        .task {
            await watchAvailable()
        }
        .task {
            await notificationCenter.specialHandler { flavor in
                specialCallOut = flavor.name
            }
        }
        
    }
    
    func watchSpecial() async {
                do {
                    for try await _ in notificationCenter.specialWatcher {
                        specialUpdateTime = Date.now
                    }
                } catch {
        
                }
    }
    
    func watchAvailable() async {
        do {
            for try await _ in notificationCenter.avaibleFlavorsWatcher {
                availbeUpdateTime = Date.now
            }
        } catch {

        }
    }

}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
