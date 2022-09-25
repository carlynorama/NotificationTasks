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
    
    @State var yourStore:String = "Los Angeles"

    @State var specialCallOut:String = ""
    
    init() {
        print("Welcome view Init")
    }
    
    var body: some View {
        
        VStack(alignment:.leading) {
            
            Text("Welcome View").font(.largeTitle)
            Text("Your Store: \(yourStore)")
            
            HStack(alignment: .firstTextBaseline) {
                Text ("Latest from Your Store:")
                Spacer()
                VStack(alignment: .leading) {
                    Text("We got a new flavor!")
                    Text("\(specialCallOut)").font(.headline)
                    Text("\(specialUpdateTime.formatted(.relative(presentation: .numeric)))")
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Available flavors were updated:")
                    Text("\(availbeUpdateTime.formatted(.relative(presentation: .named)))")
                }
                
            }.padding()
                .border(.blue)
            
            //            Text("New Flavors: \(availbeUpdateTime.formatted(date: .abbreviated, time: .standard))")
            //            Text("New Special: \(specialUpdateTime.formatted(date: .abbreviated, time: .standard))")
            
            
            Group {
                Button("Show/Hide Stores") { showMe.toggle() }
                if showMe {
                    IceCreamParlorsView()
                    ComparisonView()
                }
                Spacer()
                
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
