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
    
    var body: some View {
        VStack {
            Text("Welcome View")
            Text("New Flavors: \(availbeUpdateTime.formatted(date: .abbreviated, time: .standard))")
            Text("New Special: \(specialUpdateTime.formatted(date: .abbreviated, time: .standard))")
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
    
//    func opacity(_ date:Date) -> Double {
//        let dif = Double(date.timeIntervalSince(Date.now))
//        if dif > 10.0 {
//            return 0.0
//        } else {
//            return max(1 - dif/100, 0)
//        }
//    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
