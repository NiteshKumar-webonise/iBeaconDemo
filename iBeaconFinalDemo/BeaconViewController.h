//
//  ViewController.h
//  iBeaconFinalDemo
//
//  Created by Webonise on 11/02/14.
//  Copyright (c) 2014 Webonise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "WebserviceHelperClass.h"
@interface BeaconViewController : UIViewController <CLLocationManagerDelegate, WebserviceDelegate>
@property (nonatomic, retain) IBOutlet UILabel *lblBeacon;
@property (nonatomic, retain) IBOutlet UIButton *btnMonitor;

-(IBAction)startMonitoring:(id)sender;
-(IBAction)logout:(id)sender;
@end
