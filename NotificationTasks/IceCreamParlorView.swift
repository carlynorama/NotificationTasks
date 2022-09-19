//
//  IceCreamParlorView.swift
//  NotificationTasks
//
//  Created by Labtanza on 9/17/22.
//

import SwiftUI


struct IceCreamParlorView: View {
        @State var showMe:Bool = false
        @StateObject var iceCreamVM = IceCreamParlorVM()

        
        var body: some View {
            VStack {
                Button("Toggle View") { showMe.toggle() }
                if showMe {
                    StoreView().environmentObject(iceCreamVM)
                }
            }
            .padding()
        }
    
}

struct IceCreamParlorView_Previews: PreviewProvider {
    static var previews: some View {
        IceCreamParlorView()
    }
}
