//
//  ParentLockScreenPluginVC.swift
//  ParentLockScreenPlugin-iOS
//
//  Created by Roi Kedarya on 24/03/2019.
//  Copyright © 2019 applicaster. All rights reserved.
//

import Foundation
import ZappPlugins

class ParentLockScreenPluginVC: UIViewController {
    var generatedValues: Array<Int>
    
    let NumbersDictionary = ["Zero","One","Two","Three","Four","Five","Six","Seven","Eight","nine"]
    @IBOutlet weak var closeView: UIControl!
    @IBOutlet weak var numberLuckView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var RandomNumbersLabel: UILabel!
    @IBOutlet weak var dotsContainerView: UIView!
    @IBOutlet var dotImagesCollection: [UIImageView]!
    @IBOutlet var numberButtonsCollection: [UIButton]!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        generatedValues = Array()
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        generateValues()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func generateValues() {
        var generatedValuesStringArray = [String]()
        for index in 0...2 {
            let generatedValue = Int.random(in: 0 ... 9)
            generatedValues[index] = generatedValue
            generatedValuesStringArray[index] = String(generatedValue)
        }
        RandomNumbersLabel.text = generatedValuesStringArray.joined(separator: ",")
    }
    
    @IBAction func handleUserPushCloseButton(_ sender: UIButton) {
        self.dismissPushAnimated()
    }
    
    @IBAction func handleUserPushNumberButton(_ sender: UIButton) {
        
    }
    
}




