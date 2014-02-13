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
    
//    region.notifyEntryStateOnDisplay = YES;
//    region.notifyOnEntry = YES;
//    region.notifyOnExit = YES;
    
    // start looking for estimote beacons in region
    // when beacon ranged beaconManager:didEnterRegion:
    // and beaconManager:didExitRegion: invoked
    [self.beaconManager startMonitoringForRegion:region];
    
    
    //if user is inside or outside of the region requestStateForRegion: method invocation
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
        
            NSString* labelText;
            for (ESTBeacon* cBeacon in beacons)
            {
                    self.selectedBeacon = cBeacon;
                    labelText = [NSString stringWithFormat:@"UUID: %@, Major: %i, Minor: %i\nRegion: ",
                                           [self.selectedBeacon.proximityUUID UUIDString],
                                           [self.selectedBeacon.major unsignedShortValue],
                                           [self.selectedBeacon.minor unsignedShortValue]];
                    
                    // calculate and set new y position
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
                    
                }

                labelText = [labelText stringByAppendingString: [self tellBeaconNamefor:self.selectedBeacon]];
                self.lblBeacon.text = labelText;
        [self sendDataForBeacon:self.selectedBeacon];
                [self localNotificationWithAlertBody:@"didEnterRegion"];
        
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
        [self localNotificationWithAlertBody:@"didEnterRegion"];
    }
    else
    {
        [self localNotificationWithAlertBody:@"didExitRegion"];
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


-(void)sendDataForBeacon:(ESTBeacon *)beacon{
    
    NSMutableDictionary *dataDictionary =[NSMutableDictionary dictionary];
    [dataDictionary setObject:beacon.proximityUUID forKey:@"proximityUUID"];
    [dataDictionary setObject:beacon.major forKey:@"major"];
    [dataDictionary setObject:beacon.minor forKey:@"minor"];
    NSError *err;
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dataDictionary options:0 error:&err];
    [self postToServer:postData];
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

-(void)postToServer:(NSData*)postData{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.0.6:8888"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%d", postData.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:15];
    [request setHTTPBody:postData];
    //NSLog(@"Post data : %@",[[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding]);
    //NSLog(@"post data new  :%@",postData);
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               
                               //NSLog(@"Data:--> %@ ",data);
                               if(!error){
                                   NSDictionary *result=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                   NSLog(@"result: %@",result);
                                   if([[result valueForKey:@"status"] boolValue]){  // use filter here , if responce' success key is true
                                       
                                   }
                               }
                           }];
    
    
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {}

@end
