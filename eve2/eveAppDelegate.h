//
//  eveAppDelegate.h
//  eve2
//
//  Created by Daniel Pape on 06/05/2013.
//  Copyright (c) 2013 Daniel Pape. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "eveViewController.h"
#import "setViewController.h"


@interface eveAppDelegate : UIResponder <UIApplicationDelegate>{
    NSUserDefaults *defaults;
}

@property (strong, nonatomic) UIWindow *window;

@end
