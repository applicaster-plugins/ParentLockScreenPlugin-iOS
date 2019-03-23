//
//  GAParentLockViewController.m
//  ModularAppSDK
//
//  Created by Anton Kononenko on 8/25/15.
//  Copyright (c) 2015 Applicaster. All rights reserved.
//

@import ApplicasterSDK;
@import ComponentsSDK;
@import QuartzCore;
@import AudioToolbox;

#import "GAValidationFlowManager.h"
#import "GAUICustomizationHelper.h"
#import "UILabel+Customization.h"
#import "GAResourceHelper.h"
#import "GANumberLockViewController.h"

typedef void (^ShakeComplitionBlock)(void);
static const NSUInteger TotalNumberOfShakes = 6;
static const CGFloat InitialShakeAmplitude = 40.0f;

#pragma mark - Names for assests

NSString *const kNumbersLockBackgroundImage                = @"numbersLockBackground";

NSString *const kNumbersLockCloseButtonImage               = @"numbersLockCloseButton";

NSString *const kNumbersLockNumberPadButtonImage           = @"numbersLockNumberPad_%li";
NSString *const kNumbersLockNumberPadButtonHightlightImage = @"numbersLockNumberPadHightlight_%li";

NSString *const kNumbersLockDotImage                       = @"numbersLockDot";
NSString *const kNumbersLockDotFilledImage                 = @"numbersLockDotFilled";

#pragma mark - Localization Keys

NSString *const kNumbersLockNumberOneLocalizationKey      = @"NumberOne";
NSString *const kNumbersLockNumberTwoLocalizationKey      = @"NumberTwo";
NSString *const kNumbersLockNumberThreeLocalizationKey    = @"NumberThree";
NSString *const kNumbersLockNumberFourLocalizationKey     = @"NumberFour";
NSString *const kNumbersLockNumberFiveLocalizationKey     = @"NumberFive";
NSString *const kNumbersLockNumberSixLocalizationKey      = @"NumberSix";
NSString *const kNumbersLockNumberSevenLocalizationKey    = @"NumberSeven";
NSString *const kNumbersLockNumberEightLocalizationKey    = @"NumberEight";
NSString *const kNumbersLockNumberNineLocalizationKey     = @"NumberNine";

NSString *const kNumbersLockScreenInfoTextLocalizationKey  = @"NumbersLockInstructionsLocalizationKey";
NSString *const kNumbersLockScreenTitleTextLocalizationKey = @"NumbersLockTitleLocalizationKey";

#pragma mark - Customization Keys 

NSString *const kNumbersLockViewControllerInfoLabel         = @"NumbersLockInfoLabel";
NSString *const kNumbersLockViewControllerRandomNumberLabel = @"NumbersLockRandomNumberLabel";
NSString *const kNumbersLockViewControllerTitleLabel        = @"NumbersLockTitleLabel";
NSString *const kNumbersLockViewControllerCloseViewColor    = @"NumbersLockCloseViewColor";

NSUInteger const kParentLockScreenNumberLimit             = 3;
NSUInteger const kParentLockScreenWrongInputNumberLimit   = 3;

@interface GANumberLockViewController ()

@property (nonatomic, strong) NSArray *generatedValues;
@property (nonatomic, strong) NSMutableArray *inputedValuesByUser;

@property (nonatomic, assign) NSInteger numShakes;
@property (nonatomic, assign) NSInteger shakeDirection;
@property (nonatomic, assign) NSInteger shakeAmplitude;
@property (nonatomic, strong) ShakeComplitionBlock shakeCompletionBlock;
@property (nonatomic, strong) ValidationFlowCompletion validationFlowCompletion;

@property (nonatomic, assign) BOOL doNotAllowInputValues;
@property (nonatomic, assign) NSInteger wrongInputCounter;

@property (nonatomic, weak) IBOutlet UIControl *closeView;
@property (nonatomic, weak) IBOutlet APImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIButton *closeButton;

@property (nonatomic, weak) IBOutlet UILabel *infoLabel;
@property (nonatomic, weak) IBOutlet UILabel *randomNumbersLabel;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@property (nonatomic, weak) IBOutlet UIView  *dotsContainerView;
@property (weak, nonatomic) IBOutlet UIView *numberLockView;

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *numberButtonsCollection;
@property (nonatomic, strong) IBOutletCollection(APImageView) NSArray *dotImagesCollection;

