//
//  eveViewController.m
//  Eve Alarm
//
//  Copyright (c) 2013 Daniel Pape. All rights reserved.
//

#import "eveViewController.h"
#import "MHRotaryKnob.h"

@interface eveViewController ()

@end

@implementation eveViewController

NSString *hourFormat;
NSString *dialTime;
NSString *alarmNameString;
NSString *reminderTimeString;
BOOL isPlaying;
SKProductsRequest *productsRequest;
NSArray *validProducts;

#define kTutorialPointProductID @"com.danielpape.Eve.seasons"

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    hourFormat = @"h mm a";
    alarmNameString = @"eveAlarm4.wav";
    hourOfSleep = 8;
    isPlaying = NO;
    
    
    defaults = [[NSUserDefaults alloc]init];
    
    if ([defaults objectForKey:@"background"] != nil) {
        NSString *backgroundString = [defaults objectForKey:@"background"];
        NSLog(@"%@",backgroundString);
        self.skyBackground.image = [UIImage imageNamed:backgroundString];
        backgroundName = backgroundString;
        [defaults synchronize];
    }else{
        self.skyBackground.image = [UIImage imageNamed:@"background1.png"];
        backgroundName = [NSString stringWithFormat:@"background1.png"];
        [defaults synchronize];
    }

    self.rotaryKnob.interactionStyle = MHRotaryKnobInteractionStyleRotating;
	self.rotaryKnob.scalingFactor = 1.5f;
	self.rotaryKnob.maximumValue = 500;
	self.rotaryKnob.minimumValue = -500;
    self.rotaryKnob.defaultValue = 500;
	self.rotaryKnob.value = self.slider.value;
	self.rotaryKnob.resetsToDefault = NO;
//    self.rotaryKnob.foregroundImage = [UIImage imageNamed:@"KnobOverlay2.png"];
	self.rotaryKnob.backgroundColor = [UIColor clearColor];
	[self.rotaryKnob setKnobImage:[UIImage imageNamed:@"KnobSky3.png"] forState:UIControlStateNormal];
	self.rotaryKnob.knobImageCenter = CGPointMake(self.rotaryKnob.bounds.size.width/2.0f, self.rotaryKnob.bounds.size.width/2.0f);
	[self.rotaryKnob addTarget:self action:@selector(rotaryKnobDidChange) forControlEvents:UIControlEventValueChanged];
    
    self.mondayButton.selected = YES;
    self.tuesdayButton.selected = YES;
    self.wednesdayButton.selected = YES;
    self.thursdayButton.selected = YES;
    self.fridayButton.selected = YES;
   
    NSDateFormatter *labelFormat = [[NSDateFormatter alloc] init];
    dialTime = [NSString stringWithFormat:@"%@", [labelFormat stringFromDate:[[NSDate date] dateByAddingTimeInterval: self.rotaryKnob.value*800]]];
        
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"h mm a"];
    self.wakeTimeLabel.text = [NSString stringWithFormat:@"%@",[dateFormat stringFromDate:[NSDate date]]];
    
    NSDateFormatter *dateForAlarm = [[NSDateFormatter alloc] init];
    [dateForAlarm setDateFormat:@"HH"];
    NSString *hours = [NSString stringWithFormat:@"%@", [labelFormat stringFromDate:[NSDate date]]];
    [dateForAlarm setDateFormat:@"mm"];
    NSString *minutes = [NSString stringWithFormat:@"%@", [labelFormat stringFromDate:[NSDate date]]];

    minutesPastHour = [minutes intValue];
    NSLog(@"minutes = %f",minutesPastHour);
    int hoursInt = [hours intValue];
    NSLog(@"hours = %i",hoursInt);

    float minutesPercentage = (minutesPastHour/60) *100;
    
    float Hm = (hoursInt*100)+minutesPercentage;
    NSLog(@"%f",Hm);
    NSLog(@"rotary knob value: %f",self.rotaryKnob.value);
    
    CGPoint initcenter = [_skyBack center];
    initcenter.x = self.view.bounds.size.width/2;
    initcenter.y = Hm - 400;
    [_skyBack setCenter:initcenter];
    
    if ([[defaults objectForKey:@"background"]  isEqual: @"background1.png"]){
        self.backgroundLabel.text = @"Summer";
    }else if ([[defaults objectForKey:@"background"]  isEqual: @"background5.png"]){
        self.backgroundLabel.text = @"Autumn";
    }else if ([[defaults objectForKey:@"background"]  isEqual: @"background3.png"]){
        self.backgroundLabel.text = @"Winter";
    }else if ([[defaults objectForKey:@"background"]  isEqual: @"background6.png"]){
        self.backgroundLabel.text = @"Spring";
    }
    
    [self fetchAvailableProducts];
    
   // [self requestProUpgradeProductData];
    
   // self.IAPlabel.text = [NSString stringWithFormat:@"price is %@",proUpgradeProduct.priceAsString];
    
    NSLog(@"iap text= %@",self.IAPlabel.text);
    
    
    
}

- (void)viewDidUnload {
    [self setKnobCentre:nil];
    [super viewDidUnload];
}

- (IBAction) pressIntroScreenButton{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH mm a"];
    self.wakeTimeLabel.text = [NSString stringWithFormat:@"%@",[dateFormat stringFromDate:[NSDate date]]];
    
    NSDateFormatter *dateForAlarm = [[NSDateFormatter alloc] init];
    [dateForAlarm setDateFormat:@"HH"];
    NSString *hours = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:[[NSDate date] dateByAddingTimeInterval: self.rotaryKnob.value*800]]];
    
    [dateForAlarm setDateFormat:@"mm"];
    NSString *minutes = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:[[NSDate date] dateByAddingTimeInterval: self.rotaryKnob.value*800]]];
    
    minutesPastHour = [minutes intValue];
    int hoursInt = [hours intValue];
    float minutesPercentage = (minutesPastHour/60) *100;
    
    float Hm = (hoursInt*100)+minutesPercentage;
    NSLog(@"%f",Hm);
    NSLog(@"%f",self.rotaryKnob.value);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    CGPoint center = [_skyBack center];
    center.x = self.view.bounds.size.width/2;
    center.y = Hm - 400;
    [_skyBack setCenter:center];
    [UIView commitAnimations];
}


- (IBAction)rotaryKnobDidChange{
    
    self.setAlarmButton.enabled = NO;
    self.wakeTimeLabel.alpha = 1;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    self.dragInstructions.alpha=0;
    [UIView commitAnimations];
    
    NSDateFormatter *labelFormat = [[NSDateFormatter alloc] init];
    [labelFormat setDateFormat:hourFormat];
    self.wakeTimeLabel.text = [NSString stringWithFormat:@"%@", [labelFormat stringFromDate:[[NSDate date] dateByAddingTimeInterval: self.rotaryKnob.value*800]]];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH"];
    NSString *hours = [dateFormat stringFromDate:[[NSDate date] dateByAddingTimeInterval: self.rotaryKnob.value*800]];
    
    [dateFormat setDateFormat:@"mm"];
    NSString *minutes = [dateFormat stringFromDate:[[NSDate date] dateByAddingTimeInterval: self.rotaryKnob.value*800]];
    
    firedate = [[NSDate date] dateByAddingTimeInterval: self.rotaryKnob.value*800];
    
    minutesPastHour = [minutes intValue];
    NSLog(@"minutes past hour: %@",minutes);
    int hoursInt = [hours intValue];
    float minutesPercentage = (minutesPastHour/60) *100;
    
    float Hm = (hoursInt*100)+minutesPercentage;
    NSLog(@"%f",Hm);
    NSLog(@"Rotary Knob Value: %f",self.rotaryKnob.value);

    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0];
    
    CGPoint center = [_skyBack center];
    center.x = self.view.bounds.size.width/2;
    center.y = Hm - 400;
    
    [_skyBack setCenter:center];
    
    [UIView commitAnimations];
    
    NSLog(@"%f",minutesPastHour);

}


- (IBAction)tapThemeSegmentControl:(id)sender {
    if (_themeSegmentControl.selectedSegmentIndex==0)
    {
        NSLog(@"Segment 1 selected");
    }
    else if (_themeSegmentControl.selectedSegmentIndex==1)
    {
        NSLog(@"Segment 2 selected");
    }
    else if (_themeSegmentControl.selectedSegmentIndex==2)
    {
        NSLog(@"Segment 3 selected");
    }
    else if (_themeSegmentControl.selectedSegmentIndex==3)
    {
        NSLog(@"Segment 4 selected");
    }
}

- (IBAction)tapSoundSegmentControl:(id)sender {
    if (_soundSegmentControl.selectedSegmentIndex==0)
    {
        NSLog(@"Sound segment 1 selected");
    }
    else if (_soundSegmentControl.selectedSegmentIndex==1)
    {
        NSLog(@"Sound segment 2 selected");
    }
    else if (_soundSegmentControl.selectedSegmentIndex==2)
    {
        NSLog(@"Sound segment 3 selected");
    }
    else if (_soundSegmentControl.selectedSegmentIndex==3)
    {
        NSLog(@"Sound segment 4 selected");
    }

}

- (IBAction)slideHoursSlider:(id)sender {
//    NSLog(@"%i",(int)self.hoursSlider.value);
//    self.hoursLabel.text = [NSString stringWithFormat:@"%i",(int)self.hoursSlider.value];
}

- (IBAction)tapResetAlarmButton:(id)sender {
    [self hideSetAlarmElements];
    self.menuBackgroundImage.alpha = 1;
    self.rotaryKnob.alpha = 0.4;
    self.setAlarmButton.alpha = 1;
}

