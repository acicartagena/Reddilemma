import XCTest

import RedditAPITests

var tests = [XCTestCaseEntry]()
tests += RedditAPITests.allTests()
XCTMain(tests)