@end

@implementation GANumberLockViewController
@synthesize urlScheme = _urlScheme;
@synthesize delegate = _delegate;

#pragma mark - NSObject

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{

    NSBundle *bundle = nibBundleOrNil;
    if (!bundle && nibNameOrNil.isNotEmpty) {
        bundle = [GAResourceHelper bundleForNibNamed:nibNameOrNil];
    }

    if (!bundle) {
        bundle = [GAResourceHelper bundleForNibClass:self.class];
    }

    self = [super initWithNibName:nibNameOrNil bundle:bundle];
    if (self) {
        self.doNotAllowInputValues = NO;
        self.wrongInputCounter = 0;
        _accessGrandted = NO;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.delegate respondsToSelector:@selector(validationFlowViewControllerWillPresent:)]) {
        [self.delegate validationFlowViewControllerWillPresent:self];
    }
    
    self.closeView.backgroundColor = [GAUICustomizationHelper colorForKey:kNumbersLockViewControllerCloseViewColor];
    self.backgroundImageView.image = [self imageForName:kNumbersLockBackgroundImage];
 
    [self.closeButton setImage:[self imageForName:kNumbersLockCloseButtonImage]
                      forState:UIControlStateNormal];
    
    // Remove if do not needed
    if (self.urlScheme) {
        [self generateValues];
        [self customizeNumberPad];
        [self resetDotsImages];
        [self clearInputValues];
        [self updateLabels];
    } else {
        [self accessRejectedFromValidationFlow];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.delegate respondsToSelector:@selector(validationFlowViewControllerDidPresent:)]) {
        [self.delegate validationFlowViewControllerDidPresent:self];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [APAnalyticsManager trackScreenView:[self analyticsScreenName]];
}

#pragma marl - APValidationFlowProtocol

- (NSString *)validationFlowType {
    return kNumberNavigationFlowType;
}

- (void)setUrlScheme:(NSURL *)urlScheme {
    _urlScheme = urlScheme;
}

- (void)accessGrantedFromValidationFlow {
    [APAnalyticsManager trackEvent:@"Unlock Parent Lock"];
    [self closeParentLockViewController];
}

- (void)accessRejectedFromValidationFlow {
    [self closeParentLockViewController];
}

- (void)presentValidationFlowOnTopViewController:(UIViewController <APValidationFlowProtocol>*)viewController
                                  withCompletion:(ValidationFlowCompletion)completion {
    self.validationFlowCompletion = completion;
    [self presentValidationFlowOnTopViewController:viewController];
}

- (void)presentValidationFlowOnTopViewController:(UIViewController *)viewController {
    [viewController addChildViewController:self
                                    toView:viewController.view];
}

- (void)dissmisValidationFlow {
    [self removeViewFromParentViewController];
}
#pragma mark - Actions

- (IBAction)handleUserPushCloseButton:(UIControl *)sender {
    [self accessRejectedFromValidationFlow];
}

- (IBAction)handleUserPushNumberButton:(UIButton *)numberButton {
    if (self.doNotAllowInputValues == NO) {
        NSUInteger buttonIndex = [self.numberButtonsCollection indexOfObject:numberButton];
        NSInteger buttonNumber = buttonIndex + 1;
        NSNumber *numberOfSelectedButton = @(buttonNumber);
        
        [self.inputedValuesByUser addObject:numberOfSelectedButton];
        [self updateDotAtIndex:self.inputedValuesByUser.count - 1];
        [self checkInputResult];
    }
}

#pragma mark - Helpers methods

- (void)clearInputValues {
    self.inputedValuesByUser = [NSMutableArray new];
}

