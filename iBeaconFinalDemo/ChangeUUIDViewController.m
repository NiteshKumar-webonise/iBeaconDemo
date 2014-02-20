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
    [self startMonitor];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"WARNING" message:@"You are going to change UUID" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alertView show];
}

- (void)startMonitor{
    // craete manager instance
    if(!self.beaconRegion){
        self.beaconManager = [[ESTBeaconManager alloc] init];
        self.beaconManager.delegate = self;
        self.beaconManager.avoidUnknownStateBeacons = YES;
        
    }
    [self createBeaconRegion];
    [self.beaconManager startMonitoringForRegion:self.beaconRegion];
    
}

- (void)createBeaconRegion
{
    //    create sample region with major value defined for one perticular beacon
    //    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
    //                                                                       major:36452 minor:36010
    //                                                                  identifier: @"EstimoteSampleRegion"];
    
    if (self.beaconRegion)
        return;
    //self.beaconRegion = [[EstimoteBeaconRegion alloc]init];
    NSUUID *proximityUUID =  ESTIMOTE_PROXIMITY_UUID;
    self.beaconRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:@"EstimoteSampleRegion"];
    self.beaconRegion.notifyEntryStateOnDisplay = YES;
    self.beaconRegion.notifyOnEntry=YES;
    self.beaconRegion.notifyOnExit=YES;
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

-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{ 
    if([beacons count] > 0)
    {
        for (ESTBeacon* cBeacon in beacons)
        {
            [cBeacon writeBeaconProximityUUID:@"" withCompletion: ^(NSString *value, NSError *error){
                if(error){
                    NSLog(@"Got error while writing New UUID %@",error);
                }else{
                    NSLog(@"written new UUID and  %@", value);
                }
                
                
            }];
        }
    }
    
}

-(void)beaconManager:(ESTBeaconManager *)manager
   didDetermineState:(CLRegionState)state
           forRegion:(ESTBeaconRegion *)region
{
    if(state == CLRegionStateInside)
    {
        [self.beaconManager startRangingBeaconsInRegion:region];
    }
    else
    {
        [self.beaconManager stopRangingBeaconsInRegion:region];
    }
}


-(void)beaconManager:(ESTBeaconManager *)manager
      didEnterRegion:(ESTBeaconRegion *)region
{
    [self.beaconManager startRangingBeaconsInRegion:region];
    
}

-(void)beaconManager:(ESTBeaconManager *)manager
       didExitRegion:(ESTBeaconRegion *)region
{
    [self.beaconManager stopMonitoringForRegion:region];
    
}

@end
