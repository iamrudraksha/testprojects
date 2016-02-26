//
//  WelcomeScreenContentViewController.swift
//  CardinalHealth
//
//  Created by Volkov Alexander on 22.06.15.
//  Modified by Volkov Alexander on 16.07.15.
//  Modified by Volkov Alexander on 22.09.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* One of the pages in Welcome Screen
*
* @author Alexander Volkov
* @version 1.2
*
* changes:
* 1.1:
* - font size fix
* 1.2:
* - line spacing changed (due to "ideas" to "actions" replacement the text takes an additional line)
*/
class WelcomeScreenContentViewController: UIViewController {

    /// the size of the image for iPhone5
    let SMALL_SCREEN_IMAGE_SIZE: CGFloat = 240
    
    @IBOutlet weak var largeImage: UIImageView!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentTextLabel: UILabel!
    @IBOutlet weak var boldLabel: UILabel!

    /// the index of the page
    var itemIndex: Int!
    /// data for UI
    var content: WelcomeScreenContent!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    /**
    Update UI with content data
    */
    func updateUI() {
        largeImage.image = content.contentImage

        var titleFontSize: CGFloat = 29
        var textFontSize: CGFloat = 14.5
        if isIPhone5() {
            titleFontSize = 20
            textFontSize = 12
        }
        let titleFont = UIFont(name: Fonts.lightItalic, size: titleFontSize)!
        let title = NSMutableAttributedString(string: content.title ?? "", attributes: [
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSFontAttributeName: titleFont
            ])
        titleLabel.attributedText = title
        
        let str = content.contentText ?? ""

        let textFont = UIFont(name: Fonts.regular, size: textFontSize)!
        let paragrahStyle = NSMutableParagraphStyle()
        paragrahStyle.lineSpacing = 2
        let string = NSMutableAttributedString(string: str, attributes: [
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSFontAttributeName: textFont,
            NSParagraphStyleAttributeName: paragrahStyle
        ])
        contentTextLabel.attributedText = string
        
        boldLabel.text = content.boldText
        if isIPhone5() {
            imageWidth.constant = SMALL_SCREEN_IMAGE_SIZE
            imageHeight.constant = SMALL_SCREEN_IMAGE_SIZE
        }
    }
}
