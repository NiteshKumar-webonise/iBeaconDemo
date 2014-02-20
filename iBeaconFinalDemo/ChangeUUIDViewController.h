//
//  ChangeUUIDViewController.h
//  iBeaconFinalDemo
//
//  Created by Webonise on 20/02/14.
//  Copyright (c) 2014 Webonise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangeUUIDViewController : UIViewController
@property (nonatomic,retain) IBOutlet UIButton *btnCancel;
-(IBAction)cancel:(id)sender;
-(IBAction)updateNewUUID:(id)sender;
@end
