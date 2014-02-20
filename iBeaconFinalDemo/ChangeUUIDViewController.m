//
//  ChangeUUIDViewController.m
//  iBeaconFinalDemo
//
//  Created by Webonise on 20/02/14.
//  Copyright (c) 2014 Webonise. All rights reserved.
//

#import "ChangeUUIDViewController.h"

@interface ChangeUUIDViewController ()

@end

@implementation ChangeUUIDViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"WARNING" message:@"You are going to change UUID" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alertView show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)cancel:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)updateNewUUID:(id)sender{
    
}
@end
