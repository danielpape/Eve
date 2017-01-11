//
//  eveViewController.h
//  eve2
//
//  Created by Daniel Pape on 06/05/2013.
//  Copyright (c) 2013 Daniel Pape. All rights reserved.
//
@class MHRotaryKnob;



#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import <StoreKit/StoreKit.h>
#import "SKProduct+priceAsString.h"

#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"

@interface eveViewController : UIViewController<SKPaymentTransactionObserver, SKProductsRequestDelegate>{
    NSDate *firedate;
    NSUserDefaults *defaults;
    UILocalNotification *mondayWakeAlarm;
    UILocalNotification *tuesdayWakeAlarm;
    UILocalNotification *wednesdayWakeAlarm;
    UILocalNotification *thursdayWakeAlarm;
    UILocalNotification *fridayWakeAlarm;
    UILocalNotification *saturdayWakeAlarm;
    UILocalNotification *sundayWakeAlarm;
    UILocalNotification *mondayReminderAlarm;
    UILocalNotification *tuesdayReminderAlarm;
    UILocalNotification *wednesdayReminderAlarm;
    UILocalNotification *thursdayReminderAlarm;
    UILocalNotification *fridayReminderAlarm;
    UILocalNotification *saturdayReminderAlarm;
    UILocalNotification *sundayReminderAlarm;
    UIToolbar *bgToolbar;
    UIToolbar *bgToolbarTwo;
    float minutesPastHour;
    int hourOfSleep;
    NSString *backgroundName;
}

@property (weak, nonatomic) IBOutlet UIImageView *skyBackground;
@property (nonatomic, weak) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIImageView *knobCentre;
@property (nonatomic, weak) IBOutlet MHRotaryKnob *rotaryKnob;
@property (weak, nonatomic) IBOutlet UIImageView *skyBack;
@property (retain, nonatomic) IBOutlet UILabel *wakeTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *setAlarmButton;
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (weak, nonatomic) IBOutlet UILabel *menuHourFormatLabel;
@property (weak, nonatomic) IBOutlet UILabel *alarmNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sleepLengthLabel;
@property (weak, nonatomic) IBOutlet UIView *backgroundLabelView;
@property (weak, nonatomic) IBOutlet UIView *timeFormatLabelView;
@property (weak, nonatomic) IBOutlet UIView *soundNameLabelView;
@property (weak, nonatomic) IBOutlet UIView *sleepLengthLabelView;
@property (weak, nonatomic) IBOutlet UIButton *setFinalAlarmButton;
@property (weak, nonatomic) IBOutlet UILabel *reminderTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *eveWillRemindYouTest;
@property (weak, nonatomic) IBOutlet UILabel *setPhoneToLoudModeLabel;
@property (weak, nonatomic) IBOutlet UIView *settingsReturnButtonView;
@property (weak, nonatomic) IBOutlet UIView *setAlarmButtonView;
@property (weak, nonatomic) IBOutlet UIView *resetButtonView;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UIView *reminderTimeView;
@property (weak, nonatomic) IBOutlet UIView *setToLoudModeView;
@property (weak, nonatomic) IBOutlet UIView *returnSetSettingsView;
@property (weak, nonatomic) IBOutlet UIButton *returnSetSettingsButton;
@property (weak, nonatomic) IBOutlet UIView *closeEveView;
@property (weak, nonatomic) IBOutlet UIImageView *dragInstructions;
@property (weak, nonatomic) IBOutlet UILabel *eveWillWakeLabel;
@property (weak, nonatomic) IBOutlet UIButton *soundButton;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (weak, nonatomic) IBOutlet UIButton *introScreen;
@property (weak, nonatomic) IBOutlet UIView *daysView;
@property (weak, nonatomic) IBOutlet UIButton *daysReturnButton;
@property (weak, nonatomic) IBOutlet UIButton *mondayButton;
@property (weak, nonatomic) IBOutlet UIButton *tuesdayButton;
@property (weak, nonatomic) IBOutlet UIButton *wednesdayButton;
@property (weak, nonatomic) IBOutlet UIButton *thursdayButton;
@property (weak, nonatomic) IBOutlet UIButton *fridayButton;
@property (weak, nonatomic) IBOutlet UIButton *saturdayButton;
@property (weak, nonatomic) IBOutlet UIButton *sundayButton;
@property (weak, nonatomic) IBOutlet UIView *introView;
@property (weak, nonatomic) IBOutlet UIButton *beginButton;
@property (weak, nonatomic) IBOutlet UIImageView *menuBackground;
@property (weak, nonatomic) IBOutlet UILabel *mondayLetter;
@property (weak, nonatomic) IBOutlet UILabel *tuesdayLetter;
@property (weak, nonatomic) IBOutlet UILabel *wednesdayLetter;
@property (weak, nonatomic) IBOutlet UILabel *thursdayLetter;
@property (weak, nonatomic) IBOutlet UILabel *fridayLetter;
@property (weak, nonatomic) IBOutlet UILabel *saturdayLetter;
@property (weak, nonatomic) IBOutlet UILabel *sundayLetter;
@property (weak, nonatomic) IBOutlet UILabel *wakeReminderHours;
@property (weak, nonatomic) IBOutlet UILabel *reminderText;
@property (weak, nonatomic) IBOutlet UILabel *backgroundLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIButton *infoReturnButton;
@property (weak, nonatomic) IBOutlet UIButton *tweetButton;
@property (weak, nonatomic) IBOutlet UIImageView *iPhoneBG;
@property (weak, nonatomic) IBOutlet UIImageView *introBG;
@property (weak, nonatomic) IBOutlet UIView *IAPView;
@property (strong, nonatomic) SKProduct *product;
@property (strong, nonatomic) NSString *productID;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UILabel *IAPlabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *settingsView;
@property (weak, nonatomic) IBOutlet UIButton *resetAlarmButton;

