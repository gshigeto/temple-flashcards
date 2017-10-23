//
//  TempleCardView.swift
//  Temple Flashcards
//
//  Created by Gavin Nitta on 10/16/17.
//  Copyright © 2017 Gavin Nitta. All rights reserved.
//

import UIKit

@IBDesignable
class TempleCardView : UIView {
    
    // MARK: - Constants
    private struct Storyboard {
        static let TempleTableViewCell = "TempleTableViewCell"
    }
    
    // MARK: - Properties
    var temple: Temple = Temple()
    var label: UILabel = UILabel()
    
    @IBInspectable var filename: String = ""
    @IBInspectable var name: String = ""
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    private func setup() {
        backgroundColor = UIColor.white
        isOpaque = false
    }
    
    // MARK: - Drawing
    override func draw(_ rect: CGRect) {
        drawTemple()
    }
    
    // MARK: - Private Functions
    private func buildLabel() {
        label = UILabel(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 40))
        label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        label.textColor = UIColor.white
        label.textAlignment = .center;
        label.font = UIFont(name: "Montserrat-Light", size: 9.0)
        label.text = temple.name
        label.adjustsFontSizeToFitWidth = true
        self.addSubview(label)
    }
    
    private func drawTemple() {
        UIImage(named: temple.filename)?.draw(in: bounds.insetBy(dx: 5, dy: 5))
        removeSubviews()
        if TempleDeck.sharedInstance.showLabel {
            buildLabel()
        }
    }
    
    private func removeSubviews() {
        for sub in self.subviews {
            sub.removeFromSuperview()
        }
    }
}