- (void)checkInputResult {
    _accessGrandted = NO;
    if (self.inputedValuesByUser.count == kParentLockScreenNumberLimit) {
        if (self.generatedValues.count == kParentLockScreenNumberLimit) {
            _accessGrandted = YES;
            for (int i = 0; i < kParentLockScreenNumberLimit; i++) {
                NSNumber *generatedNumber = self.generatedValues[i];
                NSNumber *inputedNumber = self.inputedValuesByUser[i];
                if ([generatedNumber isEqualToNumber:inputedNumber] == NO) {
                    _accessGrandted = NO;
                    break;
                }
            }
        }
        if (self.accessGrandted) {
            [self accessGrantedFromValidationFlow];
        } else {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            [self clearInputValues];
            
            self.wrongInputCounter++;
            if (self.wrongInputCounter == kParentLockScreenWrongInputNumberLimit) {
                [self closeParentLockViewController];
            } else {
                [self shakeWithCompletion:^{
                    [self resetDotsImages];
                }];
            }
        }
    }
}


- (void)customizeNumberPad {
    NSInteger buttonImagesIndex = 0;
    for (UIButton *button in self.numberButtonsCollection) {
        NSString *imageName = [NSString stringWithFormat:kNumbersLockNumberPadButtonImage,(long)buttonImagesIndex];
        UIImage *image = [self imageForName:imageName];
        
        NSString *imageNameHeightlighted = [NSString stringWithFormat:kNumbersLockNumberPadButtonHightlightImage,(long)buttonImagesIndex];
        UIImage *imageHeightlighted = [self imageForName:imageNameHeightlighted];
        
        [button setImage:image forState:UIControlStateNormal];
        [button setImage:imageHeightlighted forState:UIControlStateHighlighted];
        buttonImagesIndex++;
    }
}

- (void)resetDotsImages {
    for (APImageView *dotImageView in self.dotImagesCollection) {
        UIImage *image = [self imageForName:kNumbersLockDotImage];
        dotImageView.image = image;

    }
}

- (void)updateDotAtIndex:(NSInteger)dotIndex {
    if (self.dotImagesCollection.count > dotIndex) {
        APImageView *dotImageView = self.dotImagesCollection[dotIndex];
        UIImage *image = [self imageForName:kNumbersLockDotFilledImage];
        dotImageView.image = image;
    }
}

- (void)updateLabels {

    [self.infoLabel setLabelStyleForKey:kNumbersLockViewControllerInfoLabel];
    self.infoLabel.text = [@"Please enter code to preceed" withKey:kNumbersLockScreenInfoTextLocalizationKey];

    [self.titleLabel setLabelStyleForKey:kNumbersLockViewControllerTitleLabel];
    self.titleLabel.text = [@"" withKey:kNumbersLockScreenTitleTextLocalizationKey];
    
    [self.randomNumbersLabel setLabelStyleForKey:kNumbersLockViewControllerRandomNumberLabel];
    NSString *randomNumbersText = @"";
    NSString *randomNumbersEnglishText = @"";
    if ([self.generatedValues count] > 0) {
        for (int index = 0; index < self.generatedValues.count; index++) {
            NSNumber *number = self.generatedValues[index];
            
            NSString *numberInString = [self stringFromNumber:[number integerValue] shouldTakeFromZapp:YES];
            randomNumbersText = [randomNumbersText stringByAppendingString:numberInString];
            
            // represents the values of the generated Values in english string
            NSString *englishNumbersString = [self stringFromNumber:[number integerValue] shouldTakeFromZapp:NO];
            randomNumbersEnglishText = [randomNumbersEnglishText stringByAppendingString:englishNumbersString];
            
            if (index != self.generatedValues.count - 1) {
                randomNumbersText = [randomNumbersText stringByAppendingString:@", "];
                randomNumbersEnglishText = [randomNumbersEnglishText stringByAppendingString:@", "];
            }
        }
        self.randomNumbersLabel.text = randomNumbersText;
        // if the languege is not english we will present the english text
        if ([[APApplicasterController sharedInstance].currentBroadcaster.name rangeOfString:@"English"
                                                                                    options:NSCaseInsensitiveSearch].location == NSNotFound) {
            self.infoLabel.text = randomNumbersEnglishText;
        }
    }
}

- (void)generateValues {
    NSMutableArray *geratedValuesArray = [[NSMutableArray alloc] initWithCapacity:kParentLockScreenNumberLimit];
    for (int i = 0; i < kParentLockScreenNumberLimit; i++) {
        NSNumber *generatedValue = @((arc4random() % self.numberButtonsCollection.count) + 1);
        [geratedValuesArray addObject:generatedValue];
    }
    self.generatedValues = [geratedValuesArray copy];
}