-(IBAction)touchUpInKnob;
- (IBAction) rotaryKnobDidChange;
- (IBAction) setAlarm;
- (IBAction) pressSettingsButton;
- (IBAction) pressInfoButton;
- (IBAction) pressInfoReturnButton;
- (IBAction) changeHourFormat;
- (IBAction) nextAlarm;
- (IBAction) prevAlarm;
- (IBAction) nextBackground;
- (IBAction) prevBackground;
- (IBAction) moreHours;
- (IBAction) lessHours;
- (IBAction) pressSetAlarmButton;
- (IBAction) pressSettingsReturnButton;
- (IBAction) pressResetButton;
- (IBAction) pressReturnSetSettingsButton;
- (IBAction) pressSoundButton;
- (IBAction) pressIntroScreenButton;
- (IBAction) pressDaysReturnButton;
- (IBAction) pressMondayButton;
- (IBAction) pressTuesdayButton;
- (IBAction) pressWednesdayButton;
- (IBAction) pressThursdayButton;
- (IBAction) pressFridayButton;
- (IBAction) pressSaturdayButton;
- (IBAction) pressSundayButton;
- (IBAction) pressDaysContinueButton;
- (IBAction)pressSettingsContinueButton:(id)sender;

- (void) setMondayAlarm;
- (void) setTuesdayAlarm;
- (void) setWednesdayAlarm;
- (void) setThursdayAlarm;
- (void) setFridayAlarm;
- (void) setSaturdayAlarm;
- (void) setSundayAlarm;
- (IBAction) pressBeginButton;
- (IBAction)tweet;
- (IBAction)website;
- (void) purchased;
- (IBAction) pressBackgroundButton;
- (IBAction) hideIAPView;
- (IBAction)gotoReviews:(id)sender;
- (IBAction)purchase:(id)sender;
- (IBAction)tapNap;
- (IBAction)tapMap;
- (IBAction) pressMenuReturnButton;





@end
