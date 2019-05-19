//
//  ParentLockScreenPluginVC.swift
//  ParentLockScreenPlugin-iOS
//
//  Created by Roi Kedarya on 24/03/2019.
//  Copyright © 2019 applicaster. All rights reserved.
//

import ApplicasterSDK
import ZappPlugins

public typealias HookCompletion = (Bool, NSError?, [String : Any]?) -> Void

class ParentLockScreenPluginVC: UIViewController,ZPPluggableScreenProtocol,ZPScreenHookAdapterProtocol {

    var screenPluginDelegate: ZPPlugableScreenDelegate?
    var pluginModel: ZPPluginModel?
    var hookCompletion:HookCompletion?
    var dataSourceModel: NSObject?
    var numberOfValidationButtons:Int?
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
    let isFlowBlocker: Bool = true
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var containerImageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var randomNumbersLabel: UILabel!
    @IBOutlet weak var secondaryRandomNumbersLabel: UILabel!
    @IBOutlet weak var dotsContainerView: UIView!
    @IBOutlet var dotImagesCollection: [APImageView]!
    @IBOutlet var numberButtonsCollection: [UIButton]!
    @IBOutlet weak var secondButtonsRow: UIStackView!
    @IBOutlet weak var thirdButtonsRow: UIStackView!
    
