//
//  ContactsListViewController.swift
//  VMContacts
//
//  Created by Harsha on 03/10/2021.
//

import UIKit

protocol ContactsListPresenterViewProtocol {
    func reloadData(state: LoadingState)
}

class ContactsListViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    var presenter: ContactsListPresenter?
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
    }
    
    private func addAccessibilityInfo() {
        collectionView.accessibilityLabel = "Contacts List"
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
        collectionView.accessibilityIdentifier = "contacts.collectionView"
        
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
            presenter?.loadContacts()
        }
    }

}

extension ContactsListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        presenter?.numberofSections ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter?.numberofRows ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ContactsCollectionViewCell.self, for: indexPath)
        cell.configure(with: presenter?.getPersonData(for: indexPath))
        cell.accessibilityIdentifier = "contacts.collectionView.cell.\(indexPath.row)"
        return cell
    }
    
}


extension ContactsListViewController: UISearchResultsUpdating {

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


extension ContactsListViewController: ContactsListPresenterViewProtocol {

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