-(IBAction)touchUpInKnob{
    
    NSDateFormatter *labelFormat = [[NSDateFormatter alloc] init];
    [labelFormat setDateFormat:hourFormat];
    NSLog(@"minutes past hour: %f",minutesPastHour);
    
    if (minutesPastHour == 1|
        minutesPastHour == 6|
        minutesPastHour == 11|
        minutesPastHour == 16|
        minutesPastHour == 21|
        minutesPastHour == 26|
        minutesPastHour == 31|
        minutesPastHour == 36|
        minutesPastHour == 41|
        minutesPastHour == 46|
        minutesPastHour == 51|
        minutesPastHour == 56
        ){
        firedate = [firedate dateByAddingTimeInterval:-60];
        self.wakeTimeLabel.text = [labelFormat stringFromDate:firedate];
    } else if (minutesPastHour == 2|
               minutesPastHour == 7|
               minutesPastHour == 12|
               minutesPastHour == 17|
               minutesPastHour == 22|
               minutesPastHour == 27|
               minutesPastHour == 32|
               minutesPastHour == 37|
               minutesPastHour == 42|
               minutesPastHour == 47|
               minutesPastHour == 52|
               minutesPastHour == 57
               ){
        firedate = [firedate dateByAddingTimeInterval:-60*2];
        self.wakeTimeLabel.text = [labelFormat stringFromDate:firedate];
    } else if (minutesPastHour == 3|
               minutesPastHour == 8|
               minutesPastHour == 13|
               minutesPastHour == 18|
               minutesPastHour == 23|
               minutesPastHour == 28|
               minutesPastHour == 33|
               minutesPastHour == 38|
               minutesPastHour == 43|
               minutesPastHour == 48|
               minutesPastHour == 53|
               minutesPastHour == 58
               ){
        firedate = [firedate dateByAddingTimeInterval:60*2];
        self.wakeTimeLabel.text = [labelFormat stringFromDate:firedate];
    } else if (minutesPastHour == 4|
               minutesPastHour == 9|
               minutesPastHour == 14|
               minutesPastHour == 19|
               minutesPastHour == 24|
               minutesPastHour == 29|
               minutesPastHour == 34|
               minutesPastHour == 39|
               minutesPastHour == 44|
               minutesPastHour == 49|
               minutesPastHour == 54|
               minutesPastHour == 59
               ){
        firedate = [firedate dateByAddingTimeInterval:60];
        self.wakeTimeLabel.text = [labelFormat stringFromDate:firedate];
    }
    
    self.setAlarmButton.enabled = YES;
}

-(IBAction)pressSetAlarmButton{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    self.dragInstructions.alpha=0;
    [UIView commitAnimations];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    self.infoButton.alpha = 0;
    self.menuButton.alpha = 0;
    self.rotaryKnob.alpha = 0;
    self.reminderText.alpha = 0;
    
    CGPoint daysCenter = [self.daysView center];
    daysCenter.y = self.view.bounds.size.height-150;
    [self.daysView setCenter:daysCenter];
    self.setAlarmButton.alpha = 0;
    [UIView commitAnimations];
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(dismissMenuView) userInfo:nil repeats:NO];
    
}

-(void) dismissMenuView {
    self.menuBackgroundImage.alpha = 0;
}

- (IBAction) setAlarm {
    
    NSLog(@"Set Alarm button tapped");
    /* NSDate *alarmTime = [[NSDate date] dateByAddingTimeInterval: self.rotaryKnob.value*800];
    NSLog(@"alarm time is %@",alarmTime );
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    
    NSDateComponents *alarmComponent = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit ) fromDate:alarmTime];
    
    NSDateComponents *todayComponent = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit ) fromDate:[NSDate date]];
    
    [alarmComponent setYear:todayComponent.year];
    [alarmComponent setMonth:todayComponent.month];
    [alarmComponent setDay:todayComponent.day];
    [alarmComponent setHour:alarmComponent.hour];
    [alarmComponent setMinute:alarmComponent.minute];
    
    provisionalAlarmTime = [calendar dateFromComponents:alarmComponent];
    
    NSComparisonResult result = [provisionalAlarmTime compare:[NSDate date]];
    
    if(result==NSOrderedAscending)
        provisionalAlarmTime = [provisionalAlarmTime dateByAddingTimeInterval:60*60*24];
        
    UILocalNotification *wakeAlarm = [[UILocalNotification alloc]init];
    wakeAlarm.fireDate = provisionalAlarmTime;
    wakeAlarm.alertBody = [self wakeMessage];
    wakeAlarm.soundName = alarmNameString;
    
    [wakeAlarm setHasAction:YES];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:wakeAlarm];
    NSLog(@"alarm is set for %@",provisionalAlarmTime);
    
    UILocalNotification *reminderAlarm = [[UILocalNotification alloc]init];
    
    reminderAlarm.fireDate = [provisionalAlarmTime dateByAddingTimeInterval:-hourOfSleep*60*60];
    reminderAlarm.alertBody = @"Feeling sleepy? If you go to bed now, you will feel refreshed & energised in the morning";
    reminderAlarm.soundName = @"sleepAlarm1.wav";
        
    NSComparisonResult reminderResult = [[provisionalAlarmTime dateByAddingTimeInterval:-hourOfSleep*60*60] compare:[NSDate date]];
    
    if(reminderResult==NSOrderedDescending){
        [[UIApplication sharedApplication] scheduleLocalNotification:reminderAlarm];
        NSLog(@"Reminder alarm set for %@",[provisionalAlarmTime dateByAddingTimeInterval:-hourOfSleep*60*60]);
        
        NSUserDefaults *alarmTime = [NSUserDefaults standardUserDefaults];
        [alarmTime setObject:provisionalAlarmTime forKey:@"alarmKey1"];
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:hourFormat];
    
    self.reminderTimeLabel.text = [dateFormat stringFromDate:[provisionalAlarmTime dateByAddingTimeInterval:-hourOfSleep*60*60]];
    */
    
    self.wakeReminderHours.text = [NSString stringWithFormat:@"and will remind you %d hours before", hourOfSleep];
    [NSString stringWithFormat:@"Alarm & reminders set on:"];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    self.wakeReminderHours.alpha = 1;
    self.reminderText.alpha = 1;

    
    if (self.mondayButton.selected == YES) {
        [self setMondayAlarm];
        self.mondayLetter.alpha = 1;
        NSLog(@"Monday Alarm Set");
    }
    if (self.tuesdayButton.selected == YES) {
        [self setTuesdayAlarm];
        self.tuesdayLetter.alpha = 1;
        NSLog(@"Tuesday Alarm Set");
    }
    if (self.wednesdayButton.selected == YES) {
        [self setWednesdayAlarm];
        self.wednesdayLetter.alpha = 1;
        NSLog(@"Wednesday Alarm Set");
    }
    if (self.thursdayButton.selected == YES) {
        [self setThursdayAlarm];
        self.thursdayLetter.alpha = 1;
        NSLog(@"Thursday Alarm Set");
    }
    if (self.fridayButton.selected == YES) {
        [self setFridayAlarm];
        self.fridayLetter.alpha = 1;
        NSLog(@"Friday Alarm Set");
    }
    if (self.saturdayButton.selected == YES) {
        [self setSaturdayAlarm];
        self.saturdayLetter.alpha = 1;
        NSLog(@"Saturday Alarm Set");
    }
    if (self.sundayButton.selected == YES) {
        [self setSundayAlarm];
        self.sundayLetter.alpha = 1;
        NSLog(@"Sunday Alarm Set");
    }
    
    self.eveWillWakeLabel.alpha = 1;
    self.menuBackground.alpha = 0;
    
    CGPoint formatLabelCenter = [self.timeFormatLabelView center];
    formatLabelCenter.x = self.view.bounds.size.width/2;
    formatLabelCenter.y = 500;
    [self.timeFormatLabelView setCenter:formatLabelCenter];
    
    CGPoint backgroundLabelCenter = [self.backgroundLabelView center];
    backgroundLabelCenter.x = self.view.bounds.size.width/2;
    backgroundLabelCenter.y = 500;
    [self.backgroundLabelView setCenter:backgroundLabelCenter];
    
    CGPoint soundNameLabelCenter = [self.soundNameLabelView center];
    soundNameLabelCenter.x = self.view.bounds.size.width/2;
    soundNameLabelCenter.y = 500;
    [self.soundNameLabelView setCenter:soundNameLabelCenter];
    
    CGPoint reminderTimeViewCenter = [self.reminderTimeView center];
    reminderTimeViewCenter.x = self.view.bounds.size.width/2;
    reminderTimeViewCenter.y = 80;
    [self.reminderTimeView setCenter:reminderTimeViewCenter];
        
    CGPoint settingsReturnButtonViewCenter = [self.settingsReturnButtonView center];
    settingsReturnButtonViewCenter.x = self.view.bounds.size.width/2;
    settingsReturnButtonViewCenter.y = 500;
    [self.settingsReturnButtonView setCenter:settingsReturnButtonViewCenter];

    CGPoint setAlarmButtonViewCenter = [self.setAlarmButtonView center];
    setAlarmButtonViewCenter.x = self.view.bounds.size.width/2;
    setAlarmButtonViewCenter.y = 500;
    [self.setAlarmButtonView setCenter:setAlarmButtonViewCenter];
    
    CGPoint closeEveViewCenter = [self.closeEveView center];
    closeEveViewCenter.x = self.view.bounds.size.width/2;
    closeEveViewCenter.y = 400;
    [self.closeEveView setCenter:closeEveViewCenter];

    CGPoint resetButtonViewCenter = [self.resetButtonView center];
    resetButtonViewCenter.x = self.view.bounds.size.width/2;
    resetButtonViewCenter.y = 290;
    [self.resetButtonView setCenter:resetButtonViewCenter];
    
    CGPoint setToLoudModeViewCenter = [self.setToLoudModeView center];
    setToLoudModeViewCenter.x = self.view.bounds.size.width/2;
    setToLoudModeViewCenter.y = 150;
    [self.setToLoudModeView setCenter:setToLoudModeViewCenter];
    
    CGPoint returnSetSettingsViewCenter = [self.returnSetSettingsView center];
    returnSetSettingsViewCenter.x = self.view.bounds.size.width/2;
    returnSetSettingsViewCenter.y = 500;
    [self.returnSetSettingsView setCenter:returnSetSettingsViewCenter];
    
    
    [UIView commitAnimations];
    [_audioPlayer stop];
    
    defaults = [NSUserDefaults standardUserDefaults];
    NSString *sleepString = [NSString stringWithFormat:@"%d",hourOfSleep];
    [defaults setObject:sleepString forKey:@"hourOfSleep"];
    [defaults setObject:backgroundName forKey:@"background"];
    [defaults synchronize];
    
}

- (IBAction) pressSettingsButton{
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        self.setAlarmButton.alpha = 0;
    self.dragInstructions.alpha = 0;
        [UIView commitAnimations];
    
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        CGPoint menuButtonCenter = [self.menuButton center];
        menuButtonCenter.x = 296;
        menuButtonCenter.y = 500;
        [self.menuButton setCenter:menuButtonCenter];
    
        CGPoint infoButtonCenter = [self.infoButton center];
        infoButtonCenter.x = 26;
        infoButtonCenter.y = 500;
        [self.infoButton setCenter:infoButtonCenter];
    
        CGPoint backgroundLabelCenter = [self.backgroundLabelView center];
        backgroundLabelCenter.x = self.view.bounds.size.width/2;
        backgroundLabelCenter.y = 80;
        [self.backgroundLabelView setCenter:backgroundLabelCenter];
    
        CGPoint formatLabelCenter = [self.timeFormatLabelView center];
        formatLabelCenter.x = self.view.bounds.size.width/2;
        formatLabelCenter.y = 150;
        [self.timeFormatLabelView setCenter:formatLabelCenter];
        
        CGPoint soundNameLabelCenter = [self.soundNameLabelView center];
        soundNameLabelCenter.x = self.view.bounds.size.width/2;
        soundNameLabelCenter.y = 220;
        [self.soundNameLabelView setCenter:soundNameLabelCenter];
        
        CGPoint settingsReturnButtonViewCenter = [self.settingsReturnButtonView center];
        settingsReturnButtonViewCenter.x = self.view.bounds.size.width/2;
        settingsReturnButtonViewCenter.y = 360;
        [self.settingsReturnButtonView setCenter:settingsReturnButtonViewCenter];
    
        CGPoint closeEveViewCenter = [self.closeEveView center];
        closeEveViewCenter.x = self.view.bounds.size.width/2;
        closeEveViewCenter.y = 500;
        [self.closeEveView setCenter:closeEveViewCenter];
    
    self.rotaryKnob.alpha = 0;
        
        [UIView commitAnimations];
        
    }

