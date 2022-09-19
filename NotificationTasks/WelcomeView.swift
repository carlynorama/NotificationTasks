//
//  WelcomeView.swift
//  NotificationTasks
//
//  Created by Labtanza on 9/17/22.
//

import SwiftUI



struct WelcomeView: View {
    
    @State var showMe:Bool = false
    
    
    var body: some View {
        VStack {
            Text("Welcome View")
            Button("Toggle Parlor View") { showMe.toggle() }
            if showMe {
                IceCreamParlorView().border(.blue)
            }
        }
        .padding()
    }
    
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
