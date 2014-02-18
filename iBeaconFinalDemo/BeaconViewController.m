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
@property (nonatomic, strong) ESTBeaconRegion* beaconRegion;
@property (nonatomic, assign) BOOL notificationShown;
@end

@implementation BeaconViewController
@synthesize lblBeacon,beaconRegion, btnRefreshMonitoring;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self startMonitor];
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

-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
    if([beacons count] > 0)
    {
        
        NSString* labelText;
            for (ESTBeacon* cBeacon in beacons)
            {
                self.selectedBeacon = cBeacon;
                labelText = [NSString stringWithFormat:@"UUID: %@, Major: %i, Minor: %i\nRegion: ",
                                           [self.selectedBeacon.proximityUUID UUIDString],
                                           [self.selectedBeacon.major unsignedShortValue],
                                           [self.selectedBeacon.minor unsignedShortValue]];
                    

                    switch (self.selectedBeacon.proximity)
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
                    
               

                labelText = [labelText stringByAppendingString: [self tellBeaconNamefor:self.selectedBeacon]];
                labelText = [labelText stringByAppendingString:[NSString stringWithFormat:@", Distance:%@",self.selectedBeacon.distance]];
                self.lblBeacon.text = labelText;
                
            }
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if(state==UIApplicationStateBackground||state==UIApplicationStateInactive){
            NSLog(@"in background : in didRangeBeacons");
        }else{
            NSLog(@"in foreground : in didRangeBeacons");
        }
        
        
    }else{
        [self localNotificationWithAlertBody:@"currently there is no beacon"];
    }
}


-(NSString*)tellBeaconNamefor:(ESTBeacon*)beacon{
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
        [self localNotificationWithAlertBody:@"didDetermineState: inside"];
        [self.beaconManager startRangingBeaconsInRegion:region];
    }
    else
    {
        [self localNotificationWithAlertBody:@"didDetermineState: outside"];
         [self.beaconManager stopRangingBeaconsInRegion:region];
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
        NSLog(@"in background : notification fired");
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = body;
        notification.alertAction = @"Show me the item";
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        NSLog(@"in notification badge number is %ld",(long)notification.applicationIconBadgeNumber);
    }else{
        NSLog(@"in foreground : notification fired");
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:body delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

-(IBAction)refreshMonitoring:(id)sender{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [self.beaconManager startMonitoringForRegion:self.beaconRegion];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {}

@end