-(IBAction)pressInfoButton{
    CGPoint infoCenter = [self.infoView center];
    infoCenter.x = self.view.bounds.size.width/20;
    infoCenter.y = 50;
    [self.infoView setCenter:infoCenter];
    
    self.reminderText.alpha=0;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    self.rotaryKnob.alpha = 0;
    self.setAlarmButton.alpha = 0;
    self.dragInstructions.alpha = 0;
    [UIView commitAnimations];
    
    [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(removeMenuView) userInfo:nil repeats:NO];
     [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(resizeInfoView) userInfo:nil repeats:NO];
}

- (void)removeMenuView{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    CGPoint center = [self.menuView center];
    center.x = self.view.bounds.size.width/2;
    center.y = 900;
    [self.menuBackgroundImage setCenter:center];

    self.wakeTimeLabel.alpha = 0;
    
    CGPoint timeCenter = [self.wakeTimeLabel center];
    timeCenter.x = self.view.bounds.size.width/2;
    timeCenter.y = -50;
    [self.wakeTimeLabel setCenter:timeCenter];
    
    [UIView commitAnimations];


}

- (void) hideSetAlarmElements {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.eveWillWakeLabel.alpha = 0;
    self.wakeReminderHours.alpha = 0;
    self.mondayLetter.alpha = 0;
    self.tuesdayLetter.alpha = 0;
    self.wednesdayLetter.alpha = 0;
    self.thursdayLetter.alpha = 0;
    self.fridayLetter.alpha = 0;
    self.saturdayLetter.alpha = 0;
    self.sundayLetter.alpha = 0;
    self.resetAlarmButton.alpha = 0;
    [UIView commitAnimations];
}

- (IBAction) pressInfoReturnButton{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    
    self.infoView.alpha = 0;
    
    [UIView commitAnimations];
    
    [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(replaceHomeView) userInfo:nil repeats:NO];
    
     [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(returnRotaryKnob) userInfo:nil repeats:NO];

}

-(void)resizeInfoView{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    CGPoint infoCenter = [self.infoView center];
    infoCenter.x = self.view.bounds.size.width/2;
    infoCenter.y = 240;
    [self.infoView setCenter:infoCenter];
    
    self.infoView.alpha = 0.8;
    [UIView commitAnimations];

}

-(void)replaceHomeView {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    
    CGPoint timeCenter = [self.wakeTimeLabel center];
    timeCenter.x = self.view.bounds.size.width/2;
    timeCenter.y = 104;
    [self.wakeTimeLabel setCenter:timeCenter];
    
    self.menuBackgroundImage.alpha = 1;
    self.wakeTimeLabel.alpha = 1;
    
    [UIView commitAnimations];
}

-(IBAction)tweet{
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"Hello @YonderApps !"];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
    
}

-(IBAction)website{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.evealarm.com"]];
}

-(void)returnRotaryKnob{
    self.reminderText.alpha=1;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    self.rotaryKnob.alpha = 0.4;
    self.setAlarmButton.alpha = 1;
    self.dragInstructions.alpha = 1;
    [UIView commitAnimations];

}

- (IBAction)pressSettingsReturnButton{

        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
        self.infoButton.alpha = 1;
        self.menuButton.alpha = 1;
    
        CGPoint menuButtonCenter = [self.menuButton center];
        menuButtonCenter.x = 296;
        menuButtonCenter.y = 120;
        [self.menuButton setCenter:menuButtonCenter];
    
        CGPoint infoButtonCenter = [self.infoButton center];
        infoButtonCenter.x = 26;
        infoButtonCenter.y = 122;
        [self.infoButton setCenter:infoButtonCenter];
    
        CGPoint settingsReturnButtonViewCenter = [self.settingsReturnButtonView center];
        settingsReturnButtonViewCenter.x = self.view.bounds.size.width/2;
        settingsReturnButtonViewCenter.y = 500;
        [self.settingsReturnButtonView setCenter:settingsReturnButtonViewCenter];
    
        CGPoint backgroundLabelCenter = [self.backgroundLabelView center];
        backgroundLabelCenter.x = self.view.bounds.size.width/2;
        backgroundLabelCenter.y = 500;
        [self.backgroundLabelView setCenter:backgroundLabelCenter];
    
        CGPoint formatLabelCenter = [self.timeFormatLabelView center];
        formatLabelCenter.x = self.view.bounds.size.width/2;
        formatLabelCenter.y = 500;
        [self.timeFormatLabelView setCenter:formatLabelCenter];
        
        CGPoint soundNameLabelCenter = [self.soundNameLabelView center];
        soundNameLabelCenter.x = self.view.bounds.size.width/2;
        soundNameLabelCenter.y = 500;
        [self.soundNameLabelView setCenter:soundNameLabelCenter];
    
        CGPoint closeEveViewCenter = [self.closeEveView center];
        closeEveViewCenter.x = self.view.bounds.size.width/2;
        closeEveViewCenter.y = 500;
        [self.closeEveView setCenter:closeEveViewCenter];
    
        [UIView commitAnimations];
    
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        self.setAlarmButton.alpha = 1;

        [UIView commitAnimations];
    
    NSLog(@"Menu Button X = %f, Menu Button Y = %f", menuButtonCenter.x,menuButtonCenter.y);

    
    self.rotaryKnob.alpha = 0.4;

    [_audioPlayer stop];
    }
- (IBAction) pressReturnSetSettingsButton{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    self.infoButton.alpha = 1;
    self.menuButton.alpha = 1;
    
    CGPoint menuButtonCenter = [self.menuButton center];
    menuButtonCenter.x = 296;
    menuButtonCenter.y = 120;
    [self.menuButton setCenter:menuButtonCenter];
    
    CGPoint infoButtonCenter = [self.infoButton center];
    infoButtonCenter.x = 26;
    infoButtonCenter.y = 122;
    [self.infoButton setCenter:infoButtonCenter];
    
    CGPoint backgroundLabelCenter = [self.backgroundLabelView center];
    backgroundLabelCenter.x = self.view.bounds.size.width/2;
    backgroundLabelCenter.y = 500;
    [self.backgroundLabelView setCenter:backgroundLabelCenter];
    
    CGPoint formatLabelCenter = [self.timeFormatLabelView center];
    formatLabelCenter.x = self.view.bounds.size.width/2;
    formatLabelCenter.y = 500;
    [self.timeFormatLabelView setCenter:formatLabelCenter];
    
    CGPoint setAlarmButtonViewCenter = [self.setAlarmButtonView center];
    setAlarmButtonViewCenter.x = self.view.bounds.size.width/2;
    setAlarmButtonViewCenter.y = 500;
    [self.setAlarmButtonView setCenter:setAlarmButtonViewCenter];
    
    CGPoint soundNameLabelCenter = [self.soundNameLabelView center];
    soundNameLabelCenter.x = self.view.bounds.size.width/2;
    soundNameLabelCenter.y = 500;
    [self.soundNameLabelView setCenter:soundNameLabelCenter];
    
    [UIView commitAnimations];
    
    CGPoint closeEveViewCenter = [self.closeEveView center];
    closeEveViewCenter.x = self.view.bounds.size.width/2;
    closeEveViewCenter.y = 500;
    [self.closeEveView setCenter:closeEveViewCenter];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.setAlarmButton.alpha = 1;
    
    [UIView commitAnimations];

    self.rotaryKnob.alpha = 0.4;
    [_audioPlayer stop];
}


- (IBAction)changeHourFormat{
    if([hourFormat isEqual: @"HH mm a"]){
        hourFormat = @"h mm a";
        NSDateFormatter *labelFormat = [[NSDateFormatter alloc] init];
        [labelFormat setDateFormat:hourFormat];
        self.wakeTimeLabel.text = [NSString stringWithFormat:@"%@", [labelFormat stringFromDate:[[NSDate date] dateByAddingTimeInterval: self.rotaryKnob.value*800]]];
        self.menuHourFormatLabel.text = @"12 hour";
    }else if([hourFormat isEqual:@"h mm a"]){
        hourFormat = @"HH mm a";
        NSDateFormatter *labelFormat = [[NSDateFormatter alloc] init];
        [labelFormat setDateFormat:hourFormat];
        self.wakeTimeLabel.text = [NSString stringWithFormat:@"%@", [labelFormat stringFromDate:[[NSDate date] dateByAddingTimeInterval: self.rotaryKnob.value*800]]];
        self.menuHourFormatLabel.text = @"24 hour";

    }
}

- (IBAction) nextBackground{
    if([defaults boolForKey:@"unlocked"]){
    if([backgroundName isEqual:@"background1.png"]){
        backgroundName = @"background2.png";
        self.skyBackground.image = [UIImage imageNamed:@"background5"];
        self.backgroundLabel.text = @"Autumn";
        [defaults setObject:backgroundName forKey:@"background"];
        [defaults synchronize];
    }else if ([backgroundName isEqual:@"background2.png"]){
        backgroundName = @"background3.png";
        self.skyBackground.image = [UIImage imageNamed:@"background3"];
        self.backgroundLabel.text = @"Winter";
        [defaults setObject:backgroundName forKey:@"background"];
        [defaults synchronize];
    }else if ([backgroundName isEqual:@"background3.png"]){
        backgroundName = @"background4.png";
        self.skyBackground.image = [UIImage imageNamed:@"background6"];
        self.backgroundLabel.text = @"Spring";
        [defaults setObject:backgroundName forKey:@"background"];
        [defaults synchronize];
    }else if ([backgroundName isEqual:@"background4.png"]){
        backgroundName = @"background1.png";
        self.skyBackground.image = [UIImage imageNamed:@"background1"];
        self.backgroundLabel.text = @"Summer";
        [defaults setObject:backgroundName forKey:@"background"];
        [defaults synchronize];
    }
    }else {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        self.IAPView.alpha = 1;
        [UIView commitAnimations];
    }
}

