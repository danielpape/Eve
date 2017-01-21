//
//  introViewController.h
//  eve2
//
//  Created by Daniel Pape on 20/01/2017.
//  Copyright © 2017 Daniel Pape. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "eveViewController.h"

@interface introViewController : UIViewController

@property (weak, nonatomic) eveViewController *eVC;

- (IBAction)tapDismissButton:(id)sender;

@end
