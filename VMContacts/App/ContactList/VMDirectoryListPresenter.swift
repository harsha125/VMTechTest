//
//  VMDirectoryListPresenter.swift
//  VMContacts
//
//  Created by Harsha on 03/10/2021.
//

import Foundation
import UIKit

//Enum to identify the selected Section
enum ListType: Int {
    case people, rooms
}

//Enum to determine the Loading state, to decide what to display on the UI
enum LoadingState {
    case success
    case error(error: DataLoader.Error)
}

protocol VMDirectoryListPresenterProtocol {
    var numberofSections: Int { get }
    var numberofRows: Int { get }
    func getData(for indexPath: IndexPath) -> BaseModelItem?
    
    var listType: ListType { get }
    func loadContacts(forceLoading: Bool)
    func loadRooms(forceLoading: Bool)
    func filterList(for searchText: String?)
    func updateListType(to selectedListType:  ListType)
}

final class VMDirectoryListPresenter: VMDirectoryListPresenterProtocol {
    
    private let view: VMDirectoryListPresenterViewProtocol
    private let context: ApplicationContext

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

    //Generic data source that can hold array of People And Rooms
    private(set) var dataSource: [BaseModelItem] = []
    
    //Data Loader to fetch the data from the server through API Communicator
    private lazy var dataLoader: DataLoaderProtocol = {
        return DataLoader(client: context.apiCommunicator)
    }()
    
    private(set) var listType: ListType = .people

    init(context: ApplicationContext, view: VMDirectoryListPresenterViewProtocol) {
        self.context = context
        self.view = view
    }
    
    func loadContacts(forceLoading: Bool = true) {
        listType = .people
        //Fetch the data from server only when loading for the first time OR when forced to load
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
        //Fetch the data from server only when loading for the first time OR when forced to load
        guard unfilteredRoomList == nil ||
              forceLoading else {
            dataSource = unfilteredRoomList ?? []
            view.reloadData(state: .success)
            return
        }
        //Load data for Rooms list
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

    //Filter the list based on the input search string, for the selected section(currently displayed on UI)
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
        //Performing the search & Filter in the background thread to avoid freezing of UI
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
                    //Predefined Search Criteria for People list
                    searchCriteriaArray = [currentItem?.fullName,
                                           currentItem?.email,
                                           currentItem?.jobTitle,
                                           currentItem?.phoneNumber,
                                           currentItem?.formattedCreationDate]
                case .rooms:
                    let currentItem = item as? RoomItem
                    //Predefined Search Criteria for People list
                    searchCriteriaArray = [currentItem?.name,
                                           currentItem?.formattedCreationDate]
                }
                
                let filtered = searchCriteriaArray
                    .compactMap { $0 } //Removing nil values from the search Criteria Array
                    .filter { $0.lowercased().contains(searchText) }
                return !filtered.isEmpty
            } ?? []
            DispatchQueue.main.async {
                //Performing UI updated on main thread
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
