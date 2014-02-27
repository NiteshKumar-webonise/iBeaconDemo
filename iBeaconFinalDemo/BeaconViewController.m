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
#import "UIDevice+Hardware.h"
#import "LoginViewController.h"
#import "UserData.h"


#define ESTIMOTE_PROXIMITY_UUID [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"]
static NSString * const kUUID = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";

@interface BeaconViewController () 
@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLBeacon* selectedBeacon;
@property (nonatomic, assign) BOOL notificationShown;
@property (nonatomic, strong) NSDictionary *userBeaconInfo;
@property (nonatomic, retain) WebserviceHelperClass *webserviceHelper;
@property (nonatomic, retain) NSDate *startTime, *endTime;
@property (nonatomic) NSTimeInterval timeSpent;
@property (nonatomic) BOOL isSentToserver;
@end

@implementation BeaconViewController
@synthesize lblBeacon, webserviceHelper,isSentToserver,performFBRequest;


- (void)viewDidLoad
{
    [super viewDidLoad];
    UIDevice *deviceInfo = [[UIDevice alloc]init];
    NSLog(@"HardwareDescription :%@ hardwareString %@  hardware: %d",[deviceInfo hardwareDescription],[deviceInfo hardwareString],[deviceInfo hardware]);
    //perform fb request is set
    self.performFBRequest = [[PerformFBRequest alloc]init];
    self.performFBRequest.delegate = self;
    
}

