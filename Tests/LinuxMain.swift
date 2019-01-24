import XCTest

import scrylogTests

var tests = [XCTestCaseEntry]()
tests += scrylogTests.allTests()
XCTMain(tests)