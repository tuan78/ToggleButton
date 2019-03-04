//
//  ToggleButton.swift
//  ToggleButton
//
//  Created by Tuan Tran on 04/03/2019.
//  Copyright © 2019 Tuan Tran. All rights reserved.
//

import UIKit

// MARK: - Delegate
public protocol ToggleButtonDelegate: AnyObject {

    func toggleButton(_ toggleButton: ToggleButton, didChangePosition position: ToggleButton.Position)
}

// MARK: - Main Class
@IBDesignable
open class ToggleButton: UIControl {
    
    // MARK: - Enums
    public enum Position: Int {
        case left
        case right
    }
    
    public enum ContentSizeMode: Int {
        case wrapText
        case equalize
    }
    
    // MARK: - IBInspectables
    @IBInspectable
    public var selectedTextColor: UIColor = .white {
        didSet {
            selectedTextColorDidChange()
        }
    }
    
    @IBInspectable
    public var leftTitle: String = "First" {
        didSet {
            leftTitleDidChange()
        }
    }
    
    @IBInspectable
    public var rightTitle: String = "Second" {
        didSet {
            rightTitleDidChange()
        }
    }

    @IBInspectable
    public var textHorizontalSpacing: CGFloat = 5 {
        didSet {
            updateTextSpacing()
        }
    }

    @IBInspectable
    public var textVerticalSpacing: CGFloat = 5 {
        didSet {
            updateTextSpacing()
        }
    }
    
    // MARK: - Variables
    open var leftTitleLabel: PaddingLabel?
    open var rightTitleLabel: PaddingLabel?
    
    open var thumbView: UIView!
    open var innerView: UIView!
    
    open weak var delegate: ToggleButtonDelegate?
    
    open var isAnimationEnabled: Bool = true
    open var toggleAnimationDuration: TimeInterval = 0.3
    
    public var isRoundCorner: Bool = true {
        didSet {
            isRoundCornerDidChange()
        }
    }
    
    public var cornerRadius: CGFloat = 0.0 {
        didSet {
            cornerRadiusDidChange()
        }
    }
    
    public var defaultPosition: Position = .left {
        didSet {
            defaultPositionDidChange()
        }
    }
    
    private var _currentPosition: Position = .left
    public var currentPosition: Position {
        get {
            return _currentPosition
        }
    }
    
    public var contentSizeMode: ContentSizeMode = .wrapText {
        didSet {
            contentSizeModeDidChange()
        }
    }

