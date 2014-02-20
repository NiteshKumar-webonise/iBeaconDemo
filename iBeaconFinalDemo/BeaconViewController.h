//
//  ViewController.h
//  iBeaconFinalDemo
//
//  Created by Webonise on 11/02/14.
//  Copyright (c) 2014 Webonise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ESTBeaconManager.h>
@interface BeaconViewController : UIViewController<ESTBeaconManagerDelegate,CBPeripheralManagerDelegate,
UITableViewDataSource, UITableViewDelegate >



@property (nonatomic, strong) ESTBeaconManager* beaconManager;
@property (nonatomic, strong) ESTBeacon* selectedBeacon;
@property (nonatomic, strong) ESTBeaconRegion* beaconRegion;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) NSArray *detectedBeacons;
@property (nonatomic, assign) BOOL notificationShown;
@property (nonatomic, retain) IBOutlet UILabel *lblBeacon;
@property (nonatomic, retain)  IBOutlet UIButton *btnRefreshMonitoring;
@property (nonatomic, weak) IBOutlet UITableView *beaconTableView;

-(IBAction)refreshMonitoring:(id)sender;
@end