-(IBAction) hideIAPView{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.IAPView.alpha = 0;
    [UIView commitAnimations];
}
- (IBAction) prevBackground{
    if([defaults boolForKey:@"unlocked"]){
    if([backgroundName isEqual:@"background1.png"]){
        backgroundName = @"background4.png";
        self.skyBackground.image = [UIImage imageNamed:@"background4"];
        self.backgroundLabel.text = @"Spring";
        [defaults setObject:backgroundName forKey:@"background"];
        [defaults synchronize];
    }else if ([backgroundName isEqual:@"background4.png"]){
        backgroundName = @"background1.png";
        self.skyBackground.image = [UIImage imageNamed:@"background3"];
        self.backgroundLabel.text = @"Winter";
        [defaults setObject:backgroundName forKey:@"background"];
        [defaults synchronize];
    }else if ([backgroundName isEqual:@"background3.png"]){
        backgroundName = @"background2.png";
        self.skyBackground.image = [UIImage imageNamed:@"background2"];
        self.backgroundLabel.text = @"Autumn";
        [defaults setObject:backgroundName forKey:@"background"];
        [defaults synchronize];
    }else if ([backgroundName isEqual:@"background2.png"]){
        backgroundName = @"background1.png";
        self.skyBackground.image = [UIImage imageNamed:@"background1"];
        self.backgroundLabel.text = @"Summer";
        [defaults setObject:backgroundName forKey:@"background"];
        [defaults synchronize];
    }
    }else{
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        self.IAPView.alpha = 1;
        [UIView commitAnimations];
        [self fetchAvailableProducts];
        
        //self.IAPlabel.text = [NSString stringWithFormat:NSLocalizedString(@"bla costs are %@%@", nil), [proUpgradeProduct.priceLocale objectForKey:NSLocaleCurrencySymbol], [proUpgradeProduct.price stringValue]];
        
        NSLog(@"iap text= %@",self.IAPlabel.text);
        
    }
}

- (IBAction) nextAlarm{
    
    if ([alarmNameString isEqual: @"eveAlarm1.wav"]) {
        alarmNameString = @"eveAlarm2.wav";
        [self.soundButton setTitle:@"Ludwig" forState:UIControlStateNormal];
        NSLog(@"alarm name is %@",alarmNameString);
    }else if ([alarmNameString isEqual: @"eveAlarm2.wav"]){
        alarmNameString = @"eveAlarm3.wav";
        NSLog(@"alarm name is %@",alarmNameString);
        [self.soundButton setTitle:@"Orient" forState:UIControlStateNormal];
    }else if ([alarmNameString isEqual: @"eveAlarm3.wav"]){
        alarmNameString = @"eveAlarm4.wav";
        [self.soundButton setTitle:@"Cassius" forState:UIControlStateNormal];
        NSLog(@"alarm name is %@",alarmNameString);
    }else if ([alarmNameString isEqual: @"eveAlarm4.wav"]){
        alarmNameString = @"eveAlarm1.wav";
        [self.soundButton setTitle:@"Module" forState:UIControlStateNormal];
        NSLog(@"alarm name is %@",alarmNameString);
    }
    
    [_audioPlayer stop];
    isPlaying = NO;
}

- (IBAction) prevAlarm{
    
    if ([alarmNameString isEqual: @"eveAlarm1.wav"]) {
        alarmNameString = @"eveAlarm4.wav";
        [self.soundButton setTitle:@"Cassius" forState:UIControlStateNormal];
        NSLog(@"alarm name is %@",alarmNameString);
    }else if ([alarmNameString isEqual: @"eveAlarm4.wav"]){
        alarmNameString = @"eveAlarm3.wav";
        NSLog(@"alarm name is %@",alarmNameString);
        [self.soundButton setTitle:@"Orient" forState:UIControlStateNormal];
    }else if ([alarmNameString isEqual: @"eveAlarm3.wav"]){
        alarmNameString = @"eveAlarm2.wav";
        [self.soundButton setTitle:@"Ludwig" forState:UIControlStateNormal];
        NSLog(@"alarm name is %@",alarmNameString);
    }else if ([alarmNameString isEqual: @"eveAlarm2.wav"]){
        alarmNameString = @"eveAlarm1.wav";
        [self.soundButton setTitle:@"Module" forState:UIControlStateNormal];
        NSLog(@"alarm name is %@",alarmNameString);
    }
    
    [_audioPlayer stop];
    isPlaying  = NO;
}

- (IBAction) pressSoundButton{
   /* if(isPlaying == NO){CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFURLRef soundFileURLRef;
    soundFileURLRef = CFBundleCopyResourceURL(mainBundle, (CFStringRef)@"eveAlarm1", CFSTR ("wav"), NULL);
    
    UInt32 soundID;
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundID);
    AudioServicesPlaySystemSound(soundID);
        isPlaying = YES;
    */
    
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath],alarmNameString]];
    NSError *error;
    _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
    
    if(isPlaying == NO){
        [_audioPlayer play];
        isPlaying = YES;
    }else if(isPlaying == YES){
        [_audioPlayer stop];
        isPlaying = NO;
    }
    }

- (IBAction) pressResetButton{
    
    [[UIApplication sharedApplication]cancelAllLocalNotifications];
    NSLog(@"Alarms Cancelled");
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    self.menuButton.alpha = 1;
    self.infoButton.alpha = 1;
    
    self.eveWillWakeLabel.alpha = 0;
    self.menuBackground.alpha = 1;
    self.wakeReminderHours.alpha = 0;
    self.mondayLetter.alpha = 0;
    self.tuesdayLetter.alpha = 0;
    self.wednesdayLetter.alpha = 0;
    self.thursdayLetter.alpha = 0;
    self.fridayLetter.alpha = 0;
    self.saturdayLetter.alpha = 0;
    self.sundayLetter.alpha = 0;
    self.reminderText.alpha = 0;
    
    [self.mondayLetter setTextColor:[UIColor lightGrayColor]];
    [self.tuesdayLetter setTextColor:[UIColor lightGrayColor]];
    [self.wednesdayLetter setTextColor:[UIColor lightGrayColor]];
    [self.thursdayLetter setTextColor:[UIColor lightGrayColor]];
    [self.fridayLetter setTextColor:[UIColor lightGrayColor]];
    [self.saturdayLetter setTextColor:[UIColor lightGrayColor]];
    [self.sundayLetter setTextColor:[UIColor lightGrayColor]];
           
    [defaults setBool:NO forKey:@"mondayAlarm"];
    [defaults setBool:NO forKey:@"tuesdayAlarm"];
    [defaults setBool:NO forKey:@"wednesdayAlarm"];
    [defaults setBool:NO forKey:@"thursdayAlarm"];
    [defaults setBool:NO forKey:@"fridayAlarm"];
    [defaults setBool:NO forKey:@"saturdayAlarm"];
    [defaults setBool:NO forKey:@"sundayAlarm"];
    [defaults synchronize];
    
    CGPoint menuButtonCenter = [self.menuButton center];
    menuButtonCenter.x = 296;
    menuButtonCenter.y = 120;
    [self.menuButton setCenter:menuButtonCenter];
    
    CGPoint infoButtonCenter = [self.infoButton center];
    infoButtonCenter.x = 26;
    infoButtonCenter.y = 122;
    [self.infoButton setCenter:infoButtonCenter];
    
    CGPoint backgroundLabelCenter = [self.backgroundLabelView center];
    backgroundLabelCenter.x = self.view.bounds.size.width/2;
    backgroundLabelCenter.y = 500;
    [self.backgroundLabelView setCenter:backgroundLabelCenter];
    
    CGPoint setAlarmButtonViewCenter = [self.setAlarmButtonView center];
    setAlarmButtonViewCenter.x = self.view.bounds.size.width/2;
    setAlarmButtonViewCenter.y = 500;
    [self.setAlarmButtonView setCenter:setAlarmButtonViewCenter];
    
    CGPoint formatLabelCenter = [self.timeFormatLabelView center];
    formatLabelCenter.x = self.view.bounds.size.width/2;
    formatLabelCenter.y = 500;
    [self.timeFormatLabelView setCenter:formatLabelCenter];
    
    CGPoint soundNameLabelCenter = [self.soundNameLabelView center];
    soundNameLabelCenter.x = self.view.bounds.size.width/2;
    soundNameLabelCenter.y = 500;
    [self.soundNameLabelView setCenter:soundNameLabelCenter];
    
    CGPoint reminderTimeViewCenter = [self.reminderTimeView center];
    reminderTimeViewCenter.x = self.view.bounds.size.width/2;
    reminderTimeViewCenter.y = 500;
    [self.reminderTimeView setCenter:reminderTimeViewCenter];
    
    CGPoint resetButtonViewCenter = [self.resetButtonView center];
    resetButtonViewCenter.x = self.view.bounds.size.width/2;
    resetButtonViewCenter.y = 500;
    [self.resetButtonView setCenter:resetButtonViewCenter];
    
    CGPoint setToLoudModeViewCenter = [self.setToLoudModeView center];
    setToLoudModeViewCenter.x = self.view.bounds.size.width/2;
    setToLoudModeViewCenter.y = 500;
    [self.setToLoudModeView setCenter:setToLoudModeViewCenter];
    
    CGPoint closeEveViewCenter = [self.closeEveView center];
    closeEveViewCenter.x = self.view.bounds.size.width/2;
    closeEveViewCenter.y = 500;
    [self.closeEveView setCenter:closeEveViewCenter];
    
    [UIView commitAnimations];
    
    [self performSelector:@selector(showRotaryKnob) withObject:self afterDelay:0.3 ];

}

- (void) showRotaryKnob{
    [UIView beginAnimations:Nil context:NULL];
    [UIView setAnimationDuration:0.5];
    self.rotaryKnob.alpha = 0.4;
    self.setAlarmButton.alpha = 1;
    [UIView commitAnimations];
}

-(NSString *) wakeMessage{
    NSString* wakeMessageString;
    NSArray* wakeMessageArr = [NSArray arrayWithObjects: @"An early-morning walk is a blessing for the whole day - Henry David Thoreau",
                        @"Think in the morning, act in the noon, eat in the evening, sleep in the night - William Blake", @"Each morning when I awake, I exprience again a supreme pleasure: That of being Salvador Dali - Salvador Dali", @"Lose an hour in the morning and you will spend all day looking for it - Richard Whately", @"When I wake up in the morning, I feel just like any other insecure 24-year-old girl - Lady Gaga",
                        @"I became a musician so I didn't have to wake up at 6 in the morning - Norah Jones", @"I get up in the morning, looking for an adventure - George Foreman!", nil];
    NSUInteger randomIndex = arc4random() % [wakeMessageArr count];
    wakeMessageString = [wakeMessageArr objectAtIndex: randomIndex];
    return wakeMessageString;
}

