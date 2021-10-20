//
//  ContactsListPresenter.swift
//  VMContacts
//
//  Created by Harsha on 03/10/2021.
//

import Foundation
import UIKit

enum ListType: Int {
    case people, rooms
}

enum LoadingState {
    case success
    case error(error: DataLoader.Error)
}

protocol ContactsListPresenterProtocol {
    var numberofSections: Int { get }
    var numberofRows: Int { get }
    func getData(for indexPath: IndexPath) -> BaseModelItem?
    
    var listType: ListType { get }
    func loadContacts(forceLoading: Bool)
    func loadRooms(forceLoading: Bool)
    func filterList(for searchText: String?)
    func updateListType(to selectedListType:  ListType)
}

final class ContactsListPresenter: ContactsListPresenterProtocol {
    
    private let view: ContactsListPresenterViewProtocol
    let context: ApplicationContext
    private var unfilteredContactList: [PersonItem]? = nil {
        didSet {
            dataSource = unfilteredContactList ?? []
        }
    }

    private var unfilteredRoomList: [RoomItem]? = nil {
        didSet {
            dataSource = unfilteredRoomList ?? []
        }
    }

    private(set) var dataSource: [BaseModelItem] = []
    
    private lazy var dataLoader: DataLoaderProtocol = {
        return DataLoader(client: context.apiCommunicator)
    }()
    
    private(set) var listType: ListType = .people

    init(context: ApplicationContext, view: ContactsListPresenterViewProtocol) {
        self.context = context
        self.view = view
    }
    
    func loadContacts(forceLoading: Bool = true) {
        listType = .people
        guard unfilteredContactList == nil ||
              forceLoading else {
            dataSource = unfilteredContactList ?? []
            view.reloadData(state: .success)
            return
        }
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

    
    func loadRooms(forceLoading: Bool = true) {
        listType = .rooms
        guard unfilteredRoomList == nil ||
              forceLoading else {
            dataSource = unfilteredRoomList ?? []
            view.reloadData(state: .success)
            return
        }
        //Load data for Person list
        //Update the UI when the data loading is completed(Success / Error)
        dataLoader.loadData(for: Room.self, from: AppConfig.shared.roomsURL) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case let .success(roomList):
                DispatchQueue.main.async {
                    self.unfilteredRoomList = roomList.compactMap { RoomItem(from: $0 as! Room) }
                    self.view.reloadData(state: .success)
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.unfilteredRoomList = []
                    self.view.reloadData(state: .error(error: error as! DataLoader.Error))
                }
            }
        }
    }

    func filterList(for searchText: String?) {

        let unfilteredData:[BaseModelItem]? = listType == .people ? unfilteredContactList : unfilteredRoomList
        
        guard
            let searchText = searchText?.lowercased(),
              !searchText.isEmpty
        else {
            dataSource = unfilteredData ?? []
            view.reloadData(state: .success)
            return
        }
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self
            else { return }
            ///Filter the  List based on the input text
            ///look for matchhing results with predefined search criteria
            self.dataSource = unfilteredData?.filter { item in
                let searchCriteriaArray: [String?]
                switch self.listType {
                case .people:
                    let currentItem = item as? PersonItem
                    searchCriteriaArray = [currentItem?.fullName,
                                           currentItem?.email,
                                           currentItem?.jobTitle,
                                           currentItem?.phoneNumber,
                                           currentItem?.formattedCreationDate]
                case .rooms:
                    let currentItem = item as? RoomItem
                    searchCriteriaArray = [currentItem?.name,
                                           currentItem?.formattedCreationDate]
                }
                
                let filtered = searchCriteriaArray
                    .compactMap { $0 } //Removing nil values from the search Criteria Array
                    .filter { $0.lowercased().contains(searchText) }
                return !filtered.isEmpty
            } ?? []
            DispatchQueue.main.async {
                self.view.reloadData(state: .success)
            }
            
        }
    }

    func updateListType(to selectedListType: ListType) {
        listType = selectedListType
        switch listType {
        case .people:
            loadContacts(forceLoading: false)
        case .rooms:
            loadRooms(forceLoading: false)
        }
    }

    var numberofSections: Int {
        1
    }
    
    var numberofRows: Int {
        dataSource.count
    }
    
    func getData(for indexPath: IndexPath) -> BaseModelItem? {
        return dataSource[indexPath.row]
    }

}
