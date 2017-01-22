//
//  setViewController.m
//  eve2
//
//  Created by Daniel Pape on 22/09/2013.
//  Copyright (c) 2013 Daniel Pape. All rights reserved.
//

#import "setViewController.h"


@interface setViewController ()

@end



@implementation setViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    defaults = [[NSUserDefaults alloc]init];
    
    NSString *savedHour = [defaults stringForKey:@"wakeString"];
    self.setTimeLabel.text = [NSString stringWithFormat:@"%@",savedHour];
    
    self.resetAlarmButton.layer.cornerRadius = 7.5f;
    self.resetAlarmButton.layer.shadowRadius = 2.0f;
    self.resetAlarmButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.resetAlarmButton.layer.shadowOpacity = 0.2f;
    self.resetAlarmButton.layer.shadowOffset = CGSizeMake(0, 2);
    
    if([defaults boolForKey:@"mondayAlarm"]) {
        self.mLabel.alpha = 1;
    }else{
        self.mLabel.textColor = [UIColor blackColor];
    }
    if([defaults boolForKey:@"tuesdayAlarm"]) {
        self.TuLabel.alpha = 1;
    }else{
        self.TuLabel.textColor = [UIColor blackColor];
    }
    if([defaults boolForKey:@"wednesdayAlarm"]) {
        self.wLabel.alpha = 1;
    }else{
        self.wLabel.textColor = [UIColor blackColor];
    }
    if([defaults boolForKey:@"thursdayAlarm"]) {
        self.ThLabel.alpha = 1;
        
    }else{
        self.ThLabel.textColor = [UIColor blackColor];
    }
    if([defaults boolForKey:@"fridayAlarm"]) {
        self.fLabel.alpha = 1;
    }else{
        self.fLabel.textColor = [UIColor blackColor];
    }
    if([defaults boolForKey:@"saturdayAlarm"]) {
        self.saLabel.alpha = 1;
    }else{
        self.saLabel.textColor = [UIColor blackColor];
    }
    if([defaults boolForKey:@"sundayAlarm"]) {
        self.suLabel.alpha = 1;
    }else{
        self.suLabel.textColor = [UIColor blackColor];
    }
    
    [self setBackground];
    
    [self setBackgroundPosition];
    NSString *sleepString = [defaults stringForKey:@"hourOfSleep"];
    
    self.hoursLabel.text = [NSString stringWithFormat:@"and will remind you %@ hours before",sleepString];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)setBackground{
    
    defaults = [[NSUserDefaults alloc]init];
    
    if ([[defaults objectForKey:@"background"]  isEqual: @"background1.png"]){
        self.skyBack.image = [UIImage imageNamed:@"background1.png"];
    }else if ([[defaults objectForKey:@"background"]  isEqual: @"background2.png"]){
        NSLog(@"Method Called");
        self.skyBack.image = [UIImage imageNamed:@"background2.png"];
    }else if ([[defaults objectForKey:@"background"]  isEqual: @"background3.png"]){
        self.skyBack.image = [UIImage imageNamed:@"background3.png"];
    }else if ([[defaults objectForKey:@"background"]  isEqual: @"background4.png"]){
        self.skyBack.image = [UIImage imageNamed:@"background4.png"];
    }
}

-(void) setBackgroundPosition{
    firedate = [[NSDate alloc]init];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH"];
    NSString *hours = [dateFormat stringFromDate:firedate];
    
    [dateFormat setDateFormat:@"mm"];
    NSString *minutes = [dateFormat stringFromDate:firedate];
    
    float minutesPastHour = [minutes intValue];
    NSLog(@"minutes past hour: %@",minutes);
    int hoursInt = [hours intValue];
    float minutesPercentage = (minutesPastHour/60) *100;
    
    float Hm = (hoursInt*100)+minutesPercentage;
    
    _skyBack = [[UIImageView alloc]init];
    
    CGPoint center = [_skyBack center];
    center.x = 160;
    center.y = Hm - 400;
    
    [_skyBack setCenter:center];
}

-(IBAction)tapResetButton:(id)sender{
    [[UIApplication sharedApplication]cancelAllLocalNotifications];
    [defaults setBool:NO forKey:@"mondayAlarm"];
    [defaults setBool:NO forKey:@"tuesdayAlarm"];
    [defaults setBool:NO forKey:@"wednesdayAlarm"];
    [defaults setBool:NO forKey:@"thursdayAlarm"];
    [defaults setBool:NO forKey:@"fridayAlarm"];
    [defaults setBool:NO forKey:@"saturdayAlarm"];
    [defaults setBool:NO forKey:@"sundayAlarm"];
    [defaults synchronize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