- (IBAction) pressDaysReturnButton{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    CGPoint daysCenter = [self.daysView center];
    daysCenter.y = self.view.bounds.size.height+1000;
    [self.daysView setCenter:daysCenter];
    
    self.setAlarmButton.alpha = 1;
    self.rotaryKnob.alpha = 0.4;
    self.menuBackgroundImage.alpha = 1;

    [UIView commitAnimations];
    self.infoButton.alpha = 1;
    self.menuButton.alpha = 1;
    NSLog(@"Button Pressed");
}

- (IBAction) pressMenuReturnButton {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    self.infoButton.alpha = 0;
    self.menuButton.alpha = 0;
    
    CGPoint settingsCenter = [self.settingsView center];
    settingsCenter.y = self.view.bounds.size.height+800;
    [self.settingsView setCenter:settingsCenter];
    [UIView commitAnimations];
    
    [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(presentDaysView) userInfo:nil repeats:NO];
}

- (void) presentDaysView {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    CGPoint daysCenter = [self.daysView center];
    daysCenter.y = self.view.bounds.size.height-150;
    [self.daysView setCenter:daysCenter];
    [UIView commitAnimations];
}

- (IBAction) pressMondayButton{
    if(self.mondayButton.selected == YES)
        self.mondayButton.selected = NO;
    else if (self.mondayButton.selected == NO)
        self.mondayButton.selected = YES;
}
- (IBAction) pressTuesdayButton{
    if(self.tuesdayButton.selected == YES)
        self.tuesdayButton.selected = NO;
    else if (self.tuesdayButton.selected == NO)
        self.tuesdayButton.selected = YES;
}
- (IBAction) pressWednesdayButton{
    if(self.wednesdayButton.selected == YES)
        self.wednesdayButton.selected = NO;
    else if (self.wednesdayButton.selected == NO)
        self.wednesdayButton.selected = YES;
}
- (IBAction) pressThursdayButton{
    if(self.thursdayButton.selected == YES)
        self.thursdayButton.selected = NO;
    else if (self.thursdayButton.selected == NO)
        self.thursdayButton.selected = YES;
}

- (IBAction) pressFridayButton{
    if(self.fridayButton.selected == YES)
        self.fridayButton.selected = NO;
    else if (self.fridayButton.selected == NO)
        self.fridayButton.selected = YES;
}

- (IBAction) pressSaturdayButton{
    if(self.saturdayButton.selected == YES)
        self.saturdayButton.selected = NO;
    else if (self.saturdayButton.selected == NO)
        self.saturdayButton.selected = YES;
}

- (IBAction) pressSundayButton{
    if(self.sundayButton.selected == YES)
        self.sundayButton.selected = NO;
    else if (self.sundayButton.selected == NO)
        self.sundayButton.selected = YES;
}
- (IBAction) pressDaysContinueButton{
    
    if (self.mondayButton.selected == NO && self.tuesdayButton.selected == NO && self.wednesdayButton.selected == NO && self.thursdayButton.selected == NO && self.fridayButton.selected == NO && self.saturdayButton.selected == NO && self.sundayButton.selected == NO) {
        
    }else{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    CGPoint daysCenter = [self.daysView center];
    daysCenter.y = self.view.bounds.size.height+400;
    [self.daysView setCenter:daysCenter];
        
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    CGPoint returnButtoncenter = [self.daysView center];
    returnButtoncenter.x = self.view.bounds.size.width/2;
        
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(presentMenuView) userInfo:nil repeats:NO];
    }
    }

- (IBAction)pressSettingsContinueButton:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    CGPoint settingsCenter = [self.settingsView center];
    settingsCenter.y = self.view.bounds.size.height+400;
    [self.settingsView setCenter:settingsCenter];
    [UIView commitAnimations];
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(presentAlarmSettings) userInfo:nil repeats:NO];
    [self setAlarm];
}

- (void) presentAlarmSettings {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.eveWillWakeLabel.alpha = 1;
    self.wakeReminderHours.alpha = 1;
    self.resetAlarmButton.alpha = 1;
    [UIView commitAnimations];
}

-(void)presentMenuView {
    CGPoint settingsCenter = [self.settingsView center];
    settingsCenter.y = self.view.bounds.size.height-65;
    [self.settingsView setCenter:settingsCenter];
    [UIView commitAnimations];
}

- (void) setMondayAlarm{
    NSDate *alarmTime = [[NSDate date] dateByAddingTimeInterval: self.rotaryKnob.value*800];
    NSLog(@"alarm time is %@",alarmTime );
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:[NSDate date]];
    
    NSDateComponents *alarmComponents = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:alarmTime];
    
    [components setWeekday:2];
    [components setHour:alarmComponents.hour];
    
    if (alarmComponents.minute == 1|
        alarmComponents.minute == 6|
        alarmComponents.minute == 11|
        alarmComponents.minute == 16|
        alarmComponents.minute == 21|
        alarmComponents.minute == 26|
        alarmComponents.minute == 31|
        alarmComponents.minute == 36|
        alarmComponents.minute == 41|
        alarmComponents.minute == 46|
        alarmComponents.minute == 51|
        alarmComponents.minute == 56
        ){
        alarmComponents.minute = alarmComponents.minute-1;
    }else if (alarmComponents.minute == 2|
              alarmComponents.minute == 7|
              alarmComponents.minute == 12|
              alarmComponents.minute == 17|
              alarmComponents.minute == 22|
              alarmComponents.minute == 27|
              alarmComponents.minute == 32|
              alarmComponents.minute == 37|
              alarmComponents.minute == 42|
              alarmComponents.minute == 47|
              alarmComponents.minute == 52|
              alarmComponents.minute == 57
              ){
        alarmComponents.minute = alarmComponents.minute-2;
    } else if (alarmComponents.minute == 3|
               alarmComponents.minute == 8|
               alarmComponents.minute == 13|
               alarmComponents.minute == 18|
               alarmComponents.minute == 23|
               alarmComponents.minute == 28|
               alarmComponents.minute == 33|
               alarmComponents.minute == 38|
               alarmComponents.minute == 43|
               alarmComponents.minute == 48|
               alarmComponents.minute == 53|
               alarmComponents.minute == 58
               ){
        alarmComponents.minute = alarmComponents.minute+2;
    } else if (alarmComponents.minute == 4|
               alarmComponents.minute == 9|
               alarmComponents.minute == 14|
               alarmComponents.minute == 19|
               alarmComponents.minute == 24|
               alarmComponents.minute == 29|
               alarmComponents.minute == 34|
               alarmComponents.minute == 39|
               alarmComponents.minute == 44|
               alarmComponents.minute == 49|
               alarmComponents.minute == 54|
               alarmComponents.minute == 59
               ){
        alarmComponents.minute = alarmComponents.minute+1;
    }

    [components setMinute:alarmComponents.minute];
    
    NSDate *alarmDate = [gregorian dateFromComponents:components];
    
    if ([alarmDate compare:[NSDate date]] == NSOrderedAscending) {
        alarmDate = [alarmDate dateByAddingTimeInterval:60*60*24*7];
    }
    
    NSLog(@"%@", alarmDate);
    firedate = alarmDate;

    mondayWakeAlarm = [[UILocalNotification alloc]init];
    mondayReminderAlarm = [[UILocalNotification alloc]init];
    
    mondayWakeAlarm.fireDate = alarmDate;
    mondayWakeAlarm.repeatInterval = NSWeekCalendarUnit;
    mondayWakeAlarm.alertBody = [self wakeMessage];
    mondayWakeAlarm.soundName = alarmNameString;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:mondayWakeAlarm];
    
    NSDate *reminderDate = [firedate dateByAddingTimeInterval:-60*60*hourOfSleep];
    
    mondayReminderAlarm.fireDate = reminderDate;
    mondayReminderAlarm.repeatInterval = NSWeekCalendarUnit;
    mondayReminderAlarm.soundName = @"sleepAlarm1.wav";
    mondayReminderAlarm.alertBody = @"Time for bed!";
    
    if ([reminderDate compare:[NSDate date]] == NSOrderedDescending) {
        NSLog(@"Reminder Alarm Set for %@",reminderDate);
        [[UIApplication sharedApplication] scheduleLocalNotification:mondayReminderAlarm];
    }
    
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"mondayAlarm"];
    
    NSDateFormatter *labelFormat = [[NSDateFormatter alloc] init];
    [labelFormat setDateFormat:hourFormat];
    self.reminderTimeLabel.text = [labelFormat stringFromDate:[firedate dateByAddingTimeInterval:-hourOfSleep*60*60]];
    
    NSString *alarmString = [labelFormat stringFromDate:firedate];
    [defaults setObject:alarmString forKey:@"wakeString"];
    
}

