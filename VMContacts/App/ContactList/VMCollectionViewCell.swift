//
//  VMCollectionViewCell.swift
//  VMContacts
//
//  Created by Harsha on 20/10/2021.
//

import UIKit

protocol VMCollectionViewCellConfiguring {
    func configure(with item: BaseModelItem?)
}

class VMCollectionViewCell: UICollectionViewCell, VMCollectionViewCellConfiguring {

    func configure(with item: BaseModelItem?) {
        print("Implementation requires to be overridden in the child class")
    }
}
