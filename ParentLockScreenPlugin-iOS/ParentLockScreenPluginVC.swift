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
    var pluginGeneralSettings: [String : Any]?
    var pluginStyles: [String : Any]?
    let NumbersDictionary = ["1":"One","2":"Two","3":"Three","4":"Four","5":"Five","6":"Six","7":"Seven","8":"Eight","9":"Nine"]
    let localizationDelegate: ZAAppDelegateConnectorLocalizationProtocol
    let ParentLockScreenNumberLimit = 3;
    let cornerRadius: CGFloat = 0.5;
    
    @IBOutlet weak var closeView: UIControl!
    @IBOutlet weak var numberLuckView: UIView!
    @IBOutlet weak var backgroundImageView: APImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var randomNumbersLabel: UILabel!
    @IBOutlet weak var dotsContainerView: UIView!
    @IBOutlet var dotImagesCollection: [APImageView]!
    @IBOutlet var numberButtonsCollection: [UIButton]!
    @IBOutlet weak var numberButtonsContainer: UIView!
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        generatedValues = []
        enterdValues = []
        isVlidated = false
        localizationDelegate = ZAAppConnector.sharedInstance().localizationDelegate
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        generateValues()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureScreenUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        enterdValues.removeAll()
    }
    
    required convenience init?(pluginModel: ZPPluginModel, screenModel: ZLScreenModel, dataSourceModel: NSObject?) {
        self.init(nibName: "ParentLockScreenPluginVC", bundle: Bundle(for: type(of: self)))
        pluginGeneralSettings = screenModel.general
        if let styles = screenModel.style {
            pluginStyles = styles.object
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setNumberButtons() {
        UIButton.normalBackgroundColor = StylesHelper.getColorForKey(key: "number_color", from: pluginStyles)
        UIButton.highlighteBackgroudColor = StylesHelper.getColorForKey(key: "number_color_pressed", from: pluginStyles)
        for button in numberButtonsCollection {
            button.layer.cornerRadius = cornerRadius * button.bounds.size.width
            button.clipsToBounds = true
            button.layer.borderWidth = 2
            if let pluginStyles = pluginStyles {
                button.layer.borderColor = StylesHelper.getColorForKey(key: "number_buttons_selected_background_color", from: pluginStyles).cgColor
                StylesHelper.setFontforButton(button: button, fontNameKey: "font", fontSizeKey: "number_font_size", from: pluginStyles)
            }
            if let buttonNumber = numberButtonsCollection.firstIndex(of: button) {
                button.setTitle(String(buttonNumber + 1), for: .normal)
                button.isHidden = numberOfValidationDigitsToPresent() > buttonNumber ? false : true
            }
        }
    }
    
    func configureScreenUI() {
        setIndicatorsToMainColor()
        setNumberButtons()
        if let pluginGeneralSettings = pluginGeneralSettings {
            if let screenBackgroundImageString = pluginGeneralSettings["background_image"] as? String {
                if let screenBackgroundImageUrl = URL.init(string: screenBackgroundImageString) {
                self.backgroundImageView.setImageWith(screenBackgroundImageUrl)
                }
            } else {
                let screenBackgroundColor = StylesHelper.getColorForKey(key: "background_color", from: pluginGeneralSettings)
                self.backgroundImageView.backgroundColor = screenBackgroundColor
            }
            if let closeButtonImageString = pluginGeneralSettings["close_button"] as? String,
                let closeButtonImageUrl = URL.init(string: closeButtonImageString),
                let imageView = closeButton.imageView {
                ZAAppConnector.sharedInstance().imageDelegate.setImage(to: imageView, url: closeButtonImageUrl, placeholderImage: nil)
            }
        }
    }
    
    func setInfoLabel() {
        if let pluginStyles = pluginStyles {
            StylesHelper.setFontforLabel(label: self.infoLabel, fontNameKey: "font", fontSizeKey: "call_for_action_text_font_size", from: pluginStyles)
            StylesHelper.setColorforLabel(label: self.infoLabel, key: "call_for_action_text_color", from: pluginStyles)
        }
        infoLabel.text = localizationDelegate.localizationString(byKey: "NumbersLockInstructionsLocalizationKey", defaultString: "")
    }
    
    func numberOfValidationDigitsToPresent() -> Int {
        let defaultNumberOfValidationDigits = 3;
        var validationDigits:Int = 3;
        if let pluginGeneralSettings = pluginGeneralSettings,
            let numberOfValidationButtons = pluginGeneralSettings["validation_flow_type"] as? String {
            validationDigits = Int(numberOfValidationButtons) ?? defaultNumberOfValidationDigits
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
        //set text font font size size and color
        randomNumbersLabel.text = generatedValuesLocalizedArray.joined(separator: ", ")
        StylesHelper.setColorforLabel(label: randomNumbersLabel, key: "random_numbers_color", from: pluginStyles)
        StylesHelper.setFontforLabel(label: randomNumbersLabel, fontNameKey: "font", fontSizeKey: "random_numbers_font_size", from: pluginStyles)
    }
    
    @IBAction func handleUserPushCloseButton(_ sender: UIButton) {
        self.dismissPushAnimated()
    }
    
    @IBAction func handleUserPushNumberButton(_ sender: UIButton) {
        if let number = self.numberButtonsCollection.firstIndex(of: sender) {
            updateIndicatorAtIndex(index: enterdValues.count)
            enterdValues.append(String(number + 1))
            if enterdValues.count == ParentLockScreenNumberLimit {
                if enterdValues == generatedValues {
                    self.isVlidated = true
                    self.dismiss(animated: true) {
                        //send notification of successfull login
                    }
                } else {
                    generatedValues.removeAll()
                    generateValues()
                }
                enterdValues.removeAll()
                clearValidationIndicators()
            }
        }
    }
    
    func clearValidationIndicators() {
        if let pluginGeneralSettings = pluginGeneralSettings {
            for dot in dotImagesCollection {
                dot.backgroundColor = StylesHelper.getColorForKey(key: "indicator_main_color", from: pluginGeneralSettings)
            }
        }
    }
    
    func setIndicatorsToMainColor() {
        for dot in dotImagesCollection {
            dot.layer.cornerRadius = cornerRadius * dot.bounds.size.width
            dot.clipsToBounds = true
            dot.layer.borderWidth = 1
            dot.layer.borderColor = StylesHelper.getColorForKey(key: "number_buttons_selected_background_color", from: pluginStyles).cgColor
        }
        clearValidationIndicators()
    }
    
    func updateIndicatorAtIndex(index:Int) {
        if let pluginGeneralSettings = pluginGeneralSettings {
            let dot = self.dotImagesCollection[index]
            dot.backgroundColor = StylesHelper.getColorForKey(key: "indicator_secondary_color", from: pluginGeneralSettings)
        }
    }
}

extension UIButton {

    public static var normalBackgroundColor:UIColor?
    public static var highlighteBackgroudColor:UIColor?

    override open var isHighlighted: Bool {
        didSet {
            if let normalBackgroundColor = UIButton.normalBackgroundColor, let highlighteBackgroudColor = UIButton.highlighteBackgroudColor {
                backgroundColor = isHighlighted ? highlighteBackgroudColor : normalBackgroundColor
            } else {
                backgroundColor =  UIColor.clear
            }
        }
    }
}





