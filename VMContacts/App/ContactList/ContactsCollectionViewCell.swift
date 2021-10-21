//
//  ContactsCollectionViewCell.swift
//  VMContacts
//
//  Created by Harsha on 19/10/2021.
//

import UIKit

final class ContactsCollectionViewCell: VMCollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var createdOnLabel: UILabel!
    @IBOutlet weak var contactDetailsTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyle()
        setupAccessibility()
    }

    //Override Configure method to configure the data for the cell
    override func configure(with item: BaseModelItem?) {
        //Typecast the cell data object to PersonItem and
        //render the data on cell by assigning it to relevant UI elements
        guard let item = item as? PersonItem
        else {
            imageView.image = nil
            nameLabel.text = nil
            jobTitleLabel.text = nil
            contactDetailsTextView.text = nil
            createdOnLabel.text = nil
            return
        }

        if let avtarURL = item.avtarURL,
           let imageURL = URL(string: avtarURL) {
            imageView.loadImage(from: imageURL)
        }
        nameLabel.text = "Name: \(item.fullName)"
        jobTitleLabel.text = "Job Title: \(item.jobTitle ?? "-")"
        contactDetailsTextView.text = """
            Phone: \(item.phoneNumber ?? "-")\n
            Email: \(item.email ?? "-")
            """
        createdOnLabel.text = "Created At: \(item.formattedCreationDate)"
        if let colorCode = item.colorCode {
            imageView.layer.borderColor = UIColor(colorCode).cgColor
            nameLabel.textColor = UIColor(colorCode)
        } else {
            imageView.layer.borderColor = UIColor.clear.cgColor
            nameLabel.textColor = .blackTextColor
        }
        
        //Updating Accessibility
        let accessibilityLabelText = [nameLabel.text,
                                      jobTitleLabel.text,
                                      contactDetailsTextView.text,
                                      createdOnLabel.text]
            .compactMap { $0 }
            .joined(separator: ", ")
        contentView.accessibilityLabel = accessibilityLabelText
    }
}

private extension ContactsCollectionViewCell {

    //Setup appearance of UI elements
    func applyStyle() {
        nameLabel.font = .makeScalableFont(weight: .semibold, defaultSize: 15.0)
        jobTitleLabel.font = .makeScalableFont(weight: .regular, defaultSize: 14.0)
        createdOnLabel.font = .makeScalableFont(weight: .light, defaultSize: 13.0)
        contactDetailsTextView.font = .makeScalableFont(weight: .regular, defaultSize: 14.0)
        nameLabel.numberOfLines = 0
        jobTitleLabel.numberOfLines = 0
        createdOnLabel.numberOfLines = 0
        nameLabel.textColor = .blackTextColor
        jobTitleLabel.textColor = .grayTextColor
        createdOnLabel.textColor = .systemGray
        contactDetailsTextView.textColor = .secondaryLabel
        imageView.layer.borderWidth = 2.0
        imageView.layer.cornerRadius = 5.0
        imageView.layer.masksToBounds = true
    }
    
    //Configure Accessibility Identifiers, to uniquely identify the elements for UI Tests
    func setupAccessibility() {
        nameLabel.accessibilityIdentifier = "contacts.collectionView.cell.label.name"
        jobTitleLabel.accessibilityIdentifier = "contacts.collectionView.cell.label.jobTitle"
        createdOnLabel.accessibilityIdentifier = "contacts.collectionView.cell.label.createdOn"
        contactDetailsTextView.accessibilityIdentifier = "contacts.collectionView.cell.textView.contactDetails"
        imageView.accessibilityIdentifier = "contacts.collectionView.cell.imageview.avtar"
        contentView.isAccessibilityElement = true
        accessibilityElements = [contentView]
        isAccessibilityElement = false
    }
}
