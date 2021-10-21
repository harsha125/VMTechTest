//
//  VMContactsTests.swift
//  VMContactsTests
//
//  Created by Harsha on 03/10/2021.
//

import XCTest
@testable import VMContacts

class VMContactsTests: XCTestCase {

    var applicationContextMock: ApplicationContext?
    var dataLoaderMock: DataLoader?

    override func setUp() {
        applicationContextMock = ApplicationContext(apiCommunicator: APICOmmunicatorMock())
        dataLoaderMock = DataLoader(client: applicationContextMock!.apiCommunicator)
    }
    
    override func tearDown() {
        applicationContextMock = nil
        dataLoaderMock = nil
    }
    
    func testJSONDecoder() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        let peopleList = try! JSONItemsMapper<[Person]>.decodeAndMap(peopleJSONData!)
        XCTAssertNotNil(peopleList)
        XCTAssertFalse(peopleList.isEmpty)
        XCTAssertEqual(peopleList.count, 9)
    }
    
    func testAPICommunicator() {
        let expectation = XCTestExpectation(description: "API Communicator Expectation")
        applicationContextMock?.apiCommunicator.get(from: AppConfigMock.shared.peopleURL) { (resultData) in
            switch resultData {
            case .success(let data):
                XCTAssertNotNil(data)
            case .failure(_):
                break
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testDataLoader() {
        let expectation = XCTestExpectation(description: "Data Loader Expectation")
        dataLoaderMock!.loadData(for: Person.self, from: AppConfigMock.shared.peopleURL) { (resultData) in
            switch resultData {
            case .success(let personList):
                XCTAssertNotNil(personList)
                XCTAssertFalse(personList.isEmpty)
                XCTAssertEqual(personList.count, 9)
            case .failure(_):
                break
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

}