- (void) setTuesdayAlarm{
    NSDate *alarmTime = [[NSDate date] dateByAddingTimeInterval: self.rotaryKnob.value*800];
    NSLog(@"alarm time is %@",alarmTime );
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:[NSDate date]];
    
    NSDateComponents *alarmComponents = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:alarmTime];
    
    [components setWeekday:3];
    [components setHour:alarmComponents.hour];
    
    if (alarmComponents.minute == 1|
        alarmComponents.minute == 6|
        alarmComponents.minute == 11|
        alarmComponents.minute == 16|
        alarmComponents.minute == 21|
        alarmComponents.minute == 26|
        alarmComponents.minute == 31|
        alarmComponents.minute == 36|
        alarmComponents.minute == 41|
        alarmComponents.minute == 46|
        alarmComponents.minute == 51|
        alarmComponents.minute == 56
        ){
        alarmComponents.minute = alarmComponents.minute-1;
    }else if (alarmComponents.minute == 2|
              alarmComponents.minute == 7|
              alarmComponents.minute == 12|
              alarmComponents.minute == 17|
              alarmComponents.minute == 22|
              alarmComponents.minute == 27|
              alarmComponents.minute == 32|
              alarmComponents.minute == 37|
              alarmComponents.minute == 42|
              alarmComponents.minute == 47|
              alarmComponents.minute == 52|
              alarmComponents.minute == 57
              ){
        alarmComponents.minute = alarmComponents.minute-2;
    } else if (alarmComponents.minute == 3|
               alarmComponents.minute == 8|
               alarmComponents.minute == 13|
               alarmComponents.minute == 18|
               alarmComponents.minute == 23|
               alarmComponents.minute == 28|
               alarmComponents.minute == 33|
               alarmComponents.minute == 38|
               alarmComponents.minute == 43|
               alarmComponents.minute == 48|
               alarmComponents.minute == 53|
               alarmComponents.minute == 58
               ){
        alarmComponents.minute = alarmComponents.minute+2;
    } else if (alarmComponents.minute == 4|
               alarmComponents.minute == 9|
               alarmComponents.minute == 14|
               alarmComponents.minute == 19|
               alarmComponents.minute == 24|
               alarmComponents.minute == 29|
               alarmComponents.minute == 34|
               alarmComponents.minute == 39|
               alarmComponents.minute == 44|
               alarmComponents.minute == 49|
               alarmComponents.minute == 54|
               alarmComponents.minute == 59
               ){
        alarmComponents.minute = alarmComponents.minute+1;
    }
    
    [components setMinute:alarmComponents.minute];
    
    
    NSDate *alarmDate = [gregorian dateFromComponents:components];
    
    if ([alarmDate compare:[NSDate date]] == NSOrderedAscending) {
        alarmDate = [alarmDate dateByAddingTimeInterval:60*60*24*7];
    }
    
    NSLog(@"%@", alarmDate);
    firedate = alarmDate;
    
    tuesdayWakeAlarm = [[UILocalNotification alloc]init];
    tuesdayReminderAlarm = [[UILocalNotification alloc]init];
    
    tuesdayWakeAlarm.fireDate = alarmDate;
    tuesdayWakeAlarm.repeatInterval = NSWeekCalendarUnit;
    tuesdayWakeAlarm.alertBody = [self wakeMessage];
    tuesdayWakeAlarm.soundName = alarmNameString;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:tuesdayWakeAlarm];
    
    NSDate *reminderDate = [firedate dateByAddingTimeInterval:-60*60*hourOfSleep];
    
    tuesdayReminderAlarm.fireDate = reminderDate;
    tuesdayReminderAlarm.repeatInterval = NSWeekCalendarUnit;
    tuesdayReminderAlarm.alertBody = @"Time for bed!";
    tuesdayReminderAlarm.soundName = @"sleepAlarm1.wav";
    
    if ([reminderDate compare:[NSDate date]] == NSOrderedDescending) {
        NSLog(@"Reminder Alarm Set for %@",reminderDate);
        [[UIApplication sharedApplication] scheduleLocalNotification:tuesdayReminderAlarm];
    }
    
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"tuesdayAlarm"];
    
    NSDateFormatter *labelFormat = [[NSDateFormatter alloc] init];
    [labelFormat setDateFormat:hourFormat];
    self.reminderTimeLabel.text = [labelFormat stringFromDate:[firedate dateByAddingTimeInterval:-hourOfSleep*60*60]];

    
    NSString *alarmString = [labelFormat stringFromDate:firedate];
    [defaults setObject:alarmString forKey:@"wakeString"];

}
- (void) setWednesdayAlarm{
    NSDate *alarmTime = [[NSDate date] dateByAddingTimeInterval: self.rotaryKnob.value*800];
    NSLog(@"alarm time is %@",alarmTime );
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:[NSDate date]];
    
    NSDateComponents *alarmComponents = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:alarmTime];
    
    [components setWeekday:4];
    [components setHour:alarmComponents.hour];
    
    if (alarmComponents.minute == 1|
        alarmComponents.minute == 6|
        alarmComponents.minute == 11|
        alarmComponents.minute == 16|
        alarmComponents.minute == 21|
        alarmComponents.minute == 26|
        alarmComponents.minute == 31|
        alarmComponents.minute == 36|
        alarmComponents.minute == 41|
        alarmComponents.minute == 46|
        alarmComponents.minute == 51|
        alarmComponents.minute == 56
        ){
        alarmComponents.minute = alarmComponents.minute-1;
    }else if (alarmComponents.minute == 2|
              alarmComponents.minute == 7|
              alarmComponents.minute == 12|
              alarmComponents.minute == 17|
              alarmComponents.minute == 22|
              alarmComponents.minute == 27|
              alarmComponents.minute == 32|
              alarmComponents.minute == 37|
              alarmComponents.minute == 42|
              alarmComponents.minute == 47|
              alarmComponents.minute == 52|
              alarmComponents.minute == 57
              ){
        alarmComponents.minute = alarmComponents.minute-2;
    } else if (alarmComponents.minute == 3|
               alarmComponents.minute == 8|
               alarmComponents.minute == 13|
               alarmComponents.minute == 18|
               alarmComponents.minute == 23|
               alarmComponents.minute == 28|
               alarmComponents.minute == 33|
               alarmComponents.minute == 38|
               alarmComponents.minute == 43|
               alarmComponents.minute == 48|
               alarmComponents.minute == 53|
               alarmComponents.minute == 58
               ){
        alarmComponents.minute = alarmComponents.minute+2;
    } else if (alarmComponents.minute == 4|
               alarmComponents.minute == 9|
               alarmComponents.minute == 14|
               alarmComponents.minute == 19|
               alarmComponents.minute == 24|
               alarmComponents.minute == 29|
               alarmComponents.minute == 34|
               alarmComponents.minute == 39|
               alarmComponents.minute == 44|
               alarmComponents.minute == 49|
               alarmComponents.minute == 54|
               alarmComponents.minute == 59
               ){
        alarmComponents.minute = alarmComponents.minute+1;
    }
    
    [components setMinute:alarmComponents.minute];
    
    
    NSDate *alarmDate = [gregorian dateFromComponents:components];
    
    if ([alarmDate compare:[NSDate date]] == NSOrderedAscending) {
        alarmDate = [alarmDate dateByAddingTimeInterval:60*60*24*7];
    }
    
    NSLog(@"%@", alarmDate);
    
    firedate = alarmDate;

    wednesdayWakeAlarm = [[UILocalNotification alloc]init];
    wednesdayReminderAlarm = [[UILocalNotification alloc]init];
    
    wednesdayWakeAlarm.fireDate = alarmDate;
    wednesdayWakeAlarm.repeatInterval = NSWeekCalendarUnit;
    wednesdayWakeAlarm.alertBody = [self wakeMessage];
    wednesdayWakeAlarm.soundName = alarmNameString;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:wednesdayWakeAlarm];
    
    NSDate *reminderDate = [firedate dateByAddingTimeInterval:-60*60*hourOfSleep];
    
    wednesdayReminderAlarm.fireDate = reminderDate;
    wednesdayReminderAlarm.repeatInterval = NSWeekCalendarUnit;
    wednesdayReminderAlarm.alertBody = @"Time for bed!";
    wednesdayReminderAlarm.soundName = @"sleepAlarm1.wav";
    
    if ([reminderDate compare:[NSDate date]] == NSOrderedDescending) {
        NSLog(@"Reminder Alarm Set for %@",reminderDate);
        [[UIApplication sharedApplication] scheduleLocalNotification:wednesdayReminderAlarm];
    }
    
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"wednesdayAlarm"];
    
    NSDateFormatter *labelFormat = [[NSDateFormatter alloc] init];
    [labelFormat setDateFormat:hourFormat];
    self.reminderTimeLabel.text = [labelFormat stringFromDate:[firedate dateByAddingTimeInterval:-hourOfSleep*60*60]];

    NSString *alarmString = [labelFormat stringFromDate:firedate];
    [defaults setObject:alarmString forKey:@"wakeString"];
    
}
- (void) setThursdayAlarm{
    NSDate *alarmTime = [[NSDate date] dateByAddingTimeInterval: self.rotaryKnob.value*800];
    NSLog(@"alarm time is %@",alarmTime );
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:[NSDate date]];
    
    NSDateComponents *alarmComponents = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:alarmTime];
    
    [components setWeekday:5];
    [components setHour:alarmComponents.hour];
    
    if (alarmComponents.minute == 1|
        alarmComponents.minute == 6|
        alarmComponents.minute == 11|
        alarmComponents.minute == 16|
        alarmComponents.minute == 21|
        alarmComponents.minute == 26|
        alarmComponents.minute == 31|
        alarmComponents.minute == 36|
        alarmComponents.minute == 41|
        alarmComponents.minute == 46|
        alarmComponents.minute == 51|
        alarmComponents.minute == 56
        ){
        alarmComponents.minute = alarmComponents.minute-1;
    }else if (alarmComponents.minute == 2|
              alarmComponents.minute == 7|
              alarmComponents.minute == 12|
              alarmComponents.minute == 17|
              alarmComponents.minute == 22|
              alarmComponents.minute == 27|
              alarmComponents.minute == 32|
              alarmComponents.minute == 37|
              alarmComponents.minute == 42|
              alarmComponents.minute == 47|
              alarmComponents.minute == 52|
              alarmComponents.minute == 57
              ){
        alarmComponents.minute = alarmComponents.minute-2;
    } else if (alarmComponents.minute == 3|
               alarmComponents.minute == 8|
               alarmComponents.minute == 13|
               alarmComponents.minute == 18|
               alarmComponents.minute == 23|
               alarmComponents.minute == 28|
               alarmComponents.minute == 33|
               alarmComponents.minute == 38|
               alarmComponents.minute == 43|
               alarmComponents.minute == 48|
               alarmComponents.minute == 53|
               alarmComponents.minute == 58
               ){
        alarmComponents.minute = alarmComponents.minute+2;
    } else if (alarmComponents.minute == 4|
               alarmComponents.minute == 9|
               alarmComponents.minute == 14|
               alarmComponents.minute == 19|
               alarmComponents.minute == 24|
               alarmComponents.minute == 29|
               alarmComponents.minute == 34|
               alarmComponents.minute == 39|
               alarmComponents.minute == 44|
               alarmComponents.minute == 49|
               alarmComponents.minute == 54|
               alarmComponents.minute == 59
               ){
        alarmComponents.minute = alarmComponents.minute+1;
    }
    
    [components setMinute:alarmComponents.minute];
    
    
    NSDate *alarmDate = [gregorian dateFromComponents:components];
    
    if ([alarmDate compare:[NSDate date]] == NSOrderedAscending) {
        alarmDate = [alarmDate dateByAddingTimeInterval:60*60*24*7];
    }
    
    NSLog(@"%@", alarmDate);
    
    firedate = alarmDate;
    
    thursdayWakeAlarm = [[UILocalNotification alloc]init];
    thursdayReminderAlarm = [[UILocalNotification alloc]init];
    
    thursdayWakeAlarm.fireDate = alarmDate;
    thursdayWakeAlarm.repeatInterval = NSWeekCalendarUnit;
    thursdayWakeAlarm.alertBody = [self wakeMessage];
    thursdayWakeAlarm.soundName = alarmNameString;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:thursdayWakeAlarm];
    
    NSDate *reminderDate = [firedate dateByAddingTimeInterval:-60*60*hourOfSleep];
    
    thursdayReminderAlarm.fireDate = reminderDate;
    thursdayReminderAlarm.repeatInterval = NSWeekCalendarUnit;
    thursdayReminderAlarm.alertBody = @"Time for bed!";
    thursdayReminderAlarm.soundName = @"sleepAlarm1.wav";
    
    if ([reminderDate compare:[NSDate date]] == NSOrderedDescending) {
        NSLog(@"Reminder Alarm Set for %@",reminderDate);
        [[UIApplication sharedApplication] scheduleLocalNotification:thursdayReminderAlarm];
    }
    
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"thursdayAlarm"];

    NSDateFormatter *labelFormat = [[NSDateFormatter alloc] init];
    [labelFormat setDateFormat:hourFormat];
    self.reminderTimeLabel.text = [labelFormat stringFromDate:[firedate dateByAddingTimeInterval:-hourOfSleep*60*60]];
    
    NSString *alarmString = [labelFormat stringFromDate:firedate];
    [defaults setObject:alarmString forKey:@"wakeString"];
}
- (void) setFridayAlarm{
    NSDate *alarmTime = [[NSDate date] dateByAddingTimeInterval: self.rotaryKnob.value*800];
    NSLog(@"alarm time is %@",alarmTime );
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:[NSDate date]];
    
    NSDateComponents *alarmComponents = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:alarmTime];
    
    [components setWeekday:5];
    [components setHour:alarmComponents.hour];
    
    if (alarmComponents.minute == 1|
        alarmComponents.minute == 6|
        alarmComponents.minute == 11|
        alarmComponents.minute == 16|
        alarmComponents.minute == 21|
        alarmComponents.minute == 26|
        alarmComponents.minute == 31|
        alarmComponents.minute == 36|
        alarmComponents.minute == 41|
        alarmComponents.minute == 46|
        alarmComponents.minute == 51|
        alarmComponents.minute == 56
        ){
        alarmComponents.minute = alarmComponents.minute-1;
    }else if (alarmComponents.minute == 2|
              alarmComponents.minute == 7|
              alarmComponents.minute == 12|
              alarmComponents.minute == 17|
              alarmComponents.minute == 22|
              alarmComponents.minute == 27|
              alarmComponents.minute == 32|
              alarmComponents.minute == 37|
              alarmComponents.minute == 42|
              alarmComponents.minute == 47|
              alarmComponents.minute == 52|
              alarmComponents.minute == 57
              ){
        alarmComponents.minute = alarmComponents.minute-2;
    } else if (alarmComponents.minute == 3|
               alarmComponents.minute == 8|
               alarmComponents.minute == 13|
               alarmComponents.minute == 18|
               alarmComponents.minute == 23|
               alarmComponents.minute == 28|
               alarmComponents.minute == 33|
               alarmComponents.minute == 38|
               alarmComponents.minute == 43|
               alarmComponents.minute == 48|
               alarmComponents.minute == 53|
               alarmComponents.minute == 58
               ){
        alarmComponents.minute = alarmComponents.minute+2;
    } else if (alarmComponents.minute == 4|
               alarmComponents.minute == 9|
               alarmComponents.minute == 14|
               alarmComponents.minute == 19|
               alarmComponents.minute == 24|
               alarmComponents.minute == 29|
               alarmComponents.minute == 34|
               alarmComponents.minute == 39|
               alarmComponents.minute == 44|
               alarmComponents.minute == 49|
               alarmComponents.minute == 54|
               alarmComponents.minute == 59
               ){
        alarmComponents.minute = alarmComponents.minute+1;
    }
    
    [components setMinute:alarmComponents.minute];
    
    
    NSDate *alarmDate = [gregorian dateFromComponents:components];
    
    if ([alarmDate compare:[NSDate date]] == NSOrderedAscending) {
        alarmDate = [alarmDate dateByAddingTimeInterval:60*60*24*7];
    }
    
    NSLog(@"%@", alarmDate);
    
    firedate = alarmDate;
    
    fridayWakeAlarm = [[UILocalNotification alloc]init];
    fridayReminderAlarm = [[UILocalNotification alloc]init];
    
    fridayWakeAlarm.fireDate = alarmDate;
    fridayWakeAlarm.repeatInterval = NSWeekCalendarUnit;
    fridayWakeAlarm.alertBody = [self wakeMessage];
    fridayWakeAlarm.soundName = alarmNameString;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:fridayWakeAlarm];
    
    NSDate *reminderDate = [firedate dateByAddingTimeInterval:-60*60*hourOfSleep];
    
    fridayReminderAlarm.fireDate = reminderDate;
    fridayReminderAlarm.repeatInterval = NSWeekCalendarUnit;
    fridayReminderAlarm.alertBody = @"Time for bed!";
    fridayReminderAlarm.soundName = @"sleepAlarm1.wav";
    
    if ([reminderDate compare:[NSDate date]] == NSOrderedDescending) {
        NSLog(@"Reminder Alarm Set for %@",reminderDate);
        [[UIApplication sharedApplication] scheduleLocalNotification:fridayReminderAlarm];
    }
    
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"fridayAlarm"];

    NSDateFormatter *labelFormat = [[NSDateFormatter alloc] init];
    [labelFormat setDateFormat:hourFormat];
    self.reminderTimeLabel.text = [labelFormat stringFromDate:[firedate dateByAddingTimeInterval:-hourOfSleep*60*60]];
    
    NSString *alarmString = [labelFormat stringFromDate:firedate];
    [defaults setObject:alarmString forKey:@"wakeString"];
}
- (void) setSaturdayAlarm{
    NSDate *alarmTime = [[NSDate date] dateByAddingTimeInterval: self.rotaryKnob.value*800];
    NSLog(@"alarm time is %@",alarmTime );
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:[NSDate date]];
    
    NSDateComponents *alarmComponents = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:alarmTime];
    
    [components setWeekday:7];
    [components setHour:alarmComponents.hour];
    
    if (alarmComponents.minute == 1|
        alarmComponents.minute == 6|
        alarmComponents.minute == 11|
        alarmComponents.minute == 16|
        alarmComponents.minute == 21|
        alarmComponents.minute == 26|
        alarmComponents.minute == 31|
        alarmComponents.minute == 36|
        alarmComponents.minute == 41|
        alarmComponents.minute == 46|
        alarmComponents.minute == 51|
        alarmComponents.minute == 56
        ){
        alarmComponents.minute = alarmComponents.minute-1;
    }else if (alarmComponents.minute == 2|
              alarmComponents.minute == 7|
              alarmComponents.minute == 12|
              alarmComponents.minute == 17|
              alarmComponents.minute == 22|
              alarmComponents.minute == 27|
              alarmComponents.minute == 32|
              alarmComponents.minute == 37|
              alarmComponents.minute == 42|
              alarmComponents.minute == 47|
              alarmComponents.minute == 52|
              alarmComponents.minute == 57
              ){
        alarmComponents.minute = alarmComponents.minute-2;
    } else if (alarmComponents.minute == 3|
               alarmComponents.minute == 8|
               alarmComponents.minute == 13|
               alarmComponents.minute == 18|
               alarmComponents.minute == 23|
               alarmComponents.minute == 28|
               alarmComponents.minute == 33|
               alarmComponents.minute == 38|
               alarmComponents.minute == 43|
               alarmComponents.minute == 48|
               alarmComponents.minute == 53|
               alarmComponents.minute == 58
               ){
        alarmComponents.minute = alarmComponents.minute+2;
    } else if (alarmComponents.minute == 4|
               alarmComponents.minute == 9|
               alarmComponents.minute == 14|
               alarmComponents.minute == 19|
               alarmComponents.minute == 24|
               alarmComponents.minute == 29|
               alarmComponents.minute == 34|
               alarmComponents.minute == 39|
               alarmComponents.minute == 44|
               alarmComponents.minute == 49|
               alarmComponents.minute == 54|
               alarmComponents.minute == 59
               ){
        alarmComponents.minute = alarmComponents.minute+1;
    }
    
    [components setMinute:alarmComponents.minute];
    
    
    NSDate *alarmDate = [gregorian dateFromComponents:components];
    
    if ([alarmDate compare:[NSDate date]] == NSOrderedAscending) {
        alarmDate = [alarmDate dateByAddingTimeInterval:60*60*24*7];
    }
    
    NSLog(@"%@", alarmDate);
    
    firedate = alarmDate;
    
    saturdayWakeAlarm = [[UILocalNotification alloc]init];
    saturdayReminderAlarm = [[UILocalNotification alloc]init];
    
    saturdayWakeAlarm.fireDate = alarmDate;
    saturdayWakeAlarm.repeatInterval = NSWeekCalendarUnit;
    saturdayWakeAlarm.alertBody = [self wakeMessage];
    saturdayWakeAlarm.soundName = alarmNameString;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:saturdayWakeAlarm];
    
    NSDate *reminderDate = [firedate dateByAddingTimeInterval:-60*60*hourOfSleep];
    
    saturdayReminderAlarm.fireDate = reminderDate;
    saturdayReminderAlarm.repeatInterval = NSWeekCalendarUnit;
    saturdayReminderAlarm.alertBody = @"Time for bed!";
    saturdayReminderAlarm.soundName = @"sleepAlarm1.wav";
    
    if ([reminderDate compare:[NSDate date]] == NSOrderedDescending) {
        NSLog(@"Reminder Alarm Set for %@",reminderDate);
        [[UIApplication sharedApplication] scheduleLocalNotification:saturdayReminderAlarm];
    }
  
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"saturdayAlarm"];
    
    NSDateFormatter *labelFormat = [[NSDateFormatter alloc] init];
    [labelFormat setDateFormat:hourFormat];
    self.reminderTimeLabel.text = [labelFormat stringFromDate:[firedate dateByAddingTimeInterval:-hourOfSleep*60*60]];
    
    NSString *alarmString = [labelFormat stringFromDate:firedate];
    [defaults setObject:alarmString forKey:@"wakeString"];
}
- (void) setSundayAlarm{
    NSDate *alarmTime = [[NSDate date] dateByAddingTimeInterval: self.rotaryKnob.value*800];
    NSLog(@"alarm time is %@",alarmTime );
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:[NSDate date]];
    
    NSDateComponents *alarmComponents = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:alarmTime];
    
    [components setWeekday:1];
    [components setHour:alarmComponents.hour];
    
    if (alarmComponents.minute == 1|
        alarmComponents.minute == 6|
        alarmComponents.minute == 11|
        alarmComponents.minute == 16|
        alarmComponents.minute == 21|
        alarmComponents.minute == 26|
        alarmComponents.minute == 31|
        alarmComponents.minute == 36|
        alarmComponents.minute == 41|
        alarmComponents.minute == 46|
        alarmComponents.minute == 51|
        alarmComponents.minute == 56
        ){
        alarmComponents.minute = alarmComponents.minute-1;
    }else if (alarmComponents.minute == 2|
              alarmComponents.minute == 7|
              alarmComponents.minute == 12|
              alarmComponents.minute == 17|
              alarmComponents.minute == 22|
              alarmComponents.minute == 27|
              alarmComponents.minute == 32|
              alarmComponents.minute == 37|
              alarmComponents.minute == 42|
              alarmComponents.minute == 47|
              alarmComponents.minute == 52|
              alarmComponents.minute == 57
              ){
        alarmComponents.minute = alarmComponents.minute-2;
    } else if (alarmComponents.minute == 3|
               alarmComponents.minute == 8|
               alarmComponents.minute == 13|
               alarmComponents.minute == 18|
               alarmComponents.minute == 23|
               alarmComponents.minute == 28|
               alarmComponents.minute == 33|
               alarmComponents.minute == 38|
               alarmComponents.minute == 43|
               alarmComponents.minute == 48|
               alarmComponents.minute == 53|
               alarmComponents.minute == 58
               ){
        alarmComponents.minute = alarmComponents.minute+2;
    } else if (alarmComponents.minute == 4|
               alarmComponents.minute == 9|
               alarmComponents.minute == 14|
               alarmComponents.minute == 19|
               alarmComponents.minute == 24|
               alarmComponents.minute == 29|
               alarmComponents.minute == 34|
               alarmComponents.minute == 39|
               alarmComponents.minute == 44|
               alarmComponents.minute == 49|
               alarmComponents.minute == 54|
               alarmComponents.minute == 59
               ){
        alarmComponents.minute = alarmComponents.minute+1;
    }
    
    [components setMinute:alarmComponents.minute];
    
    
    NSDate *alarmDate = [gregorian dateFromComponents:components];
    
    if ([alarmDate compare:[NSDate date]] == NSOrderedAscending) {
        alarmDate = [alarmDate dateByAddingTimeInterval:60*60*24*7];
    }
    
    NSLog(@"%@", alarmDate);
    
    firedate = alarmDate;
    
    sundayWakeAlarm = [[UILocalNotification alloc]init];
    
    sundayWakeAlarm.fireDate = alarmDate;
    sundayWakeAlarm.repeatInterval = NSWeekCalendarUnit;
    sundayWakeAlarm.alertBody = [self wakeMessage];
    sundayWakeAlarm.soundName = alarmNameString;
    sundayReminderAlarm.hasAction = YES;
        
    [[UIApplication sharedApplication] scheduleLocalNotification:sundayWakeAlarm];
    NSLog(@"Sunday alarm set: %@",sundayWakeAlarm);
    
    NSDate *reminderDate = [firedate dateByAddingTimeInterval:-60*60*hourOfSleep];
    
    sundayReminderAlarm = [[UILocalNotification alloc]init];
    
    sundayReminderAlarm.fireDate = reminderDate;
    sundayReminderAlarm.repeatInterval = NSWeekCalendarUnit;
    sundayReminderAlarm.alertBody = @"Time for bed!";
    sundayReminderAlarm.hasAction = YES;
    sundayReminderAlarm.soundName = @"sleepAlarm1.wav";
    
    if ([reminderDate compare:[NSDate date]] == NSOrderedDescending) {
        NSLog(@"Reminder Alarm Set for %@",reminderDate);
        [[UIApplication sharedApplication] scheduleLocalNotification:sundayReminderAlarm];
    }
    
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"sundayAlarm"];
    
    NSDateFormatter *labelFormat = [[NSDateFormatter alloc] init];
    [labelFormat setDateFormat:hourFormat];
    self.reminderTimeLabel.text = [labelFormat stringFromDate:[firedate dateByAddingTimeInterval:-hourOfSleep*60*60]];
    
    NSString *alarmString = [labelFormat stringFromDate:firedate];
    [defaults setObject:alarmString forKey:@"wakeString"];
}

