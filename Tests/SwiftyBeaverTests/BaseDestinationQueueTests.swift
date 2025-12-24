//
//  BaseDestinationQueueTests.swift
//  SwiftyBeaver
//
//  Created by Alejandro Beltrán on 12/24/25.
//

import XCTest
@testable import SwiftyBeaver

final class BaseDestinationQueueTests: XCTestCase {
    func testExecuteAsyncRunsBlock() {
        let obj = BaseDestination()
        let exp = expectation(description: "async block executed")
        obj.execute(synchronously: false) {
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }
    func testExecuteSynchronouslyReturnsValue() {
        let obj = BaseDestination()
        let value: Int = obj.executeSynchronously { 42 }
        XCTAssertEqual(value, 42)
    }
    func testExecuteSynchronouslyPropagatesError() {
        enum SampleError: Error { case boom }
        let obj = BaseDestination()
        XCTAssertThrowsError(try obj.executeSynchronously { throw SampleError.boom })
    }
    func testQueueIsSerialAndPreservesOrder() {
        let obj = BaseDestination()
        let exp = expectation(description: "serial execution")
        var arr: [Int] = []
        obj.execute(synchronously: false) { arr.append(1) }
        obj.execute(synchronously: false) {
            arr.append(2)
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(arr, [1, 2])
    }
}
