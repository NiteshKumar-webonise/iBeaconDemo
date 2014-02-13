//
//  ViewController.m
//  iBeaconFinalDemo
//
//  Created by Webonise on 11/02/14.
//  Copyright (c) 2014 Webonise. All rights reserved.
//

#import "BeaconViewController.h"
#import <ESTBeaconManager.h>
#define ESTIMOTE_PROXIMITY_UUID [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"]

@interface BeaconViewController () <ESTBeaconManagerDelegate>
@property (nonatomic, strong) ESTBeaconManager* beaconManager;
@property (nonatomic, strong) ESTBeacon* selectedBeacon;
@property (nonatomic, assign) BOOL notificationShown;
@end

@implementation BeaconViewController
@synthesize lblBeacon;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // craete manager instance
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    self.beaconManager.avoidUnknownStateBeacons = YES;
    
    
//    create sample region with major value defined for one perticular beacon
//    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
//                                                                       major:36452 minor:36010
//                                                                  identifier: @"EstimoteSampleRegion"];
    
    
//  create sample region for all perticular beacons
    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                                  identifier: @"EstimoteSampleRegion"];
    
    region.notifyEntryStateOnDisplay = YES;
    region.notifyOnEntry = YES;
    region.notifyOnExit = YES;
    
    // start looking for estimote beacons in region
    // when beacon ranged beaconManager:didEnterRegion:
    // and beaconManager:didExitRegion: invoked
    [self.beaconManager startMonitoringForRegion:region];
     [self.beaconManager requestStateForRegion:region];

    
    // start looking for estimote beacons in region
    // when beacon ranged beaconManager:didRangeBeacons:inRegion: invoked
    [self.beaconManager startRangingBeaconsInRegion:region];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
    if([beacons count] > 0)
    {
        
        //self.selectedBeacon = [beacons objectAtIndex:0];
        
       // NSMutableString *allBeaconsData = [[NSMutableString alloc]init];
        NSString* labelText;
            for (ESTBeacon* cBeacon in beacons)
            {
//                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"didEnterRegion" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
//                [alert show];

                // update beacon it same as selected initially
                if(1)//&&[self.selectedBeacon.ibeacon.major unsignedShortValue]==36452 &&[self.selectedBeacon.ibeacon.minor unsignedShortValue]==36010
                {
                    self.selectedBeacon = cBeacon;
                    
                    
                    
                    labelText = [NSString stringWithFormat:
                                           @"UUID: %@, Major: %i, Minor: %i\nRegion: ",
                                           [self.selectedBeacon.ibeacon.proximityUUID UUIDString],
                                           [self.selectedBeacon.ibeacon.major unsignedShortValue],
                                           [self.selectedBeacon.ibeacon.minor unsignedShortValue]];
                    
                    // calculate and set new y position
                    switch (self.selectedBeacon.ibeacon.proximity)
                    {
                        case CLProximityUnknown:
                            labelText = [labelText stringByAppendingString: @"Unknown, "];
                            break;
                        case CLProximityImmediate:
                            labelText = [labelText stringByAppendingString: @"Immediate, "];
                            break;
                        case CLProximityNear:
                            labelText = [labelText stringByAppendingString: @"Near, "];
                            break;
                        case CLProximityFar:
                            labelText = [labelText stringByAppendingString: @"Far, "];
                            break;
                            
                        default:
                            break;
                    }
                    
                }

                labelText = [labelText stringByAppendingString: [self tellBeaconNamefor:self.selectedBeacon.ibeacon]];
                self.lblBeacon.text = labelText;
                [self localNotificationWithAlertBody:@"didEnterRegion"];
            }
       // }
        
        
                // beacon array is sorted based on distance
        // closest beacon is the first one
        
        
    }
}


-(NSString*)tellBeaconNamefor:(CLBeacon*)beacon{
    NSString *beaconName;
    if([beacon.major unsignedShortValue]==36452 && [beacon.minor unsignedShortValue]== 36010){
        beaconName = @"Mint Cocktail";
    }else if ([beacon.major unsignedShortValue]==36015 && [beacon.minor unsignedShortValue]== 56457){
        beaconName = @"Icy Marshmallow";
    }else if ([beacon.major unsignedShortValue]==12830 && [beacon.minor unsignedShortValue]== 49469){
        beaconName = @"Blueberry Pie";
    }
    return beaconName;
}

-(void)beaconManager:(ESTBeaconManager *)manager
   didDetermineState:(CLRegionState)state
           forRegion:(ESTBeaconRegion *)region
{
    if(state == CLRegionStateInside)
    {
        [manager startMonitoringForRegion:region];
    }
    else
    {
        [manager stopMonitoringForRegion:region];
    }
}

-(void)beaconManager:(ESTBeaconManager *)manager
      didEnterRegion:(ESTBeaconRegion *)region
{
    // present local notification
    [self localNotificationWithAlertBody:@"didEnterRegion"];
    // iPhone/iPad entered beacon zone
    [self.beaconManager startRangingBeaconsInRegion:region];
    
}

-(void)beaconManager:(ESTBeaconManager *)manager
       didExitRegion:(ESTBeaconRegion *)region
{
    // present local notification
    [self localNotificationWithAlertBody:@"didExitRegion"];
    // iPhone/iPad left beacon zone
    [self.beaconManager stopMonitoringForRegion:region];
    
}


-(void)localNotificationWithAlertBody:(NSString*)body{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state==UIApplicationStateBackground||state==UIApplicationStateInactive){
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = body;
        notification.alertAction = @"Show me the item";
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        NSLog(@"in notification badge number is %ld",(long)notification.applicationIconBadgeNumber);
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:body delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {}

@end
