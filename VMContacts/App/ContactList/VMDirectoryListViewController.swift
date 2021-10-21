//
//  VMDirectoryListViewController.swift
//  VMContacts
//
//  Created by Harsha on 03/10/2021.
//

import UIKit

protocol VMDirectoryListPresenterViewProtocol {
    func reloadData(state: LoadingState)
}

class VMDirectoryListViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    var presenter: VMDirectoryListPresenter?
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let searchController = UISearchController(searchResultsController: nil)
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshList), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Please wait...")
        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Contacts List"
        navigationController?.navigationBar.prefersLargeTitles = true
        presenter?.loadContacts()
        configureCollectionView()
        configureSearchController()
        addAccessibilityInfo()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deactivateSearchController()
    }
    
    deinit {
        presenter = nil
    }
    
    @IBAction func segmentControlTapped(_ sender: Any) {
        presenter?.updateListType(to: ListType(rawValue: segmentedControl.selectedSegmentIndex) ?? .people)
    }
    
    private func addAccessibilityInfo() {
        collectionView.accessibilityLabel = "Directory List"
        collectionView.accessibilityIdentifier = "contacts.collectionview"
        searchController.searchBar.accessibilityLabel = "Contacts List Search bar"
        searchController.searchBar.searchTextField.accessibilityIdentifier = "contacts.searchField"

    }

    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Enter search text"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.refreshControl = refreshControl
        collectionView.keyboardDismissMode = .interactive
        collectionView.dataSource = self
        collectionView.register(nibForClass: ContactsCollectionViewCell.self)
        collectionView.register(nibForClass: RoomsCollectionViewCell.self)
        collectionView.accessibilityIdentifier = "collectionView"
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func deactivateSearchController() {
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
    }

    private func createLayout() -> UICollectionViewLayout {
        var layoutConfig: UICollectionLayoutListConfiguration = .init(appearance: .insetGrouped)
        layoutConfig.showsSeparators = true
        let layout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        return layout
    }

    @objc private func refreshList() {
        if !isSearching {
            guard let presenter = presenter
            else { return }
            switch presenter.listType {
            case .people:
                presenter.loadContacts()
            case .rooms:
                presenter.loadRooms()
            }
        }
    }

}

extension VMDirectoryListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        presenter?.numberofSections ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter?.numberofRows ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let listType = presenter?.listType
        else { return VMCollectionViewCell() }
        let cell: VMCollectionViewCell
        var cellData: BaseModelItem? = nil
        switch listType {
        case .people:
            cell = collectionView.dequeueReusableCell(ContactsCollectionViewCell.self, for: indexPath)
            cell.accessibilityIdentifier = "contacts.collectionView.cell.\(indexPath.row)"
            cellData = presenter?.getData(for: indexPath) as? PersonItem
        case .rooms:
            cell = collectionView.dequeueReusableCell(RoomsCollectionViewCell.self, for: indexPath)
            cell.accessibilityIdentifier = "rooms.collectionView.cell.\(indexPath.row)"
            cellData = presenter?.getData(for: indexPath) as? RoomItem
        }
        cell.configure(with: cellData)
        return cell
    }
    
}


extension VMDirectoryListViewController: UISearchResultsUpdating {

    private var searchText: String? {
        searchController.searchBar.text
    }
    var isSearching: Bool {
        searchController.isActive
    }

    func updateSearchResults(for searchController: UISearchController) {
        presenter?.filterList(for: searchText)
    }
}


extension VMDirectoryListViewController: VMDirectoryListPresenterViewProtocol {

    //Configure Error view when the State is Error / API call fails
    private func configureErrorView(with errorText: String) -> UIView {
        let errorView = UIView(frame: .zero)
        let errorLabel = UILabel()
        errorLabel.numberOfLines = 0
        errorLabel.font = .makeScalableFont(for: .headline, weight: .light, defaultSize: 17.0)
        errorLabel.textColor = .themeRed_C40202
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.text = errorText
        errorView.addSubview(errorLabel)
        errorView.tag = 100
        NSLayoutConstraint.activate([
            errorLabel.leadingAnchor.constraint(greaterThanOrEqualTo: errorView.leadingAnchor, constant: 30.0),
            errorLabel.centerYAnchor.constraint(equalTo: errorView.centerYAnchor),
            errorLabel.topAnchor.constraint(greaterThanOrEqualTo: errorView.topAnchor, constant: 30.0),
            errorLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor)
        ])
        return errorView
    }
    
    func reloadData(state: LoadingState) {
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
        //Update the title based on the selected Section on Segment control
        title = presenter?.listType == .people ? "Contacts" : "Rooms"
        collectionView.subviews.forEach { if $0.tag == 100 { $0.removeFromSuperview() } }
        switch state {
        case .success:
            if isSearching, presenter?.dataSource.isEmpty == true {
                let errorView = configureErrorView(with: "Your search has no matching results")
                errorView.frame = collectionView.bounds
                collectionView.addSubview(errorView)
            }

        case .error(_):
            let errorView = configureErrorView(with: "Something went worong! Unable to load data")
            errorView.frame = collectionView.bounds
            collectionView.addSubview(errorView)
        }
        collectionView.reloadData()

        
    }
}

