//
//  setViewController.h
//  eve2
//
//  Created by Daniel Pape on 22/09/2013.
//  Copyright (c) 2013 Daniel Pape. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "eveViewController.h"

@interface setViewController : UIViewController{
    NSDate *firedate;
    NSUserDefaults *defaults;
    int hourOfSleep;
}

@property (weak, nonatomic) IBOutlet UILabel *setTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *mLabel;
@property (weak, nonatomic) IBOutlet UILabel *TuLabel;
@property (weak, nonatomic) IBOutlet UILabel *wLabel;
@property (weak, nonatomic) IBOutlet UILabel *ThLabel;
@property (weak, nonatomic) IBOutlet UILabel *fLabel;
@property (weak, nonatomic) IBOutlet UILabel *saLabel;
@property (weak, nonatomic) IBOutlet UILabel *suLabel;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) IBOutlet UIImageView *skyBack;
@property (weak, nonatomic) IBOutlet UILabel *hoursLabel;

-(IBAction)tapResetButton:(id)sender;

@end
