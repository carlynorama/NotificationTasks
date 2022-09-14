//
//  ContentView.swift
//  NotificationTasks
//
//  Created by Labtanza on 9/13/22.
//

import SwiftUI

struct ContentView: View {

    
    @State var showMe:Bool = false
    
    var body: some View {
        VStack {
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
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            Button("Post Message") {
                notificationService.publishMessage("Hello")
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