- (IBAction) pressBeginButton{
    NSDateFormatter *labelFormat = [[NSDateFormatter alloc] init];
    [labelFormat setDateFormat:hourFormat];
    self.wakeTimeLabel.text = [NSString stringWithFormat:@"%@", [labelFormat stringFromDate:[[NSDate date] dateByAddingTimeInterval: self.rotaryKnob.value*800]]];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH"];
    NSString *hours = [dateFormat stringFromDate:[[NSDate date] dateByAddingTimeInterval: self.rotaryKnob.value*800]];
    
    [dateFormat setDateFormat:@"mm"];
    NSString *minutes = [dateFormat stringFromDate:[[NSDate date] dateByAddingTimeInterval: self.rotaryKnob.value*800]];
    
    minutesPastHour = [minutes intValue];
    NSLog(@"minutes past hour: %@",minutes);
    int hoursInt = [hours intValue];
    float minutesPercentage = (minutesPastHour/60) *100;
    
    float Hm = (hoursInt*100)+minutesPercentage;
    
    CGPoint center = [_skyBack center];
    center.x = self.view.bounds.size.width/2;
    center.y = Hm - 400;
    
    [_skyBack setCenter:center];
  
    
    [UIView commitAnimations];
}

-(void) purchased{
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"unlocked"];
    [defaults synchronize];
}

