//
//  ViewController.h
//  iBeaconFinalDemo
//
//  Created by Webonise on 11/02/14.
//  Copyright (c) 2014 Webonise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeaconViewController : UIViewController
@property (nonatomic, retain) IBOutlet UILabel *lblBeacon;
@property (nonatomic, retain)  IBOutlet UIButton *btnRefreshMonitoring;

-(IBAction)refreshMonitoring:(id)sender;
@property (nonatomic, weak) IBOutlet UITableView *beaconTableView;
@end
