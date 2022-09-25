//
//  CopyTaskExample.swift
//  NotificationTasks
//
//  Created by Labtanza on 9/25/22.
//
// Example by Ray Fix:
//https://github.com/aflockofswifts/meetings#copytask


import Foundation


//enum FileCopyStatus {
//    case complete
//    case cancelled
//    case error(FileCopyError)
//}
//
//protocol FileAccess {
//
//}
//
//enum FileCopyError:Error {
//
//}
//
//
//final class CopyTask {
//  var status: AsyncStream<FileCopyStatus>! = nil
//  private var task: Task<Void, Never>? = nil
//  private var continuation: AsyncStream<FileCopyStatus>.Continuation! = nil
//  private var access: any FileAccess
//
//  init(source: URL, destination: URL, access: any FileAccess) {
//    self.access = access
//    self.status = AsyncStream.init { continuation in
//      self.continuation = continuation
//      continuation.yield(.estimating)
//    }
//    task = Task {
//      do {
//        let totalSize = try await self.findSize(source)
//        try await self.recursiveCopy(source: source,
//                                     destination: destination,
//                                     total: totalSize)
//        self.continuation.yield(.complete(.init(current: totalSize, total: totalSize)))
//      } catch is CancellationError {
//        self.continuation.yield(.cancelled)
//      } catch {
//        self.continuation.yield(.error(error))
//      }
//      self.continuation.finish()
//    }
//  }
//
//  private func findSize(_ url: URL) async throws -> Int64 {
//    let info = try await access.fileInfo(for: url)
//    if !info.isDirectory {
//      return info.size
//    }
//    func depthFirst(url: URL) async throws -> Int64 {
//      let dir = try await access.listDirectory(url: url)
//      var total: Int64 = 0
//      for file in dir {
//        if file.isDirectory {
//          total += try await depthFirst(url: url.appendingPathComponent(file.name))
//          try Task.checkCancellation()
//        } else {
//          total += file.size
//        }
//      }
//      return total
//    }
//    return try await depthFirst(url: url)
//  }
//
//  func recursiveCopy(source: URL, destination: URL, total: Int64) async throws {
//    var current: Int64 = 0
//    let info = try await access.fileInfo(for: source)
//    if !info.isDirectory {
//      try await access.copyFile(source: source, destination: destination) { byteCount in
//        current += byteCount
//      }
//    } else {
//      func depthFirstCopy(source: URL, destination: URL) async throws {
//        let dir = try await access.listDirectory(url: source)
//
//        for file in dir {
//          let sourceURL = source.appendingPathComponent(file.name)
//          let destinationURL = destination.appendingPathComponent(file.name)
//          try Task.checkCancellation()
//          if file.isDirectory {
//            try await access.createDirectory(url: destinationURL)
//            try await depthFirstCopy(source: sourceURL,
//                                     destination: destinationURL)
//          } else {
//            try await access.copyFile(source: sourceURL, destination: destinationURL) {
//              byteCount in
//              current += byteCount
//            }
//            self.continuation.yield(.progress(.init(current: current, total: total)))
//          }
//        }
//      }
//      try await depthFirstCopy(source: source, destination: destination)
//    }
//  }
//
//  func cancel() {
//    task?.cancel()
//  }
//
//  @discardableResult
//  func complete() async throws -> FileCopyProgress {
//    var last: FileCopyStatus?
//    for await state in status {
//      last = state
//    }
//    guard let last = last else {
//      throw FileCopyError.unknownTransferFailure
//    }
//    switch last {
//    case .estimating, .progress(_):
//      throw FileCopyError.unknownTransferFailure
//    case .complete(let progress):
//      return progress // happy path
//    case .cancelled:
//      throw CancellationError()
//    case .error(let error):
//      throw error
//    }
//  }
//}
