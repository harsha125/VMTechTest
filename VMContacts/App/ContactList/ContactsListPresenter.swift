//
//  ContactsListPresenter.swift
//  VMContacts
//
//  Created by Harsha on 03/10/2021.
//

import Foundation
import UIKit

enum ListType {
    case people, rooms, none
}

enum LoadingState {
    case success
    case error(error: DataLoader.Error)
}


struct PersonItem {
    let firstName: String?
    let lastName: String?
    let phoneNumber: String?
    let email: String?
    let jobTitle: String?
    let avtarURL: String?
    let colorCode: String?
    
    var fullName: String {
        [firstName, lastName].compactMap { $0 }
            .filter{ $0.isEmpty == false }
            .joined(separator: " ")
    }
    
    init(from responseObject: Person) {
        self.firstName = responseObject.firstName
        self.lastName = responseObject.lastName
        self.phoneNumber = responseObject.phone
        self.email = responseObject.email
        self.jobTitle = responseObject.jobTitle
        self.avtarURL = responseObject.avatar
        self.colorCode = responseObject.favouriteColor
    }

}

struct RoomItem {
    let name: String?
    let size: Int
    let isOccupied: Bool
    let createdOn: Date?
    
    init(from responseObject: Room) {
        self.name = responseObject.name
        self.size = responseObject.maxOccupancy ?? 0
        self.isOccupied = responseObject.isOccupied
        self.createdOn = responseObject.createdOn
    }
}


protocol ContactsListPresenterProtocol {
    var numberofSections: Int { get }
    var numberofRows: Int { get }
    func getPersonData(for indexPath: IndexPath) -> PersonItem?
    func getRoomData(for indexPath: IndexPath) -> RoomItem?
    
    var getCellIdentifier: String { get }
    
    var listType: ListType { get set }
    func loadContacts()
    func filterList(for searchText: String?)
}

final class ContactsListPresenter: ContactsListPresenterProtocol {
    
    private let view: ContactsListPresenterViewProtocol
    let context: ApplicationContext
    private var unfilteredContactList: [PersonItem] = [] {
        didSet {
            dataSource = unfilteredContactList
        }
    }

//    private var unfilteredRoomList: [RoomItem] = [] {
//        didSet {
//            dataSource = unfilteredRoomList
//        }
//    }

    private(set) var dataSource: [Any] = []
    
    private lazy var dataLoader: DataLoaderProtocol = {
        return DataLoader(client: context.apiCommunicator)
    }()
    
    var listType: ListType = .none

    init(context: ApplicationContext, view: ContactsListPresenterViewProtocol) {
        self.context = context
        self.view = view
    }
    
    func loadContacts() {
        listType = .people
        //Load data for Person list
        //Update the UI when the data loading is completed(Success / Error)
        dataLoader.loadData(for: Person.self, from: AppConfig.shared.peopleURL) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case let .success(personList):
                DispatchQueue.main.async {
                    self.unfilteredContactList = personList.compactMap { PersonItem(from: $0 as! Person) }
                    self.view.reloadData(state: .success)
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.unfilteredContactList = []
                    self.view.reloadData(state: .error(error: error as! DataLoader.Error))
                }
            }
        }
    }
    
    func filterList(for searchText: String?) {
        guard
            let searchText = searchText?.lowercased(),
              !searchText.isEmpty
        else {
            dataSource = unfilteredContactList
            view.reloadData(state: .success)
            return
        }
        ///Filter the  List based on the input text
        ///look for matchhing results with predefined search criteria
        dataSource = unfilteredContactList.filter { item in
            let searchCriteriaArray = [item.fullName, item.email, item.jobTitle, item.phoneNumber].compactMap { $0 }
            let filtered = searchCriteriaArray.filter { $0.lowercased().contains(searchText) }
            return !filtered.isEmpty
        }
        view.reloadData(state: .success)
    }


    var numberofSections: Int {
        1
    }
    
    var numberofRows: Int {
        dataSource.count
    }
    
    func getPersonData(for indexPath: IndexPath) -> PersonItem? {
        return dataSource[indexPath.row] as? PersonItem
    }

    func getRoomData(for indexPath: IndexPath) -> RoomItem? {
        return dataSource[indexPath.row] as? RoomItem
    }


    var getCellIdentifier: String {
        var cellIdentifier = ""
        switch listType {
        case .people:
            cellIdentifier = String(describing: ContactsCollectionViewCell.self)
        case .rooms:
            cellIdentifier = String(describing: RoomsCollectionViewCell.self)
        default:
            break
        }
        return cellIdentifier
    }
}
