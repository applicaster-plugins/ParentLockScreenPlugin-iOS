//
//  GAParentLockViewController.h
//  ModularAppSDK
//
//  Created by Anton Kononenko on 8/25/15.
//  Copyright (c) 2015 Applicaster. All rights reserved.
//

@import UIKit;
@import ZappPlugins;
@import ApplicasterSDK;

@class APImageView;

@interface GANumberLockViewController : UIViewController <APValidationFlowProtocol, ZPAnalyticsScreenProtocol>

@property (nonatomic, assign, readonly) NSInteger accessGrandted;

#pragma mark - Actions

- (IBAction)handleUserPushCloseButton:(UIControl *)sender;
- (IBAction)handleUserPushNumberButton:(UIButton *)numberButton;

@end
