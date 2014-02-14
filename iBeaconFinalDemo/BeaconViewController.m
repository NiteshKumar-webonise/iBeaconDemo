//
//  ViewController.m
//  iBeaconFinalDemo
//
//  Created by Webonise on 11/02/14.
//  Copyright (c) 2014 Webonise. All rights reserved.
//

#import "BeaconViewController.h"
#import <ESTBeaconManager.h>
#import "AppDelegate.h"

#import "BeaconRegion.h"

#define ESTIMOTE_PROXIMITY_UUID [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"]
static NSString * const kUUID = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";

@interface BeaconViewController () 
@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLBeacon* selectedBeacon;
@property (nonatomic, assign) BOOL notificationShown;
@end

@implementation BeaconViewController
@synthesize lblBeacon;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    create sample region with major value defined for one perticular beacon
//    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
//                                                                       major:36452 minor:36010
//                                                                  identifier: @"EstimoteSampleRegion"];
    
    
//  create sample region for all perticular beacons
   // ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
    //                                                              identifier: @"EstimoteSampleRegion"];
    
    //region.notifyEntryStateOnDisplay = YES;

    
    [self initializeRegionMonitoring];
}

- (void)initializeRegionMonitoring {
    // initialize new location manager
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
    }
    [self createBeaconRegion];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    //[self.locationManager requestStateForRegion:[BeaconRegion targetRegion]];
}

- (void)createBeaconRegion
{
    if (self.beaconRegion)
        return;
    
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:kUUID];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:@"EstimoteSampleRegion"];
    self.beaconRegion.notifyEntryStateOnDisplay = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - delegate for startRangingBeaconsInRegion
-(void)locationManager:(CLLocationManager *)manager
       didRangeBeacons:(NSArray *)beacons
              inRegion:(CLBeaconRegion *)region
{
    if([beacons count] > 0)
    {
        
            NSString* labelText;
            for (CLBeacon * cBeacon in beacons)
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
                NSString *distance = [NSString stringWithFormat:@", Distance:%f", self.selectedBeacon.accuracy];
                labelText = [labelText stringByAppendingString:distance];
                self.lblBeacon.text = labelText;
                //[self sendDataForBeacon:self.selectedBeacon];
                [self localNotificationWithAlertBody:@"didEnterRegion"];
                UIApplicationState state = [[UIApplication sharedApplication] applicationState];
                AppDelegate *app = [[UIApplication sharedApplication]delegate];
                app.body = @"didEnterRegion";
                if(state==UIApplicationStateBackground||state==UIApplicationStateInactive){
                    if(state==UIApplicationStateBackground){
                        NSLog(@"didRangeBeacons is in background mode");
                    }else if(state==UIApplicationStateInactive){
                        NSLog(@"didRangeBeacons is in Inactive mode");
                    }
                }

                    
                }

        
    }else{
        self.lblBeacon.text = @"currently there is no beacons nearby";
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if(state==UIApplicationStateBackground||state==UIApplicationStateInactive){
            if(state==UIApplicationStateBackground){
                NSLog(@"didRangeBeacons is in background mode");
                [self localNotificationWithAlertBody:@"currently there is no beacons nearby"];
            }else if(state==UIApplicationStateInactive){
                NSLog(@"didRangeBeacons is in Inactive mode");
            }
        }
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

#pragma mark - delegate when startMonitoringForRegion
-(void)locationManager:(CLLocationManager *)manager
     didDetermineState:(CLRegionState)state
             forRegion:(CLRegion *)region
{
    if(state == CLRegionStateInside)
    {
        NSLog(@"in didDetermineState: CLRegionStateInside");
        [self localNotificationWithAlertBody:@"didEnterRegion"];
        [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    }
    else
    {   NSLog(@"in didDetermineState: CLRegionStateOutside or CLRegionStateUnknown");
        [self localNotificationWithAlertBody:@"didExitRegion"];
    }
}

-(void)locationManager:(CLLocationManager *)manager
        didEnterRegion:(CLRegion *)region
{
    // present local notification
    [self localNotificationWithAlertBody:@"didEnterRegion"];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    
}

-(void)locationManager:(CLLocationManager *)manager
         didExitRegion:(CLRegion *)region
{
    // present local notification
    [self localNotificationWithAlertBody:@"didExitRegion"];
    // iPhone/iPad left beacon zone
    [manager stopRangingBeaconsInRegion:self.beaconRegion];
    
}

#pragma mark - Any failure event
-(void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error{
    [self localNotificationWithAlertBody:[NSString stringWithFormat:@"Beacon rangingBeaconsDidFailForRegion with error: %@",error]];
}

-(void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error{
    [self localNotificationWithAlertBody:[NSString stringWithFormat:@"Beacon monitoringDidFailForRegion with error: %@",error]];
}


#pragma mark - webservice methods
-(void)sendDataForBeacon:(ESTBeacon *)beacon{
    
    NSMutableDictionary *dataDictionary =[NSMutableDictionary dictionary];
    [dataDictionary setObject:beacon.proximityUUID forKey:@"proximityUUID"];
    [dataDictionary setObject:beacon.major forKey:@"major"];
    [dataDictionary setObject:beacon.minor forKey:@"minor"];
    NSError *err;
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dataDictionary options:0 error:&err];
    [self postToServer:postData];
}

-(void)postToServer:(NSData*)postData{
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.0.6:8888"]];
//    [request setHTTPMethod:@"POST"];
//    [request setValue:[NSString stringWithFormat:@"%d", postData.length] forHTTPHeaderField:@"Content-Length"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [request setTimeoutInterval:15];
//    [request setHTTPBody:postData];
//    //NSLog(@"Post data : %@",[[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding]);
//    //NSLog(@"post data new  :%@",postData);
//    
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
//                               
//                               //NSLog(@"Data:--> %@ ",data);
//                               if(!error){
//                                   NSDictionary *result=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//                                   NSLog(@"result: %@",result);
//                                   if([[result valueForKey:@"status"] boolValue]){  // use filter here , if responce' success key is true
//                                       
//                                   }
//                               }
//                           }];
    
    
}

#pragma mark - Local Notification

-(void)localNotificationWithAlertBody:(NSString*)body{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state==UIApplicationStateBackground||state==UIApplicationStateInactive){
        if(state==UIApplicationStateBackground){
            NSLog(@"App is in background mode");
        }else if(state==UIApplicationStateInactive){
            NSLog(@"App is in Inactive mode");
        }
        
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = body;
        notification.alertAction = @"Show me the item";
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        NSLog(@"in notification badge number is %ld",(long)notification.applicationIconBadgeNumber);
    }else{
//        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:body delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alert show];
        NSLog(@"app is in forground mode");
    }
}


- (IBAction)startMonitoring:(id)sender{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [self initializeRegionMonitoring];
}





-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    // current location usage is required to use this demo app
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        [[[UIAlertView alloc] initWithTitle:@"Current Location Required"
                                    message:@"Please re-enable Core Location to run this Demo.  The app will now exit."
                                   delegate:self
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil] show];
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // exit application if user declined Current Location permissions
    exit(0);
}

@end
