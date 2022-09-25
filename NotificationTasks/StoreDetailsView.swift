//
//  InsistantPopover.swift
//  AsyncPublisherTests
//
//  Created by Labtanza on 9/9/22.
//

import Foundation
import SwiftUI


struct StoreDetailsView: View {
    //there is a task creator IN THE INIT of this VM. The tasks will last with the VM or longer. Watch for leaks.
    @EnvironmentObject private var viewModel:IceCreamParlorVM
    

    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.thisWeeksSpecial.name)
            Text("Updated \(viewModel.updateCount) times")
            
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(viewModel.available) {
                        Text($0.name)
                    }
                }
            }
        }.task {
            await viewModel.watchForSpecial()
        }
        .task {
            //await viewModel.listenForFlavorList()
            await viewModel.updateFlavorsOnNotificationPing()
        }
    }


}

struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        StoreDetailsView().environmentObject(IceCreamParlorVM())
    }
}
