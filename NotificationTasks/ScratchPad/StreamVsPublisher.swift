//
//  ComparingApproaches.swift
//  NotificationTasks
//
//  Created by carlynorama on 9/15/22.
//
//
// https://www.donnywals.com/comparing-lifecycle-management-for-async-sequences-and-publishers/ (code appraoch has been depricated since written)
// https://www.hackingwithswift.com/quick-start/concurrency/how-to-create-a-custom-asyncsequence

import Foundation
import Combine
import SwiftUI

struct ComparisonContainerView: View {
    @State var showExampleView = false
    
    var body: some View {
        Button("Show example") {
            showExampleView = true
        }.sheet(isPresented: $showExampleView) {
            ComparisonView()
        }
    }
}

class ComparisonViewModel {
    
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

struct ComparisonView: View {
    @State var isPortraitFromPublisher = false
    @State var isPortraitFromSequence = false
    @State var isPortraitFromLocalSequence = false
    
    let viewModel = ComparisonViewModel()
    
    var body: some View {
        VStack {
            Text("Portrait from publisher: \(isPortraitFromPublisher ? "yes" : "no")")
            Text("Portrait from sequence: \(isPortraitFromSequence ? "yes" : "no")")
            Text("Portrait from local sequence: \(isPortraitFromLocalSequence ? "yes" : "no")")
        }
      //Bespoke publisher.
        .onReceive(viewModel.notificationCenterPublisher()) { orientation in
            isPortraitFromPublisher = orientation == .portrait
        }
      //As custom async sequence.
      .task {  await watchForFlips()  }
      //Async stream. Requires teardown as written.
        .task {
            for await value in viewModel.stream {
                isPortraitFromSequence = value == .portrait
            }
        }
        .onDisappear(perform: viewModel.tearDown)
              .task {  await watchForFlips()  }
        // can of course do it all inline.
//        .task {
               
//            let sequence = NotificationCenter.default.notifications(named: UIDevice.orientationDidChangeNotification)
//                .map { _ in await UIDevice.current.orientation }
//            for await orientation in sequence {
//                isPortraitFromLocalSequence = orientation == .portrait
//                print(orientation)
//            }
//        }
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


struct FlipWatcher: AsyncSequence, AsyncIteratorProtocol {
    typealias Element = UIDeviceOrientation
    
    private var isActive = true
    
    mutating func next() async throws -> Element? {
        guard isActive else { return nil }
        let sequence = await NotificationCenter.default.notifications(named: UIDevice.orientationDidChangeNotification)
            .map { _ in await UIDevice.current.orientation }
        
        for await orientation in sequence {
            print("\(orientation)")
            return orientation
        }
        return nil
    }
    
    func makeAsyncIterator() -> FlipWatcher {
        self
    }
}
