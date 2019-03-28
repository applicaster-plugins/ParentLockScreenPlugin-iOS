//
//  ParentLockScreenPluginVC.swift
//  ParentLockScreenPlugin-iOS
//
//  Created by Roi Kedarya on 24/03/2019.
//  Copyright © 2019 applicaster. All rights reserved.
//

import ApplicasterSDK
import ZappPlugins

class ParentLockScreenPluginVC: UIViewController,ZPPluggableScreenProtocol {
    
    var screenPluginDelegate: ZPPlugableScreenDelegate?
    
    var numberOfValidationButtons:String?
    var dataSourceModel: NSObject?
    var isVlidated:Bool!
    var generatedValues: [String]
    var enterdValues: [String]
    var vlidationType: String?
    var pluginConfig: [String : Any]?
    var pluginStyles: [String : Any]?
    let NumbersDictionary = ["1":"One","2":"Two","3":"Three","4":"Four","5":"Five","6":"Six","7":"Seven","8":"Eight","9":"Nine"]
    let localizationDelegate: ZAAppDelegateConnectorLocalizationProtocol
    let ParentLockScreenNumberLimit = 3;
    
    @IBOutlet weak var closeView: UIControl!
    @IBOutlet weak var numberLuckView: UIView!
    @IBOutlet weak var backgroundImageView: APImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var randomNumbersLabel: UILabel!
    @IBOutlet weak var dotsContainerView: UIView!
    @IBOutlet var dotImagesCollection: [APImageView]!
    @IBOutlet var numberButtonsCollection: [UIButton]!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        generatedValues = []
        enterdValues = []
        isVlidated = false
        localizationDelegate = ZAAppConnector.sharedInstance().localizationDelegate
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configureScreenUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        generateValues()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        enterdValues.removeAll()
    }
    
    required convenience init?(pluginModel: ZPPluginModel, screenModel: ZLScreenModel, dataSourceModel: NSObject?) {
        self.init(nibName: "ParentLockScreenPluginVC", bundle: Bundle(for: type(of: self)))
        pluginConfig = screenModel.general
        if let styles = screenModel.style {
            pluginStyles = styles.object
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setNumberButtons() {
        UIButton.normalColor = UIColor.clear
        UIButton.highlightedColor = UIColor.purple
        for button in numberButtonsCollection {
            button.layer.cornerRadius = 0.5 * button.bounds.size.width
            button.clipsToBounds = true
            button.layer.borderColor = UIColor.yellow.cgColor
            button.layer.borderWidth = 2
            if let pluginStyles = pluginStyles {
                StylesHelper.setFontforButton(button: button, fontNameKey: "font", fontSizeKey: "number_font_size", from: pluginStyles)
                StylesHelper.setColorforButton(button: button, key: "number_buttons_title_color", state: .normal, from: pluginStyles)
                StylesHelper.setColorforButton(button: button, key: "number_buttons_title_color_selected", state: .highlighted, from: pluginStyles)
            }
            if let buttonNumber = numberButtonsCollection.firstIndex(of: button) {
                button.setTitle(String(buttonNumber + 1), for: .normal)
            }
        }
    }
    
    func configureScreenUI() {
        setNumberButtons()
        if let pluginStyles = pluginStyles {
            if let backgroundImage = pluginStyles["background_image"] as? String {
                
            } else if let backgroundColor = pluginStyles["background_color"] as? String {
                let screenBackgroundColor = UIColor(hex: backgroundColor)
                self.numberLuckView.backgroundColor = screenBackgroundColor
            }
            if let pluginConfig = pluginConfig,
                let closeButtonImageString = pluginConfig["close_button"] as? String {
                let closeImage = UIImage.init(named: closeButtonImageString)
                self.closeButton.setImage(closeImage, for: .normal)
            }
        }
    }
    
    func setInfoLabel() {
        if let pluginStyles = pluginStyles {
            StylesHelper.setFontforLabel(label: self.infoLabel, fontNameKey: "font", fontSizeKey: <#T##String#>, from: <#T##[String : Any]?#>)
        }
    }
    
    func numberOfValidationDigitsToPresent() -> Int {
        let defaultNumberOfValidationDigits = 3;
        var validationDigits:Int = 3;
        if let pluginConfig = pluginConfig,
            let numberOfValidationButtons = pluginConfig["validation_flow_type"] as? String {
            validationDigits = Int(numberOfValidationButtons) ?? defaultNumberOfValidationDigits
        } else {
            validationDigits = 9
        }
        return validationDigits
    }
    
    func generateValues() {
        var generatedValuesLocalizedArray = [String]()
        for _ in 1...ParentLockScreenNumberLimit {
            let generatedValue = String(Int.random(in: 1 ... numberOfValidationDigitsToPresent()))
            generatedValues.append(generatedValue)
            if let stringGeneratedValue = NumbersDictionary[generatedValue] {
                let stringGeneratedValueKey = "Number\(stringGeneratedValue)"
                if let localizedValue = self.localizationDelegate.localizationString(byKey: stringGeneratedValueKey, defaultString: stringGeneratedValue) {
                    generatedValuesLocalizedArray.append(localizedValue)
                }
            }
        }
        randomNumbersLabel.text = generatedValuesLocalizedArray.joined(separator: ", ")
    }
    
    @IBAction func handleUserPushCloseButton(_ sender: UIButton) {
        self.dismissPushAnimated()
    }
    
    @IBAction func handleUserPushNumberButton(_ sender: UIButton) {
        if let number = self.numberButtonsCollection.firstIndex(of: sender) {
            enterdValues.append(String(number + 1))
            if enterdValues.count == ParentLockScreenNumberLimit {
                if enterdValues == generatedValues {
                    self.isVlidated = true
                } else {
                    enterdValues.removeAll()
                }
            }
        }
    }
    
}

extension UIButton {
    
    public static var normalColor:UIColor?
    public static var highlightedColor:UIColor?
    
    override open var isHighlighted: Bool {
        didSet {
            if let normalColor = UIButton.normalColor, let highlightedColor = UIButton.highlightedColor {
                backgroundColor = isHighlighted ? highlightedColor : normalColor
            } else {
                backgroundColor = isHighlighted ? UIColor.black : UIColor.white
            }
        }
    }
}





