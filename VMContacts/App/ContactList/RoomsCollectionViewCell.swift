//
//  RoomsCollectionViewCell.swift
//  VMContacts
//
//  Created by Harsha on 19/10/2021.
//

import UIKit

final class RoomsCollectionViewCell: VMCollectionViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var createdOnLabel: UILabel!
    @IBOutlet weak var maxOccupancyLabel: UILabel!
    @IBOutlet weak var availabilityLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyle()
        setupAccessibility()
    }
    
    //Override Configure method to configure the data for the cell
    override func configure(with item: BaseModelItem?) {
        //Typecast the cell data object to RoomItem and
        //render the data on cell by assigning it to relevant UI elements
        guard let item = item as? RoomItem
        else {
            nameLabel.text = nil
            maxOccupancyLabel.text = nil
            availabilityLabel.text = nil
            createdOnLabel.text = nil
            return
        }
        nameLabel.text = "Name: \(item.name ?? "-")"
        maxOccupancyLabel.text = "Maximum Occupancy: \(item.size)"
        availabilityLabel.text = "Status: \(item.isOccupied == true ? "Full" : "Available")"
        createdOnLabel.text = "Created At: \(item.formattedCreationDate)"
        
        if item.isOccupied == true {
            availabilityLabel.textColor = .themeRed_C40202
        } else {
            availabilityLabel.textColor = .systemGreen
        }
        //Updating Accessibility
        let accessibilityLabelText = [nameLabel.text,
                                      createdOnLabel.text,
                                      maxOccupancyLabel.text,
                                      availabilityLabel.text]
            .compactMap { $0 }
            .joined(separator: ", ")
        contentView.accessibilityLabel = accessibilityLabelText
    }

    
}
private extension RoomsCollectionViewCell {

    //Setup appearance of UI elements
    func applyStyle() {
        nameLabel.font = .makeScalableFont(weight: .semibold, defaultSize: 15.0)
        maxOccupancyLabel.font = .makeScalableFont(weight: .regular, defaultSize: 14.0)
        createdOnLabel.font = .makeScalableFont(weight: .light, defaultSize: 13.0)
        availabilityLabel.font = .makeScalableFont(weight: .regular, defaultSize: 14.0)
        nameLabel.numberOfLines = 0
        maxOccupancyLabel.numberOfLines = 0
        createdOnLabel.numberOfLines = 0
        availabilityLabel.numberOfLines = 0
        nameLabel.textColor = .blackTextColor
        maxOccupancyLabel.textColor = .grayTextColor
        createdOnLabel.textColor = .systemGray
        availabilityLabel.textColor = .secondaryLabel
    }

    //Configure Accessibility Identifiers, to uniquely identify the elements for UI Tests
    func setupAccessibility() {
        nameLabel.accessibilityIdentifier = "rooms.collectionView.cell.label.name"
        maxOccupancyLabel.accessibilityIdentifier = "rooms.collectionView.cell.label.maxOccupancyLabel"
        createdOnLabel.accessibilityIdentifier = "rooms.collectionView.cell.label.createdOn"
        availabilityLabel.accessibilityIdentifier = "rooms.collectionView.cell.label.maxOccupancyLabel"
        contentView.isAccessibilityElement = true
        accessibilityElements = [contentView]
        isAccessibilityElement = false
    }

}
