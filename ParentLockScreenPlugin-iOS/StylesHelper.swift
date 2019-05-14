//
//  StylesHelper.swift
//  ParentLockScreenPlugin
//
//  Created by Miri Vecselboim on 28/03/2019.
//

import Foundation
import ZappPlugins

class StylesHelper: NSObject {
    
    //Color
    public static func setColorforLabel(label: UILabel, key:String, from dictionary:[String : Any]?) {
        if let dictionary = dictionary,
            let argbString = dictionary[key] as? String,
            !argbString.isEmptyOrWhitespace() {
            let color = UIColor(argbHexString: argbString)
            label.textColor = color
        }
    }
    
    public static func setColorforButton(button: UIButton, key:String,from dictionary:[String : Any]?, for state:UIControl.State) {
        if let dictionary = dictionary,
            let argbString = dictionary[key] as? String,
            !argbString.isEmptyOrWhitespace() {
            let color = UIColor(argbHexString: argbString)
            button.setTitleColor(color, for: state)
        }
    }
    
    public static func setColorforView(view: UIView, key:String, from dictionary:[String : Any]?) {
        if let dictionary = dictionary,
            let argbString = dictionary[key] as? String,
            !argbString.isEmptyOrWhitespace() {
            let color = UIColor(argbHexString: argbString)
            view.backgroundColor = color
        }
    }
    
    // Font
    public static func setFontforLabel(label: UILabel, fontNameKey:String, fontSizeKey:String, from dictionary:[String : Any]?) {
        var font = UIFont.systemFont(ofSize: 10)
        if let dictionary = dictionary,
            let fontName = dictionary[fontNameKey] as? String,
            let fontSizeString = dictionary[fontSizeKey] as? String,
            let fontSize = CGFloat(fontSizeString),
            let tempFont = UIFont(name: fontName, size: fontSize) {
            font = tempFont
        }
        label.font = font
    }
    
    public static func setFontforButton(button: UIButton, fontNameKey:String, fontSizeKey:String, from dictionary:[String : Any]?) {
        var font = UIFont.systemFont(ofSize: 10)
        if let dictionary = dictionary,
            let fontName = dictionary[fontNameKey] as? String,
            let fontSizeString = dictionary[fontSizeKey] as? String,
            let fontSize = CGFloat(fontSizeString),
            let tempFont = UIFont(name: fontName, size: fontSize) {
            font = tempFont
        }
        button.titleLabel?.font = font
    }
    
    public static func getColorForKey(key:String, from dictionary:[String : Any]?) -> UIColor {
        var color:UIColor
        if let dictionary = dictionary,
            !key.isEmptyOrWhitespace(),
            let argbString = dictionary[key] as? String,
            !argbString.isEmptyOrWhitespace() {
            color = UIColor(argbHexString: argbString)
        } else {
            color = UIColor.clear
        }
        return color
    }
    
    public static func image(for Key:String, using dictionary:[String:Any]) -> UIImage? {
        var retVal : UIImage?
        if let backgroundImageString = dictionary[Key] as? String,
            let backgroundImageUrl = URL.init(string: backgroundImageString) {
            let backgroundImage = UIImageView.init()
            ZAAppConnector.sharedInstance().imageDelegate.setImage(to: backgroundImage, url: backgroundImageUrl, placeholderImage: nil)
            //let backgroundImage = APImageView.init()
            //backgroundImage.setImageWith(backgroundImageUrl)
            retVal = backgroundImage.image
        }
        return retVal
    }
}

