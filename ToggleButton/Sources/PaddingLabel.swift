//
//  PaddingLabel.swift
//  ToggleButton
//
//  Created by Tuan Tran on 04/03/2019.
//  Copyright © 2019 Tuan Tran. All rights reserved.
//

import UIKit

open class PaddingLabel: UILabel {

    public var padding: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            sizeToFit()
        }
    }

    override open func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    // Override `intrinsicContentSize` property for Auto layout code
    override open var intrinsicContentSize: CGSize {
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + padding.left + padding.right
        let heigth = superContentSize.height + padding.top + padding.bottom
        return CGSize(width: width, height: heigth)
    }

    // Override `sizeThatFits(_:)` method for Springs & Struts code
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        let superSizeThatFits = super.sizeThatFits(size)
        let width = superSizeThatFits.width + padding.left + padding.right
        let heigth = superSizeThatFits.height + padding.top + padding.bottom
        return CGSize(width: width, height: heigth)
    }
}
