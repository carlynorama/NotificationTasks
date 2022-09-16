//
//  WalsExample.swift
//  NotificationTasks
//
//  Created by Labtanza on 9/15/22.
//
//The code here does not work. Had to update.
//https://www.donnywals.com/comparing-lifecycle-management-for-async-sequences-and-publishers/
import Foundation
import Combine
import SwiftUI

struct ContainerView: View {
    @State var showExampleView = false
    
    var body: some View {
        Button("Show example") {
            showExampleView = true
        }.sheet(isPresented: $showExampleView) {
            ExampleView()
        }
    }
}

class ExampleViewModel {
    
    private var tasksToCancel:[Task<(), Never>] = []
    
    func tearDown() {
        for task in tasksToCancel {
            task.cancel()
        }
    }
    
    func notificationCenterPublisher() -> AnyPublisher<UIDeviceOrientation, Never> {
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .map { _ in UIDevice.current.orientation }
            .eraseToAnyPublisher()
    }
    
    
    func notificationCenterSequence() async ->  AsyncMapSequence<NotificationCenter.Notifications, UIDeviceOrientation> {
        await NotificationCenter.default.notifications(named: UIDevice.orientationDidChangeNotification)
            .map { _ in await UIDevice.current.orientation }
    }
    
    
    
    //    var sequence:AsyncStream<UIDeviceOrientation> {
    //        get async {
    //            await notificationCenterSequence()
    //        }
    //    }
    
    var stream:AsyncStream<UIDeviceOrientation> {
        return AsyncStream { continuation in
            let streamObserver = Task {
                let sequence = await notificationCenterSequence()
                for await orientation in sequence {
                    print("\(orientation)")
                    continuation.yield(orientation)
                }
            }
            tasksToCancel.append(streamObserver)
        }
        
    }
    
}

struct ExampleView: View {
    @State var isPortraitFromPublisher = false
    @State var isPortraitFromSequence = false
    @State var isPortraitFromLocalSequence = false
    
    let viewModel = ExampleViewModel()
    
    var body: some View {
        VStack {
            Text("Portrait from publisher: \(isPortraitFromPublisher ? "yes" : "no")")
            Text("Portrait from sequence: \(isPortraitFromSequence ? "yes" : "no")")
            Text("Portrait from local sequence: \(isPortraitFromLocalSequence ? "yes" : "no")")
        }
        .task {
            for await value in viewModel.stream {
                isPortraitFromSequence = value == .portrait
            }
        }
        .onReceive(viewModel.notificationCenterPublisher()) { orientation in
            isPortraitFromPublisher = orientation == .portrait
        }
//        .task {
//            let sequence = NotificationCenter.default.notifications(named: UIDevice.orientationDidChangeNotification)
//                .map { _ in await UIDevice.current.orientation }
//            for await orientation in sequence {
//                isPortraitFromLocalSequence = orientation == .portrait
//                print(orientation)
//            }
//        }
        .task {  await watchForFlips()  }
        .onDisappear(perform: viewModel.tearDown)
        
    }
    
    func watchForFlips() async  {
        let flipWatcher =  FlipWatcher()

        do {
            for try await value in flipWatcher {
                withAnimation {
                    isPortraitFromLocalSequence = value == .portrait
                    print("FlipWatcher: \(value)")
                }
            }
        } catch {
            
        }
    }
}