- (IBAction)pressBackgroundButton{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.setAlarmButton.alpha = 0;
    self.dragInstructions.alpha = 0;
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    CGPoint menuButtonCenter = [self.menuButton center];
    menuButtonCenter.x = 296;
    menuButtonCenter.y = 500;
    [self.menuButton setCenter:menuButtonCenter];
    
    CGPoint infoButtonCenter = [self.infoButton center];
    infoButtonCenter.x = 26;
    infoButtonCenter.y = 500;
    [self.infoButton setCenter:infoButtonCenter];
    
    CGPoint backgroundLabelCenter = [self.backgroundLabelView center];
    backgroundLabelCenter.x = self.view.bounds.size.width/2;
    backgroundLabelCenter.y = 80;
    [self.backgroundLabelView setCenter:backgroundLabelCenter];
    
    CGPoint formatLabelCenter = [self.timeFormatLabelView center];
    formatLabelCenter.x = self.view.bounds.size.width/2;
    formatLabelCenter.y = 500;
    [self.timeFormatLabelView setCenter:formatLabelCenter];
    
    CGPoint soundNameLabelCenter = [self.soundNameLabelView center];
    soundNameLabelCenter.x = self.view.bounds.size.width/2;
    soundNameLabelCenter.y = 500;
    [self.soundNameLabelView setCenter:soundNameLabelCenter];
    
    CGPoint settingsReturnButtonViewCenter = [self.settingsReturnButtonView center];
    settingsReturnButtonViewCenter.x = self.view.bounds.size.width/2;
    settingsReturnButtonViewCenter.y = 150;
    [self.settingsReturnButtonView setCenter:settingsReturnButtonViewCenter];
    
    CGPoint closeEveViewCenter = [self.closeEveView center];
    closeEveViewCenter.x = self.view.bounds.size.width/2;
    closeEveViewCenter.y = 500;
    [self.closeEveView setCenter:closeEveViewCenter];
    
    self.rotaryKnob.alpha = 0;
    
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)fetchAvailableProducts{
    NSSet *productIdentifiers = [NSSet
                                 setWithObjects:kTutorialPointProductID,nil];
    productsRequest = [[SKProductsRequest alloc]
                       initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
}

- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

- (void)purchaseMyProduct:(SKProduct*)product{
    if ([self canMakePurchases]) {
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
                                  @"Purchases are disabled in your device" message:nil delegate:
                                  self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
    }
}
-(IBAction)purchase:(id)sender{
    [self purchaseMyProduct:[validProducts objectAtIndex:0]];
    //self.purchaseButton.enabled = NO;
}

#pragma mark StoreKit Delegate

-(void)paymentQueue:(SKPaymentQueue *)queue
updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                self.activityIndicator.alpha = 1;
                [self.activityIndicator startAnimating];
                NSLog(@"Purchasing");
                break;
            case SKPaymentTransactionStatePurchased:
                if ([transaction.payment.productIdentifier
                     isEqualToString:kTutorialPointProductID]) {
                    NSLog(@"Purchased ");
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
                                              @"Purchase is completed succesfully" message:nil delegate:
                                              self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    [alertView show];
                    self.activityIndicator.alpha = 0;
                    
                    [self.activityIndicator startAnimating];
                    [UIView beginAnimations:nil context:NULL];
                    [UIView setAnimationDuration:0.5];
                    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                    self.IAPView.alpha = 0;
                    [UIView commitAnimations];
                    
                    defaults = [[NSUserDefaults alloc]init];
                    [defaults setBool:YES forKey:@"unlocked"];
                    [defaults synchronize];
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                self.activityIndicator.alpha = 0;
                [self.activityIndicator startAnimating];
                NSLog(@"Restored ");
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.5];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                self.IAPView.alpha = 0;
                [UIView commitAnimations];
                
                
                defaults = [[NSUserDefaults alloc]init];
                [defaults setBool:YES forKey:@"purchasedDefaults"];
                [defaults synchronize];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                self.activityIndicator.alpha = 0;
                [self.activityIndicator stopAnimating];
                NSLog(@"Purchase failed ");
                break;
            default:
                break;
        }
    }
}

-(void)productsRequest:(SKProductsRequest *)request
    didReceiveResponse:(SKProductsResponse *)response
{
    SKProduct *validProduct = nil;
    int count = [response.products count];
    if (count>0) {
        validProducts = response.products;
        validProduct = [response.products objectAtIndex:0];
        if ([validProduct.productIdentifier
             isEqualToString:kTutorialPointProductID]) {
           // [self.productTitleLabel setText:[NSString stringWithFormat:
                                            // @"Product Title: %@",validProduct.localizedTitle]];
            self.IAPlabel.text = [NSString stringWithFormat:@"Personalise your alarm with our beautiful Seasons Sky Pack, for just %@",validProduct.priceAsString];
            [UIView commitAnimations];
        }
    } else {
        UIAlertView *tmp = [[UIAlertView alloc]
                            initWithTitle:@"Not Available"
                            message:@"No products to purchase"
                            delegate:self
                            cancelButtonTitle:nil
                            otherButtonTitles:@"Ok", nil];
        [tmp show];
    }
    [self.activityIndicator stopAnimating];
}

- (IBAction)gotoReviews:(id)sender{
    NSString *str = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=633081958";
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

- (IBAction)restore:(id)sender{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (IBAction)tapNap{
    NSString *str = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=789920975";
[[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

- (IBAction)tapMap{
    NSString *str = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=792151906";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}


@end
