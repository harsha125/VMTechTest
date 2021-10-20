//
//  ContactsCollectionViewCell.swift
//  VMContacts
//
//  Created by Harsha on 19/10/2021.
//

import UIKit

class ContactsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var contactDetailsTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        applyStyle()
        setupAccessibility()
    }
    
    func configure(with item: PersonItem?) {
        //TODO: Download and display image
        nameLabel.text = "Name: \(item?.fullName ?? "-")"
        jobTitleLabel.text = "Job Title: \(item?.jobTitle ?? "-")"
        contactDetailsTextView.text = """
            Phone: \(item?.phoneNumber ?? "-")\n
            Email: \(item?.email ?? "-")
            """
        if let colorCode = item?.colorCode {
            imageView.layer.borderColor = UIColor(colorCode).cgColor
        } else {
            imageView.layer.borderColor = UIColor.clear.cgColor
        }
        
        //Updating Accessibility
        let accessibilityLabelText = [nameLabel.text,
                                      jobTitleLabel.text,
                                      contactDetailsTextView.text]
            .compactMap { $0 }
            .joined(separator: ", ")
        contentView.accessibilityLabel = accessibilityLabelText
    }

    func applyStyle() {
        nameLabel.font = .makeScalableFont(weight: .semibold, defaultSize: 15.0)
        jobTitleLabel.font = .makeScalableFont(weight: .regular, defaultSize: 14.0)
        contactDetailsTextView.font = .makeScalableFont(weight: .regular, defaultSize: 14.0)
        nameLabel.numberOfLines = 0
        jobTitleLabel.numberOfLines = 0
        nameLabel.textColor = .blackTextColor
        jobTitleLabel.textColor = .grayTextColor
        contactDetailsTextView.textColor = .secondaryLabel
        imageView.layer.borderWidth = 1.0
        imageView.layer.cornerRadius = 5.0
        imageView.layer.masksToBounds = true
    }
    
    func setupAccessibility() {
        nameLabel.accessibilityIdentifier = "contacts.collectionView.cell.label.name"
        jobTitleLabel.accessibilityIdentifier = "contacts.collectionView.cell.label.jobTitle"
        contactDetailsTextView.accessibilityIdentifier = "contacts.collectionView.cell.textView.contactDetails"
        contentView.isAccessibilityElement = true
        accessibilityElements = [contentView]
        isAccessibilityElement = false
    }
}