- (NSString *)stringFromNumber:(NSInteger)number shouldTakeFromZapp:(BOOL)shouldTakeFromZapp{
    NSString *retVal = nil;
    switch (number) {
        case 1:
            retVal = (shouldTakeFromZapp)? [@"One" withKey:kNumbersLockNumberOneLocalizationKey]: @"One";
            break;
        case 2:
            retVal = (shouldTakeFromZapp)? [@"Two" withKey:kNumbersLockNumberTwoLocalizationKey]: @"Two";
            break;
        case 3:
            retVal = (shouldTakeFromZapp)? [@"Three" withKey:kNumbersLockNumberThreeLocalizationKey]: @"Three";
            break;
        case 4:
            retVal = (shouldTakeFromZapp)? [@"Four" withKey:kNumbersLockNumberFourLocalizationKey]: @"Four";
            break;
        case 5:
            retVal = (shouldTakeFromZapp)? [@"Five" withKey:kNumbersLockNumberFiveLocalizationKey]: @"Five";
            break;
        case 6:
            retVal = (shouldTakeFromZapp)? [@"Six" withKey:kNumbersLockNumberSixLocalizationKey]: @"Six";
            break;
        case 7:
            retVal = (shouldTakeFromZapp)? [@"Seven" withKey:kNumbersLockNumberSevenLocalizationKey]: @"Seven";
            break;
        case 8:
            retVal = (shouldTakeFromZapp)? [@"Eight" withKey:kNumbersLockNumberEightLocalizationKey]: @"Eight";
            break;
        case 9:
            retVal = (shouldTakeFromZapp)? [@"Nine" withKey:kNumbersLockNumberNineLocalizationKey]: @"Nine";
            break;
        default:
            break;
    }
    return retVal;
}

- (UIImage *)imageForName:(NSString *)imageName {
    return [GAResourceHelper imageNamed:imageName];
}

- (void)shakeWithCompletion:(ShakeComplitionBlock)completion {
    self.doNotAllowInputValues = YES;
    self.numShakes = 0;
    self.shakeDirection = -1;
    self.shakeAmplitude = InitialShakeAmplitude;
    self.shakeCompletionBlock = completion;
    [self performShake];
}

- (void)performShake
{
    [UIView animateWithDuration:0.03f animations:^ {
        self.dotsContainerView.transform = CGAffineTransformMakeTranslation(self.shakeDirection * self.shakeAmplitude, 0.0f);
    } completion:^(BOOL finished) {
        if (self.numShakes < TotalNumberOfShakes) {
            self.numShakes++;
            self.shakeDirection = -1 * self.shakeDirection;
            self.shakeAmplitude = (TotalNumberOfShakes - self.numShakes) * (InitialShakeAmplitude / TotalNumberOfShakes);
            [self performShake];
        } else {
            self.dotsContainerView.transform = CGAffineTransformIdentity;
            if (self.shakeCompletionBlock) {
                self.doNotAllowInputValues = NO;
                self.shakeCompletionBlock();
                self.shakeCompletionBlock = nil;
            }
        }
    }];
}

- (void)closeParentLockViewController {
    
    __weak typeof(self) weakSelf = self;

    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.numberLockView.alpha = 0;
        self.closeButton.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.closeView.alpha = 0;
        } completion:^(BOOL finished) {
            NSDictionary *parameters = @{kIsAccessGrandted : [NSNumber numberWithInteger:self.accessGrandted]};
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kValidationFlowWillCloseNotification
                                                                object:nil
                                                              userInfo:parameters];
            if (self.validationFlowCompletion) {
                [weakSelf removeViewFromParentViewController];
                weakSelf.validationFlowCompletion(weakSelf.accessGrandted, weakSelf.urlScheme);
                weakSelf.validationFlowCompletion = nil;
            } else {
                [weakSelf.delegate validationFlowViewControllerShouldBeDismissed:weakSelf
                                                                   accessGranted:self.accessGrandted
                                                                       urlScheme:self.urlScheme];
            }
        }];
    }];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [CAAppDefineComponent sharedInstance].allowedOrientationMask;
}

#pragma mark - ZPAnalyticsScreenProtocol

-(NSString *)analyticsScreenName {
    return @"Parent Lock";
}

@end
