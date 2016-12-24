//
//  morningViewController.m
//  eve2
//
//  Created by Daniel Pape on 19/10/2013.
//  Copyright (c) 2013 Daniel Pape. All rights reserved.
//

#import "morningViewController.h"

@interface morningViewController ()

@end

@implementation morningViewController

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
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"hh mm a"];
    self.timeLabel.text = [NSString stringWithFormat:@"%@",[NSDate date]];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