- (void)viewDidAppear:(BOOL)animated{
    [self signInSettings];
    AppDelegate *appDelegate=[[UIApplication sharedApplication]delegate];
    if (appDelegate.session.isOpen) {
        [self.performFBRequest showLoadingWithLabel:@"Loading..." withView:self.view];
        [self.performFBRequest sendRequestswithGraphPath:@"me?fields=id,name,first_name,last_name,email,picture.width(120).height(59),username"];
    }
    
    
    if(!([appDelegate.login_type isEqualToString:FACEBOOK_LOGIN]||[appDelegate.login_type isEqualToString:GOOGLE_LOGIN])){
        LoginViewController *loginViewController=[[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
        [self presentLogin:loginViewController];
    }else{
        [self initializeRegionMonitoring];
        webserviceHelper = [[WebserviceHelperClass alloc] init];
        webserviceHelper.delegate = self;
    }
}

-(void)signInSettings{
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser=YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.clientID=CLIENT_ID;
    signIn.scopes=[NSArray arrayWithObjects:kGTLAuthScopePlusLogin, nil];
    signIn.delegate=self;
    
}

#pragma mark - performFBRequest delegate
-(void)thisIsmyResult:(id)result {
    //NSLog(@"this is case 1--->%@",result);
   // NSLog(@"result is :%@",result);
    [self.performFBRequest.loadProgress hide:YES];

    NSDictionary *userInfo = result;
    NSLog(@"username: %@ and email : %@",[userInfo valueForKey:@"name"],[userInfo valueForKey:@"email"]);

    ModelContext *modelContext = [ModelContext sharedSingletonObject];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UserData" inManagedObjectContext:modelContext.managedObjectContext];

    UserData *userData;// = [[UserData alloc]init];
    userData = [[UserData alloc]initWithEntity:entityDescription insertIntoManagedObjectContext:modelContext.managedObjectContext];
    userData.name = [userInfo valueForKey:@"name"];
    userData.email = [userInfo valueForKey:@"email"];
    [modelContext insertIntoEntity:@"UserData" entityObject:userData]; //database insertion
}

#pragma mark
-(void)presentLogin:(UIViewController*)viewController{
    [self presentViewController:viewController animated:NO completion:nil];
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
    //[self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    //[self.locationManager requestStateForRegion:[BeaconRegion targetRegion]];
}

- (void)createBeaconRegion
{
    if (self.beaconRegion)
        return;
    
//    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:kUUID];
//    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:@"EstimoteSampleRegion"];
//    self.beaconRegion.notifyEntryStateOnDisplay = YES;
//    self.beaconRegion.notifyOnEntry=YES;
//    self.beaconRegion.notifyOnExit=YES;
    self.beaconRegion = [BeaconRegion targetRegion];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)logout:(id)sender{
     AppDelegate *appDelegate=[[UIApplication sharedApplication]delegate];
     LoginViewController *loginViewController=[[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
    if([appDelegate.login_type isEqualToString:GOOGLE_LOGIN]){
        [self googleSignOut];
        
    }else if ([appDelegate.login_type isEqualToString:FACEBOOK_LOGIN]){
        if(appDelegate.session.isOpen){
            [appDelegate.session closeAndClearTokenInformation];
        }
        [self presentLogin:loginViewController];
    }
}

#pragma mark -Google signOut
- (void)googleSignOut{
    [self showLoadingWithLabel:@"Log Out.." withView:self.view];
    [[GPPSignIn sharedInstance] disconnect]; //[[GPPSignIn sharedInstance] signOut];
}

- (void)showLoadingWithLabel:(NSString *)loadingMsg withView:(UIView *)view{
    self.mbProgressHUD = [MBProgressHUD showHUDAddedTo:view animated:NO];
    self.mbProgressHUD.labelText = loadingMsg;
}


#pragma mark -Disconnect from Google+

- (void)didDisconnectWithError:(NSError *)error{
    if(error){
        NSLog(@"Got an error here %@",error);
    }else{
        [self.mbProgressHUD hide:YES];
        LoginViewController *loginViewController=[[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
        [self presentLogin:loginViewController];
    }
}


#pragma mark -signIn delegate
- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    if(error){
        //NSLog(@"Received error %@",error);
    }else{
        //NSLog(@"logged in auth object %@",auth);
    }
    
}

#pragma mark - delegate for startRangingBeaconsInRegion
-(void)locationManager:(CLLocationManager *)manager
       didRangeBeacons:(NSArray *)beacons
              inRegion:(CLBeaconRegion *)region
{
    if([beacons count] > 0)
    {
        
            NSString* labelText;
            NSString *proximity;
            for (CLBeacon * cBeacon in beacons)
            {
                    self.selectedBeacon = cBeacon;                
                    labelText = [NSString stringWithFormat:@"UUID: %@, Major: %i, Minor: %i\nRegion: ",
                                           [self.selectedBeacon.proximityUUID UUIDString],
                                           [self.selectedBeacon.major unsignedShortValue],
                                           [self.selectedBeacon.minor unsignedShortValue]];
                
                proximity= [self returnProximityRangefor:self.selectedBeacon.proximity]; //recieve proximty range in string
                labelText = [[labelText stringByAppendingString:proximity] stringByAppendingString:@", "];
                labelText = [labelText stringByAppendingString: [self tellBeaconNamefor:self.selectedBeacon]];
                NSString *distance = [NSString stringWithFormat:@", Distance:%f", self.selectedBeacon.accuracy];
                labelText = [labelText stringByAppendingString:distance];
                self.lblBeacon.text = labelText;
                self.timeSpent = [self.startTime timeIntervalSinceDate:self.endTime];
                NSLog(@"time spents : %f",self.timeSpent);
                if(self.timeSpent>20 && isSentToserver==NO){
                    [self sendDataForBeacon:self.selectedBeacon];
                    isSentToserver=YES;//it should be set in responce .. got from server
                }
                
                //[self localNotificationWithAlertBody:@"didRangeBeacons:"];
                
                UIApplicationState state = [[UIApplication sharedApplication] applicationState];
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


-(NSString*)returnProximityRangefor:(NSInteger)proximityValue{
    NSString *proximity;
    switch (proximityValue)
    {
        case CLProximityUnknown:
            proximity = @"Unknown";
            break;
        case CLProximityImmediate:
            proximity = @"Immediate";
            break;
        case CLProximityNear:
            proximity = @"Near";
            break;
        case CLProximityFar:
            proximity = @"Far";
            break;
        default:
            break;
    }
    return proximity;
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
        [self localNotificationWithAlertBody:@"didDetermineState:inside"];
        [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    }
    else
    {   NSLog(@"in didDetermineState: CLRegionStateOutside or CLRegionStateUnknown");
        [self localNotificationWithAlertBody:@"didDetermineState:outside"];
    }
}

-(void)locationManager:(CLLocationManager *)manager
        didEnterRegion:(CLRegion *)region
{
    isSentToserver=NO;
    // present local notification
    [self localNotificationWithAlertBody:@"didEnterRegion"];
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"didEnterRegion" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
    self.startTime = [NSDate date]; //record time when user enters in the room
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    
}

-(void)locationManager:(CLLocationManager *)manager
         didExitRegion:(CLRegion *)region
{
    // present local notification
    [self localNotificationWithAlertBody:@"Thank you for attending conference! :)"];
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Thank you for attending conference! :)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    
    self.endTime = [NSDate date]; //record time when user exits from the room
    self.timeSpent = [self.endTime timeIntervalSinceDate:self.startTime];
     //NSLog(@"time spent when exit : %f",self.timeSpent);
    [self sendDataForBeacon:self.selectedBeacon];
    // iPhone/iPad left beacon zone
    [manager stopRangingBeaconsInRegion:self.beaconRegion];
    
}

-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region{
    [self.locationManager requestStateForRegion:self.beaconRegion];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    [self localNotificationWithAlertBody:@"location Update"];
}

#pragma mark - Any failure event
-(void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error{
    [self localNotificationWithAlertBody:[NSString stringWithFormat:@"Beacon rangingBeaconsDidFailForRegion with error: %@",error]];
}

-(void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error{
    [self localNotificationWithAlertBody:[NSString stringWithFormat:@"Beacon monitoringDidFailForRegion with error: %@",error]];
}


#pragma mark - webservice methods
-(void)sendDataForBeacon:(CLBeacon *)beacon{
    
    NSMutableDictionary *dataDictionary =[NSMutableDictionary dictionary];
    [dataDictionary setObject:beacon.proximityUUID forKey:@"proximityUUID"];
    [dataDictionary setObject:beacon.major forKey:@"major"];
    [dataDictionary setObject:beacon.minor forKey:@"minor"];
    NSNumber *timeSpend = [NSNumber numberWithDouble:self.timeSpent];
    [dataDictionary setObject:timeSpend forKey:@"Timespent"];
    webserviceHelper.showLoadingView = NO;
    [webserviceHelper callWebServiceForPOSTRequest:@"http://192.168.0.14" withParameters:dataDictionary withServiceTag:0];
    //NSData *postData = [NSJSONSerialization dataWithJSONObject:dataDictionary options:0 error:&err];
    
    
    //[self postToServer:postData];
}

-(void)postToServer:(NSData*)postData{

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

#pragma mark - Webservice delegate method
/*Api Call Response*/
-(void)apiCallResponse:(id)response andServiceTag:(int)tag {

}
/*Api Call Error*/
-(void)apiCallError:(NSError *)error andServiceTag:(int)tag {
  
}


@end
