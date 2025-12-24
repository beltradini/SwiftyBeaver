//
//  StressTests.swift
//  SwiftyBeaver
//
//  Created by Alejandro Beltrán on 12/24/25.
//

import XCTest
@testable import SwiftyBeaver

final class StressTests: XCTestCase {

    func testConcurrentAsyncNoCrashStress() {
        let obj = BaseDestination()
        let N = 1000
        let exp = expectation(description: "all tasks executed")
        exp.expectedFulfillmentCount = N
        
        for _ in 0..<N {
            DispatchQueue.global().async {
                obj.execute(synchronously: false) {
                    exp.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 5.0)
    }

    func testMixedSyncAsyncNoDeadlock() {
        let obj = BaseDestination()
        let group = DispatchGroup()
        let workers = 50
        let iterations = 200
        
        for _ in 0..<workers {
            DispatchQueue.global().async(group: group) {
                for _ in 0..<iterations {
                    // Mix synchronous and asynchronous calls
                    obj.execute(synchronously: false) { }
                    let _ = obj.executeSynchronously { true }
                }
            }
        }
        // Wait for group with timeout
        let waitResult = group.wait(timeout: .now() + 10)
        XCTAssertEqual(waitResult, .success, "Mixed sync/async operations timed out or deadlocked")
    }

    func testNoFatalErrorUnderRace() {
        // Create many destinations concurrently and call execute on them immediately.
        // If queue was optional and sometimes nil, this could trigger a crash; this test guards against regressions.
        let iterations = 500
        let exp = expectation(description: "concurrent creations finished")
        exp.expectedFulfillmentCount = iterations

        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            let dest = BaseDestination()
            dest.execute(synchronously: false) {
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 10.0)
    }
}