    private var leftLabelEqualWidthRightLabelConstraint: NSLayoutConstraint?
    private var thumbViewEqualWidthLeftLabelConstraint: NSLayoutConstraint?
    private var thumbViewEqualWidthRightLabelConstraint: NSLayoutConstraint?
    private var thumbViewLeadingConstraint: NSLayoutConstraint?
    private var isToggling: Bool = false
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupViews()
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        updateToggleButtonUI()
    }
    
    private func setupViews() {
        // Views
        initInnerView()
        initThumbView()
        initLabels()
        
        // Layers
        innerView.layer.borderWidth = 1
        
        // Events
        tintColorDidChange()
        isRoundCornerDidChange()
        currentPositionDidChange(animated: false)
        contentSizeModeDidChange()
        
        addTarget(self, action: #selector(onClickToggleButton(_:)), for: .touchUpInside)
    }
    
    // MARK: - View Functions
    private func initThumbView() {
        thumbView = UIView(frame: .zero)
        thumbView.isUserInteractionEnabled = false
        
        thumbView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(thumbView)
        
        let topConstraint = NSLayoutConstraint(item: thumbView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        topConstraint.isActive = true
        
        let bottomConstraint = NSLayoutConstraint(item: thumbView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        bottomConstraint.isActive = true
        
        thumbViewLeadingConstraint = NSLayoutConstraint(item: thumbView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        thumbViewLeadingConstraint?.isActive = true
        
        thumbView.setNeedsLayout()
    }
    
    private func initInnerView() {
        innerView = UIView(frame: .zero)
        innerView.isUserInteractionEnabled = false
        
        innerView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(innerView)
        
        let topConstraint = NSLayoutConstraint(item: innerView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        topConstraint.isActive = true
        
        let bottomConstraint = NSLayoutConstraint(item: innerView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        bottomConstraint.isActive = true
        
        let leadingConstraint = NSLayoutConstraint(item: innerView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        leadingConstraint.isActive = true
        
        let trailingConstraint = NSLayoutConstraint(item: innerView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        trailingConstraint.isActive = true
        
        innerView.setNeedsLayout()
    }
    
    private func initLabels() {
        // Setup left title label
        leftTitleLabel = PaddingLabel(frame: .zero)
        guard let `leftTitleLabel` = leftTitleLabel else {
            return
        }

        leftTitleLabel.textAlignment = .center
        leftTitleLabel.baselineAdjustment = .alignCenters
        leftTitleLabel.padding = UIEdgeInsets.init(top: textVerticalSpacing, left: textHorizontalSpacing, bottom: textVerticalSpacing, right: textHorizontalSpacing)
        leftTitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        // Setup right title label
        rightTitleLabel = PaddingLabel(frame: .zero)
        guard let `rightTitleLabel` = rightTitleLabel else {
            return
        }

        rightTitleLabel.textAlignment = .center
        rightTitleLabel.baselineAdjustment = .alignCenters
        rightTitleLabel.padding = UIEdgeInsets.init(top: textVerticalSpacing, left: textHorizontalSpacing, bottom: textVerticalSpacing, right: textHorizontalSpacing)
        rightTitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        // Add subviews
        leftTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        rightTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(leftTitleLabel)
        addSubview(rightTitleLabel)

        // Update constraints
        let leftViewleadingConstraint = NSLayoutConstraint(item: leftTitleLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        leftViewleadingConstraint.isActive = true
        
        let rightViewLeadingConstraint = NSLayoutConstraint(item: rightTitleLabel, attribute: .left, relatedBy: .equal, toItem: leftTitleLabel, attribute: .right, multiplier: 1, constant: 0)
        rightViewLeadingConstraint.isActive = true
    
        let rightViewTrailingConstraint = NSLayoutConstraint(item: rightTitleLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        rightViewTrailingConstraint.isActive = true
        
        let leftViewTopConstraint = NSLayoutConstraint(item: leftTitleLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        leftViewTopConstraint.isActive = true
        
        let rightViewTopConstraint = NSLayoutConstraint(item: rightTitleLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        rightViewTopConstraint.isActive = true
        
        let leftViewBottomConstraint = NSLayoutConstraint(item: leftTitleLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        leftViewBottomConstraint.isActive = true
        
        let rightViewBottomConstraint = NSLayoutConstraint(item: rightTitleLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        rightViewBottomConstraint.isActive = true

        leftTitleDidChange()
        rightTitleDidChange()
    }
    
    private func updateToggleButtonUI() {
        updateTextColor()
        updateThumbViewFrame()
    }
    
    private func updateTextColor() {
        switch currentPosition {
            
        case .left:
            leftTitleLabel?.textColor = selectedTextColor
            rightTitleLabel?.textColor = tintColor
            
        case .right:
            leftTitleLabel?.textColor = tintColor
            rightTitleLabel?.textColor = selectedTextColor
        }
    }

    private func updateThumbViewFrame() {
        if thumbViewEqualWidthLeftLabelConstraint == nil {
            thumbViewEqualWidthLeftLabelConstraint = NSLayoutConstraint(item: thumbView, attribute: .width, relatedBy: .equal, toItem: leftTitleLabel, attribute: .width, multiplier: 1, constant: 0)
        }

        if thumbViewEqualWidthRightLabelConstraint == nil {
            thumbViewEqualWidthRightLabelConstraint = NSLayoutConstraint(item: thumbView, attribute: .width, relatedBy: .equal, toItem: rightTitleLabel, attribute: .width, multiplier: 1, constant: 0)
        }

        switch currentPosition {

        case .left:
            thumbViewEqualWidthLeftLabelConstraint?.isActive = true
            thumbViewEqualWidthRightLabelConstraint?.isActive = false
            thumbViewLeadingConstraint?.constant = 0
            
        case .right:
            thumbViewEqualWidthLeftLabelConstraint?.isActive = false
            thumbViewEqualWidthRightLabelConstraint?.isActive = true

            thumbViewLeadingConstraint?.constant = leftTitleLabel?.bounds.size.width ?? 0
        }
        
        thumbView.setNeedsLayout()
    }

    private func updateTextSpacing() {
        rightTitleLabel?.padding = UIEdgeInsets.init(top: textVerticalSpacing, left: textHorizontalSpacing, bottom: textVerticalSpacing, right: textHorizontalSpacing)
        leftTitleLabel?.padding = UIEdgeInsets.init(top: textVerticalSpacing, left: textHorizontalSpacing, bottom: textVerticalSpacing, right: textHorizontalSpacing)
    }
    
    // MARK: - Events
    override open func tintColorDidChange() {
        super.tintColorDidChange()
        
        thumbView.backgroundColor = tintColor
        innerView.layer.borderColor = tintColor.cgColor
        
        updateTextColor()
    }
    
    open func selectedTextColorDidChange() {
        updateTextColor()
    }
    
    open func isRoundCornerDidChange() {
        if isRoundCorner {
            cornerRadius = bounds.size.height / 2.0
        } else {
            cornerRadius = 0.0
        }
    }
    
    open func cornerRadiusDidChange() {
        innerView.layer.cornerRadius = cornerRadius
        thumbView.layer.cornerRadius = cornerRadius
    }

    open func leftTitleDidChange() {
        leftTitleLabel?.text = leftTitle
        
        leftTitleLabel?.sizeToFit()
        leftTitleLabel?.setNeedsLayout()
    }
    
    open func rightTitleDidChange() {
        rightTitleLabel?.text = rightTitle
        
        rightTitleLabel?.sizeToFit()
        rightTitleLabel?.setNeedsLayout()
    }

    open func contentSizeModeDidChange() {
        guard let `leftTitleLabel` = leftTitleLabel else {
            return
        }

        guard let `rightTitleLabel` = rightTitleLabel else {
            return
        }

        if leftLabelEqualWidthRightLabelConstraint == nil {
            leftLabelEqualWidthRightLabelConstraint = NSLayoutConstraint(item: leftTitleLabel, attribute: .width, relatedBy: .equal, toItem: rightTitleLabel, attribute: .width, multiplier: 1, constant: 0)
        }
        
        switch contentSizeMode {
            
        case .equalize:
            leftLabelEqualWidthRightLabelConstraint?.priority = .required
            leftLabelEqualWidthRightLabelConstraint?.isActive = true
            
        case .wrapText:
            leftLabelEqualWidthRightLabelConstraint?.isActive = false
        }
        
        leftTitleLabel.setNeedsLayout()
        rightTitleLabel.setNeedsLayout()

        updateThumbViewFrame()
        
        layoutIfNeeded()
    }
    
    open func defaultPositionDidChange() {
        _currentPosition = defaultPosition
        updateToggleButtonUI()
    }
    
    open func currentPositionDidChange(animated: Bool = true) {
        if isToggling {
            return
        }
        
        isToggling = true
        
        updateToggleButtonUI()
        
        if animated {
            UIView.animate(withDuration: toggleAnimationDuration, animations: { [weak self] in
                
                guard let `self` = self else { return }
                self.layoutIfNeeded()
                
            }) { [weak self] (success) in
                
                guard let `self` = self else { return }
                self.isToggling = false
                self.delegate?.toggleButton(self, didChangePosition: self.currentPosition)
            }
        } else {
            layoutIfNeeded()
            isToggling = false
            delegate?.toggleButton(self, didChangePosition: currentPosition)
        }
    }
    
    open func `switch`(toPosition position: Position, animated: Bool = true) {
        if currentPosition == position {
            return
        }
        
        _currentPosition = position
        currentPositionDidChange(animated: animated)
    }
    
    open func smoothSwitch(toPosition position: Position) {
        if currentPosition != position {
            _currentPosition = position
            currentPositionDidChange(animated: true)
        }
    }
    
    @objc private func onClickToggleButton(_ sender: Any) {
        switch currentPosition {
            
        case .left:
            _currentPosition = .right
            
        case .right:
            _currentPosition = .left
        }
        
        currentPositionDidChange()
    }
}
