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
    
    var subTaskSpawingingStream:AsyncStream<UIDeviceOrientation> {
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
    
    var asyncStream:AsyncStream<UIDeviceOrientation> {
        return AsyncStream.init(unfolding: unfolding, onCancel: onCancel)
        
        //() async -> _?
        func unfolding() async -> UIDeviceOrientation? {
            let sequence = await notificationCenterSequence()
            for await orientation in sequence {
                print("\(orientation)")
                return orientation
            }
            return nil
        }
        
        //optional
        @Sendable func onCancel() -> Void {
            print("ComaprisonVM asyncStream Got Canceled")
        }
    }
    
}

struct ComparisonView: View {
    @State var isPortraitFromPublisher = false
    @State var isPortraitFromTaskSequence = false
    @State var isPortraitFromLocalSequence = false
    @State var isPortraitFromStream = false
    
    let viewModel = ComparisonViewModel()
    
    var body: some View {
        VStack {
            Text("Portrait from publisher: \(isPortraitFromPublisher ? "yes" : "no")")
            Text("Portrait from task spawing stream: \(isPortraitFromTaskSequence ? "yes" : "no")")
            Text("Portrait from local sequence: \(isPortraitFromLocalSequence ? "yes" : "no")")
            Text("Portrait from custom sequence: \(isPortraitFromStream ? "yes" : "no")")
        }
      //Bespoke publisher.
        .onReceive(viewModel.notificationCenterPublisher()) { orientation in
            isPortraitFromPublisher = orientation == .portrait
        }
      //As custom async sequence.
      .task {  await watchForFlips()  }
      //Async stream. Requires teardown as written.
        .task {
            for await value in viewModel.subTaskSpawingingStream {
                isPortraitFromTaskSequence = value == .portrait
            }
        }
        .onDisappear(perform: viewModel.tearDown)
        .task {  await watchForFlips()  }
        .task {
            defer { print("ComparisoView: asyncStream canceled w/o explicit cancel")}
            for await value in viewModel.asyncStream {
                isPortraitFromStream = value == .portrait
            }
        }
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
