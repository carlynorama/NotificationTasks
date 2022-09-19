//
//  ContentView.swift
//  NotificationTasks
//
//  Created by Labtanza on 9/13/22.
//

import SwiftUI

struct ScratchPadView: View {

    
    @State var showMe:Bool = false
    
    var body: some View {
        VStack {
            ComparisonContainerView()
            Button("Toggle View") { showMe.toggle() }
            if showMe {
                NotificationView()
            }
        }
        .padding()
    }
}

struct NotificationView: View {
    var notificationService = NotificationService()
    
    @State var messageDisplay:String = "Hello, world!"
    
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text(messageDisplay)
            Button("Post Message") {
                notificationService.publishMessage("Hello")
            }
            Button("Sloppy Message") {
                notificationService.sloppyMessage("Can you hear me?")
            }
        }
        .padding()
        .task {
            await notificationService.watchForFlip()
        }
        .task {
            await notificationService.watchForMessage() { message in
                messageDisplay = message
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ScratchPadView()
    }
}
