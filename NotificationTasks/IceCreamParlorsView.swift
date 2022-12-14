//
//  IceCreamParlorView.swift
//  NotificationTasks
//
//  Created by Labtanza on 9/17/22.
//

import SwiftUI


struct IceCreamParlorsView: View {
        
    // These variables b/c of their property wrappers, persist
    // between inits. Any variables without a persisting wrapper will not.
        @State var showMe:Bool = false
        @StateObject var iceCreamVM = IceCreamParlorVM()

    init() {
        //print("IceCreamParlorsView Init")
    }
    
    var body: some View {
        HStack(alignment: .top) {
            ComingSoonView(storeName: "New York")
            ComingSoonView(storeName: "Philadelphia")
            VStack {
                Text(iceCreamVM.locationName).font(.title)
                Button("Show/Hide Store Details") { showMe.toggle() }
                if showMe {
                    StoreDetailsView().environmentObject(iceCreamVM)
                }
            }
            .padding()
            ComingSoonView(storeName: "Houston")
            ComingSoonView(storeName: "Chicago")
            //ComingSoonView(storeName: "Phoenix")
            
        }
    }
    
}

struct ComingSoonView: View {
    let storeName:String
    var body: some View {
        ZStack {
            Color.secondary
            VStack {
                Text(storeName)
                Text("coming soon")
            }
        }.padding()
    }
}


struct IceCreamParlorView_Previews: PreviewProvider {
    static var previews: some View {
        IceCreamParlorsView()
    }
}
