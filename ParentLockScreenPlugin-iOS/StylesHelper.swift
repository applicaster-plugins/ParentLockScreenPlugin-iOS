//
//  StylesHelper.swift
//  ParentLockScreenPlugin
//
//  Created by Miri Vecselboim on 28/03/2019.
//

import ApplicasterSDK
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
            let backgroundImage = APImageView()
            backgroundImage.setImageWith(backgroundImageUrl)
            retVal = backgroundImage.image
        }
        return retVal
    }
    
    static private let backgroundImageIphone_568 = "parent_lock_background_image_568h"
    static private let backgroundImageIphone_667 = "parent_lock_background_image_667h"
    static private let backgroundImageIphone_736 = "parent_lock_background_image_736h"
    static private let backgroundImageIphone_812 = "parent_lock_background_image_812h"
    static private let backgroundImageIpadNonRetina_1024  = "parent_lock_background_image_landscape~ipad"
    static private let backgroundImageIpad_1024  = "parent_lock_background_image_landscape@2x~ipad"
    static private let backgroundImageIpad_1024_portrait  = "parent_lock_background_image_portrait@2x~ipad"
    static private let backgroundImageIpad_1366_portrait  = "parent_lock_background_image_1366h_portrait@2x~ipad"
    static private let backgroundImageIpad_1366 = "parent_lock_background_image_1366h@2x~ipad"
    
    @objc public class func localSplashImageNameForScreenSize() -> String {
        var retVal = ""
        
        let devicePortraitWidth = APScreenMultiplierConverter.deviceWidth()
        let devicePortraitHeight = APScreenMultiplierConverter.deviceHeight()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            retVal = backgroundImageIpad_1024
            
            if devicePortraitWidth == 768 {
                if UIScreen.main.scale >= 2.0 {
                    if UIApplication.shared.statusBarOrientation.isLandscape {
                        retVal = backgroundImageIpad_1024
                    } else {
                        retVal = backgroundImageIpad_1024_portrait
                    }
                } else {
                    retVal = backgroundImageIpadNonRetina_1024
                }
            } else if devicePortraitWidth == 1024 {
                if UIApplication.shared.statusBarOrientation.isLandscape {
                    retVal = backgroundImageIpad_1366
                } else {
                    retVal = backgroundImageIpad_1366_portrait
                }
            }
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            retVal = backgroundImageIphone_568
            if devicePortraitWidth == 320 {
                let size = UIScreen.main.bounds.size
                if size.width == 568 || size.height == 568 {
                    retVal = backgroundImageIphone_568
                }
            } else if devicePortraitWidth == 375 {
                if devicePortraitHeight == 812 {
                    retVal = backgroundImageIphone_812
                }
                else {
                    retVal = backgroundImageIphone_667
                }
            } else if devicePortraitWidth == 414 {
                retVal = backgroundImageIphone_736
            }
        }
        return retVal
    }
}

