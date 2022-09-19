//
//  InsistantPopover.swift
//  AsyncPublisherTests
//
//  Created by Labtanza on 9/9/22.
//

import Foundation
import SwiftUI


struct StoreView: View {
    //there is a task creator IN THE INIT of this VM. The tasks will last with the VM or longer. Watch for leaks.
    @EnvironmentObject private var viewModel:IceCreamParlorVM
    

    var body: some View {
        VStack {
            Text(viewModel.thisWeeksSpecial.name)
            Text("Updated \(viewModel.updateCount) times")
            ScrollView {
                VStack {
                    ForEach(viewModel.available) {
                        Text($0.name)
                    }
                }
            }
        }.task {
            await viewModel.casualSetUp()
        }
    }


}

struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        StoreView().environmentObject(IceCreamParlorVM())
    }
}
