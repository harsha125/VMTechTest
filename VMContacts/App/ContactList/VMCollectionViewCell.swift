//
//  VMCollectionViewCell.swift
//  VMContacts
//
//  Created by Harsha on 20/10/2021.
//

import UIKit

//Configuring the attributes / behaviour for the Collection view cell
protocol VMCollectionViewCellConfiguring {
    func configure(with item: BaseModelItem?)
}

//Base CollectionViewCell class subclassed from UICollectionViewCell, to extend the functionality of UICollectionViewCell
class VMCollectionViewCell: UICollectionViewCell, VMCollectionViewCellConfiguring {

    func configure(with item: BaseModelItem?) {
        print("Implementation requires to be overridden in the child class")
    }
}
