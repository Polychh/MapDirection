//
//  UIStackView.swift
//  Map
//
//  Created by USER on 21.04.2023.
//

import UIKit

extension UIStackView {
    convenience init( axis:NSLayoutConstraint.Axis, distribution:  UIStackView.Distribution) {
        self.init(frame: .zero)
        self.axis = axis
        self.distribution = distribution
        self.translatesAutoresizingMaskIntoConstraints = false
        intrinsicContentSize.width
    }
    
    func removeFully(view: UIView) {
        removeArrangedSubview(view)
        view.removeFromSuperview()
    }
    
    func removeFullyAllArrangedSubviews() {
        arrangedSubviews.forEach { (view) in
            removeFully(view: view)
        }
    }
}
