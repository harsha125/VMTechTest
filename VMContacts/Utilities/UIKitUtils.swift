//
//  UIKitUtils.swift
//  VMContacts
//
//  Created by Harsha on 19/10/2021.
//

import UIKit

///UIFont extension that provides an API to have dynamically sizable font for a UI Element.
/// This facilitates resizing of the text when the large fonts are enabled through Accessibility section of device Settings
extension UIFont {
    static func makeScalableFont(for textStyle: UIFont.TextStyle = .body,
                                 weight: UIFont.Weight = .regular,
                                 defaultSize: CGFloat = 12.0,
                                 symbolicTraits: UIFontDescriptor.SymbolicTraits? = nil,
                                 maximumPointSize: CGFloat? = nil) -> UIFont {

        let metricsObject = UIFontMetrics(forTextStyle: textStyle)
        var weightedFont = UIFont.systemFont(ofSize: defaultSize, weight: weight)
        
        if let symbolicTraits = symbolicTraits,
           let descriptorWithtrait = weightedFont.fontDescriptor.withSymbolicTraits(symbolicTraits) {
            weightedFont = UIFont(descriptor: descriptorWithtrait, size: weightedFont.pointSize)
        }
        if let maxpointSize = maximumPointSize,
           defaultSize < maxpointSize {
            return metricsObject.scaledFont(for: weightedFont, maximumPointSize: maxpointSize)
        }
        return metricsObject.scaledFont(for: weightedFont)
    }
}
///Simple extension that adds `className` property to `UIViewController`
extension UIViewController {
    static var className: String {
        String(describing: self)
    }
}

extension UICollectionView {
    
    func register<Cell: UICollectionViewCell>(class cellClass: Cell.Type,
                                              forCellWithReuseIdentifier identifier: String = String(describing: Cell.self)) {
        register(cellClass, forCellWithReuseIdentifier: identifier)
    }

    func register<Cell: UICollectionViewCell>(nibForClass cellClass: Cell.Type,
                                              forCellWithReuseIdentifier identifier: String = String(describing: Cell.self),
                                              bundle: Bundle? = nil) {
        let nibname = String(describing: cellClass)
        let nib = UINib(nibName: nibname, bundle: bundle)
        register(nib, forCellWithReuseIdentifier: identifier)
    }

    
    func dequeueReusableCell<Cell>(_ cellType: Cell.Type,
                                   for indexPath: IndexPath,
                                   withReuseIdentifier identifier: String = String(describing: Cell.self)) -> Cell where Cell: UICollectionViewCell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? Cell else {
            fatalError("Error Dequeuing Collection View Cell of type \(cellType) with Identifier \(identifier) for indexpath \(indexPath).")
        }
        return cell
    }

}


extension UIStoryboard {
    static let main = UIStoryboard(name: "Main", bundle: .main)
}

