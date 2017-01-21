//
//  introViewController.m
//  eve2
//
//  Created by Daniel Pape on 20/01/2017.
//  Copyright © 2017 Daniel Pape. All rights reserved.
//

#import "introViewController.h"
#import "MHRotaryKnob.h"


@interface introViewController ()

@end

@implementation introViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)tapDismissButton:(id)sender {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.view.alpha = 0;
    _eVC.rotaryKnob.alpha = 1;
    _eVC.setAlarmButton.alpha = 1;
    [UIView commitAnimations];
    
}
@end
