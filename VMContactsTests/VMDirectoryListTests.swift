//
//  VMDirectoryListTests.swift
//  VMContactsTests
//
//  Created by Harsha on 21/10/2021.
//

import XCTest
@testable import VMContacts

class VMDirectoryListTests: XCTestCase {
    private var viewMock: VMDirectoryListViewControllerMock?
    var presenter: VMDirectoryListPresenter?
    var appContextMock: ApplicationContext?

    override func setUp() {
        appContextMock = ApplicationContext(apiCommunicator: APICOmmunicatorMock())
        viewMock = .init()
        presenter = VMDirectoryListPresenter(context: appContextMock!, view: viewMock!)
        viewMock!.presenter = presenter
    }
    
    override func tearDown() {
        viewMock = nil
        presenter = nil
        appContextMock = nil
    }
    
    func testPeopleLoading() {
        presenter?.loadContacts()
        wait(for: [viewMock!.peopleListLoadExpectation], timeout: 5)
    }

    func testMeetingRoomsListLoading() {
        presenter?.loadRooms()
        wait(for: [self.viewMock!.roomListLoadExpectation], timeout: 5)
    }


    func testPeopleListSearching() {
        viewMock?.isSearching = true
        presenter?.loadContacts()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.presenter?.filterList(for: "ronny")
        }
        wait(for: [self.viewMock!.searchExpectation], timeout: 5)
    }

    func testRoomListSearching() {
        viewMock?.isSearching = true
        presenter?.loadRooms()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.presenter?.filterList(for: "island")
        }
        wait(for: [self.viewMock!.searchExpectation], timeout: 5)
    }


    private class VMDirectoryListViewControllerMock: VMDirectoryListPresenterViewProtocol {
        var presenter: VMDirectoryListPresenter?
        let peopleListLoadExpectation = XCTestExpectation(description: "People List Load Complete")
        let roomListLoadExpectation = XCTestExpectation(description: "Rooms List Load Expectation")
        let searchExpectation = XCTestExpectation(description: "People list search Expectation")
        var isSearching = false

        
        func reloadData(state: LoadingState) {
            if isSearching {
                searchExpectation.fulfill()
            } else {
                if presenter?.listType == .people {
                    peopleListLoadExpectation.fulfill()
                } else {
                    roomListLoadExpectation.fulfill()
                }
            }
        }
        
    }

}