    //MARK: - ZPPluggableScreenProtocol
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        generatedValues = []
        enterdValues = []
        isVlidated = false
        localizationDelegate = ZAAppConnector.sharedInstance().localizationDelegate
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required convenience init?(pluginModel: ZPPluginModel, screenModel: ZLScreenModel, dataSourceModel: NSObject?) {
        self.init(nibName: "ParentLockScreenPluginVC", bundle: Bundle(for: type(of: self)))
        pluginGeneralSettings = screenModel.general
        self.pluginModel = pluginModel
        if let styles = screenModel.style {
            pluginStyles = styles.object
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - ZPScreenHookAdapterProtocol
    
    func executeHook(presentationIndex: NSInteger, dataDict: [String : Any]?, taskFinishedWithCompletion: @escaping (Bool, NSError?, [String : Any]?) -> Void) {
        hookCompletion = taskFinishedWithCompletion
    }

    required convenience init?(pluginModel: ZPPluginModel, dataSourceModel: NSObject?) {
        self.init(nibName: "ParentLockScreenPluginVC", bundle: Bundle(for: type(of: self)))
        self.pluginModel = pluginModel
        self.dataSourceModel = dataSourceModel
    }
    
    func hookPluginDidDisappear(viewController: UIViewController) {
        if let hookCompletion = self.hookCompletion {
            let error = NSError(domain: "User has closed hook execution failed", code: 0, userInfo: nil)
            hookCompletion(false, error, nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateValues()
        configureScreenUI()
        setCloseButtonImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        enterdValues.removeAll()
    }
    
    //MARK: - UI configurations and private helper methods
    
    private func setNumberButtons() {
        for button in numberButtonsCollection {
            if let backgroundImage = UIImage(named: "number_btn_not_selected_bg") {
                button.setBackgroundImage(backgroundImage, for: .normal)
                if let selectedBackgroundImage = UIImage(named: "number_btn_selected_bg") {
                    button.setBackgroundImage(selectedBackgroundImage, for: .highlighted)
                }
            } else {
                button.layer.cornerRadius = cornerRadius * button.bounds.size.width
                button.clipsToBounds = true
                button.layer.borderWidth = 2
                button.layer.borderColor = StylesHelper.getColorForKey(key: "number_buttons_selected_background_color", from: pluginStyles).cgColor
            }
            if let pluginStyles = pluginStyles {
                StylesHelper.setColorforButton(button: button, key: "number_color", from: pluginStyles, for: .normal)
                StylesHelper.setColorforButton(button: button, key: "number_color_pressed", from: pluginStyles, for: UIControl.State.highlighted)
                StylesHelper.setFontforButton(button: button, fontNameKey: "font", fontSizeKey: "number_font_size", from: pluginStyles)
            }
            if let buttonNumber = numberButtonsCollection.firstIndex(of: button) {
                button.setTitle(String(buttonNumber + 1), for: .normal)
            }
        }
        let numberOfValidationDigitsToPresent = self.numberOfValidationDigitsToPresent()
        secondButtonsRow.isHidden = numberOfValidationDigitsToPresent == 3
        thirdButtonsRow.isHidden = numberOfValidationDigitsToPresent == 3
    }
    
    private func configureScreenUI() {
        setIndicatorsToMainColor()
        setNumberButtons()
        setInfoLabel()
        let containerBackgroundImageName = (numberOfValidationDigitsToPresent() == 3) ? "background_image_1_3" : "background_image_1_9"
        if  let containerBackgroundImage = UIImage(named: containerBackgroundImageName) {
            self.containerImageView.image = containerBackgroundImage
        }
        if let parentLockscreenBackgroundImage = UIImage(named: "parent_lock_background_image_736h") {
            self.backgroundImageView.image = parentLockscreenBackgroundImage
        }
        if let pluginGeneralSettings = pluginGeneralSettings {
            let screenBackgroundColor = StylesHelper.getColorForKey(key: "background_color", from: pluginGeneralSettings)
            self.backgroundImageView.backgroundColor = screenBackgroundColor
        }
    }
    
    private func setCloseButtonImage() {
        if let closeButtonImage = UIImage(named: "close_button") {
            closeButton.setImage(closeButtonImage, for: .normal)
        }
    }
    
    private func setInfoLabel() {
        if let pluginStyles = pluginStyles {
            StylesHelper.setFontforLabel(label: self.infoLabel, fontNameKey: "font", fontSizeKey: "call_for_action_text_font_size", from: pluginStyles)
            StylesHelper.setColorforLabel(label: self.infoLabel, key: "call_for_action_text_color", from: pluginStyles)
        }
        infoLabel.text = localizationDelegate.localizationString(byKey: "NumbersLockInstructionsLocalizationKey", defaultString: "")
    }
    
    private func numberOfValidationDigitsToPresent() -> Int {
        var retVal:Int = 3;
        if let numberOfValidationButtons = numberOfValidationButtons {
            return numberOfValidationButtons
        } else {
            if let pluginGeneralSettings = pluginGeneralSettings,
                let ValidationButtonsNumberString = pluginGeneralSettings["validation_flow_type"] as? String {
                self.numberOfValidationButtons = Int(ValidationButtonsNumberString) ?? 3
                retVal = self.numberOfValidationButtons!
            }
        }
        return retVal
    }
    
    private func generateValues() {
        var generatedValuesLocalizedArray = [String]()
        var nonLocalizedGeneratedValues = [String]()
        for _ in 1...ParentLockScreenNumberLimit {
            let generatedValue = String(Int.random(in: 1 ... numberOfValidationDigitsToPresent()))
            generatedValues.append(generatedValue)
            if let stringGeneratedValue = NumbersDictionary[generatedValue] {
                nonLocalizedGeneratedValues.append(stringGeneratedValue)
                let stringGeneratedValueKey = "Number\(stringGeneratedValue)"
                if let localizedValue = self.localizationDelegate.localizationString(byKey: stringGeneratedValueKey, defaultString: stringGeneratedValue) {
                    generatedValuesLocalizedArray.append(localizedValue)
                }
            }
        }
        //set font, size and color
        randomNumbersLabel.text = generatedValuesLocalizedArray.joined(separator: ", ")
        StylesHelper.setColorforLabel(label: randomNumbersLabel, key: "random_numbers_color", from: pluginStyles)
        StylesHelper.setFontforLabel(label: randomNumbersLabel, fontNameKey: "font", fontSizeKey: "random_numbers_font_size", from: pluginStyles)
        let localizationLanguage = APApplicasterController.sharedInstance()?.localizationLanguage
        if localizationLanguage == "EN" {
            
        } else {
            //set font, size and color
            secondaryRandomNumbersLabel.text = nonLocalizedGeneratedValues.joined(separator: ", ")
            StylesHelper.setColorforLabel(label: secondaryRandomNumbersLabel, key: "secondary_random_numbers_color", from: pluginStyles)
            StylesHelper.setFontforLabel(label: secondaryRandomNumbersLabel, fontNameKey: "font", fontSizeKey: "secondary_random_numbers_font_size", from: pluginStyles)
        }
    }
    
    @IBAction func handleUserPushCloseButton(_ sender: UIButton) {
        closeScreenPlugin(with: false)
    }
    
    private func closeScreenPlugin(with success:Bool) {
        if let hookCompletion = self.hookCompletion {
            let error = success ? nil : NSError(domain: "User has closed hook execution failed", code: 0, userInfo: nil)
            hookCompletion(success, error, nil)
        }
        if let screenPluginDelegate = self.screenPluginDelegate {
            screenPluginDelegate.removeScreenPluginFromNavigationStack()
        }
    }
    
    @IBAction func handleUserPushNumberButton(_ sender: UIButton) {
        if let number = self.numberButtonsCollection.firstIndex(of: sender) {
            updateIndicatorAtIndex(index: enterdValues.count)
            enterdValues.append(String(number + 1))
            if enterdValues.count == ParentLockScreenNumberLimit {
                if enterdValues == generatedValues {
                    self.isVlidated = true
                    closeScreenPlugin(with: true)
                    if let hookCompletion = self.hookCompletion {
                        hookCompletion(true,nil,nil)
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
    
    private func clearValidationIndicators() {
        if let pluginGeneralSettings = pluginGeneralSettings {
            for dot in dotImagesCollection {
                dot.backgroundColor = StylesHelper.getColorForKey(key: "indicator_normal", from: pluginGeneralSettings)
            }
        }
    }
    
    private func setIndicatorsToMainColor() {
        for dot in dotImagesCollection {
            dot.layer.cornerRadius = cornerRadius * dot.bounds.size.width
            dot.clipsToBounds = true
            dot.layer.borderWidth = 1
            dot.layer.borderColor = StylesHelper.getColorForKey(key: "indicator_highlighted", from: pluginStyles).cgColor
        }
        clearValidationIndicators()
    }
    
    private func updateIndicatorAtIndex(index:Int) {
        if let pluginGeneralSettings = pluginGeneralSettings {
            let dot = self.dotImagesCollection[index]
            dot.backgroundColor = StylesHelper.getColorForKey(key: "indicator_highlighted", from: pluginGeneralSettings)
        }
    }
}





