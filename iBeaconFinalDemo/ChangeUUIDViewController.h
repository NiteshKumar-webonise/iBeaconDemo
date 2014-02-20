//
//  ChangeUUIDViewController.h
//  iBeaconFinalDemo
//
//  Created by Webonise on 20/02/14.
//  Copyright (c) 2014 Webonise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ESTBeaconManager.h>
@interface ChangeUUIDViewController : UIViewController<ESTBeaconManagerDelegate>
@property (nonatomic,retain) IBOutlet UIButton *btnCancel;
@property (nonatomic, strong) ESTBeaconManager* beaconManager;
@property (nonatomic, strong) ESTBeacon* selectedBeacon;
@property (nonatomic, strong) ESTBeaconRegion* beaconRegion;

-(IBAction)cancel:(id)sender;
-(IBAction)updateNewUUID:(id)sender;
@end
