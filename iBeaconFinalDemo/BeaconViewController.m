//
//  ViewController.m
//  iBeaconFinalDemo


#import "BeaconViewController.h"
#import "ChangeUUIDViewController.h"
#import "EstimoteBeaconRegion.h"
#import "UIDevice+Hardware.h"

#define ESTIMOTE_PROXIMITY_UUID [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"]

static NSString * const kBeaconCellIdentifier = @"BeaconCell";
static NSString * const kBeaconsHeaderViewIdentifier = @"BeaconsHeader";
static NSString * const kBeaconSectionTitle = @"Looking for beacons...";
static CGPoint const kActivityIndicatorPosition = (CGPoint){205, 3};
static int const kCellHeight = 52;

@implementation BeaconViewController
@synthesize lblBeacon,beaconRegion, btnRefreshMonitoring,locationManager, scrollViewCustom ,firstBeacon, previosBeacon, lblEnterAndExitStatus, isEnteredInRegion,isUUIDgoingToChange;
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIDevice *DeviceInfo = [[UIDevice alloc]init];
    NSLog(@"device info :%@",[DeviceInfo hardwareString]) ;
    if(([DeviceInfo hardware]>=4 && [DeviceInfo hardware]<=6)||([DeviceInfo hardware]>=23 && [DeviceInfo hardware]<=35)){
        scrollViewCustom.contentSize = CGSizeMake(320,590);
    }else if ([DeviceInfo hardware]>=7 && [DeviceInfo hardware]<=11){
        scrollViewCustom.contentSize = CGSizeMake(320,568);
    }
    

    //[self startMonitor];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:NO];
    // initialize location manager
    if (!self.locationManager) { //initializing for authorizition
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    isEnteredInRegion = YES;
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


#pragma mark - ESTBeaconManager delegates

-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
    if(isUUIDgoingToChange){
        if([self isValidBeacon:[beacons objectAtIndex:0]]){
            NSLog(@"you have got right beacon to change!");
        }
        NSLog(@"uuid is going to change!");
        isUUIDgoingToChange=NO;
    }
    [self statusLabelForBeacons:beacons];
    [self detectedBeaconUpdateAtRunTimeforBeacons:beacons];
    //maintain table height
    int tableContentHeight = kCellHeight *[self.detectedBeacons count];
    self.beaconTableView.contentSize = CGSizeMake(320, tableContentHeight);
    //[self.beaconTableView reloadData];
}

-(void)beaconManager:(ESTBeaconManager *)manager
   didDetermineState:(CLRegionState)state
           forRegion:(ESTBeaconRegion *)region
{
    if(state == CLRegionStateInside)
    {
        NSLog(@"in didDetermineState: CLRegionStateInside");
        [self.beaconManager startRangingBeaconsInRegion:region];
    }
    else
    {
        NSLog(@"in didDetermineState: CLRegionStateOutside or CLRegionStateUnknown");
        //[self.beaconManager stopRangingBeaconsInRegion:region];
    }
}


-(void)beaconManager:(ESTBeaconManager *)manager
      didEnterRegion:(ESTBeaconRegion *)region
{
    // present local notification
    [self localNotificationWithAlertBody:@"You have entered the iBeacon area"];
    isEnteredInRegion = YES;
    // iPhone/iPad entered beacon zone
    [self.beaconManager startRangingBeaconsInRegion:region];
    
}

-(void)beaconManager:(ESTBeaconManager *)manager
       didExitRegion:(ESTBeaconRegion *)region
{
    // present local notification
    [self localNotificationWithAlertBody:@"You have exited the iBeacon area"];
    self.previosBeacon=nil;
    isEnteredInRegion = NO;
    // iPhone/iPad left beacon zone
    [self.beaconManager stopRangingBeaconsInRegion:region];
    
}

-(void)beaconManager:(ESTBeaconManager *)manager rangingBeaconsDidFailForRegion:(ESTBeaconRegion *)region withError:(NSError *)error{
    [self localNotificationWithAlertBody:[NSString stringWithFormat:@"Beacon ranging failed with error: %@", error]];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    // current location usage is required to use this demo app
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        [[[UIAlertView alloc] initWithTitle:@"Current Location Required"
                                    message:@"Please re-enable Core Location From Setting to run this Demo.The app will now exit."
                                   delegate:self
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil] show];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // exit application if user declined Current Location permissions
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:NO];
    exit(0);
}


#pragma mark -DidRange Action methods

-(void)statusLabelForBeacons:(NSArray*)beacons{
    if([beacons count] > 0)
    {
        NSString* labelText;
        self.selectedBeacon =  beacons[0];// [beacons objectAtIndex:0];
        self.lblEnterAndExitStatus.text =[NSString stringWithFormat:@"%@ Beacon is near by you", [self tellBeaconNamefor:self.selectedBeacon]];
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
            
        int currentBeaconInteger = [self.selectedBeacon.major intValue];
        int preViousBeaconInteger = [self.previosBeacon.major intValue];
        BOOL checkBeacon = FALSE;
        if (currentBeaconInteger != preViousBeaconInteger) {
            checkBeacon = TRUE;
        }
         //[self rangeNotificationWithBeaconName:[self tellBeaconNamefor:self.selectedBeacon]];
        if(isEnteredInRegion && checkBeacon){  // checking if new detected beacon is previos one, if yes ignore it.
           [self rangeNotificationWithBeaconName:[self tellBeaconNamefor:self.selectedBeacon]];
        }
        
        self.previosBeacon = self.selectedBeacon; //this is handling race condition for notification
        
    }else{
        self.lblEnterAndExitStatus.text = @"Please wait ..! Status is going to change";
        self.lblBeacon.text = @"currently there is no beacons nearby";
        isEnteredInRegion = YES;
        //[self localNotificationWithAlertBody:@"currently there is no beacon"];
    }
}

-(void)rangeNotificationWithBeaconName:(NSString*)beaconName{
    [self localNotificationWithAlertBody:[NSString stringWithFormat:@"There is %@ beacon near by you!",beaconName]];
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state==UIApplicationStateBackground||state==UIApplicationStateInactive){
        
        if(state==UIApplicationStateBackground){
            NSLog(@"didRangeBeacons is in background mode");
        }else if(state==UIApplicationStateInactive){
            NSLog(@"didRangeBeacons is in Inactive mode");
        }
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
    }else{
        beaconName = @"Unknown";
    }
    return beaconName;
}

- (NSArray *)filteredBeacons:(NSArray *)beacons
{
    // Filters duplicate beacons out; this may happen temporarily if the originating device changes its Bluetooth id
    NSMutableArray *mutableBeacons = [beacons mutableCopy];
    
    NSMutableSet *lookup = [[NSMutableSet alloc] init];
    for (int index = 0; index < [beacons count]; index++) {
        CLBeacon *curr = [beacons objectAtIndex:index];
        NSString *identifier = [NSString stringWithFormat:@"%@/%@", curr.major, curr.minor];
        
        // this is very fast constant time lookup in a hash table
        if ([lookup containsObject:identifier]) {
            [mutableBeacons removeObjectAtIndex:index];
        } else {
            [lookup addObject:identifier];
        }
    }
    
    return [mutableBeacons copy];
}


-(void)detectedBeaconUpdateAtRunTimeforBeacons:(NSArray*)beacons{
    NSArray *filteredBeacons = [self filteredBeacons:beacons];
    
    if (filteredBeacons.count == 0) {
        NSLog(@"No beacons found nearby.");
    } else {
        NSLog(@"Found %lu %@.", (unsigned long)[filteredBeacons count],
              [filteredBeacons count] > 1 ? @"beacons" : @"beacon");
        
    }
    
    NSArray *deletedRows = [self indexPathsOfRemovedBeacons:filteredBeacons];
    NSArray *insertedRows = [self indexPathsOfInsertedBeacons:filteredBeacons];
    NSArray *reloadedRows = nil;
    if (!deletedRows && !insertedRows)
        reloadedRows = [self indexPathsForBeacons:filteredBeacons];
    
    self.detectedBeacons = filteredBeacons;
    
    [self.beaconTableView beginUpdates];
    if (insertedRows)
        [self.beaconTableView insertRowsAtIndexPaths:insertedRows withRowAnimation:UITableViewRowAnimationFade];
    if (deletedRows)
        [self.beaconTableView deleteRowsAtIndexPaths:deletedRows withRowAnimation:UITableViewRowAnimationFade];
    if (reloadedRows)
        [self.beaconTableView reloadRowsAtIndexPaths:reloadedRows withRowAnimation:UITableViewRowAnimationNone];
    [self.beaconTableView endUpdates];
}

#pragma mark - Calculate indexPath To update

- (NSArray *)indexPathsOfRemovedBeacons:(NSArray *)beacons
{
    NSMutableArray *indexPaths = nil;
    
    NSUInteger row = 0;
    for (CLBeacon *existingBeacon in self.detectedBeacons) {
        BOOL stillExists = NO;
        for (CLBeacon *beacon in beacons) {
            if ((existingBeacon.major.integerValue == beacon.major.integerValue) &&
                (existingBeacon.minor.integerValue == beacon.minor.integerValue)) {
                stillExists = YES;
                break;
            }
        }
        if (!stillExists) {
            if (!indexPaths)
                indexPaths = [NSMutableArray new];
            [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:0]];
        }
        row++;
    }
    
    return indexPaths;
}

- (NSArray *)indexPathsOfInsertedBeacons:(NSArray *)beacons
{
    NSMutableArray *indexPaths = nil;
    
    NSUInteger row = 0;
    for (CLBeacon *beacon in beacons) {
        BOOL isNewBeacon = YES;
        for (CLBeacon *existingBeacon in self.detectedBeacons) {
            if ((existingBeacon.major.integerValue == beacon.major.integerValue) &&
                (existingBeacon.minor.integerValue == beacon.minor.integerValue)) {
                isNewBeacon = NO;
                break;
            }
        }
        if (isNewBeacon) {
            if (!indexPaths)
                indexPaths = [NSMutableArray new];
            [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:0]];
        }
        row++;
    }
    
    return indexPaths;
}

- (NSArray *)indexPathsForBeacons:(NSArray *)beacons
{
    NSMutableArray *indexPaths = [NSMutableArray new];
    for (NSUInteger row = 0; row < beacons.count; row++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:0]];
    }
    
    return indexPaths;
}



#pragma mark - LocalNotification

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
        NSLog(@"in foreground : %@",body);
//        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:body delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alert show];
    }
}

#pragma mark - Button actions

-(IBAction)refreshMonitoring:(id)sender{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [self startMonitor];
    //[self.beaconManager startMonitoringForRegion:self.beaconRegion];
}

//-(IBAction)startMonitoring:(id)sender{
//    [self.beaconManager startMonitoringForRegion:self.beaconRegion];
//}
//
//-(IBAction)pauseMonitoring:(id)sender{
//    [self.beaconManager stopMonitoringForRegion:self.beaconRegion];
//    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];
//}

-(IBAction)changeUUID:(id)sender{
    
    //[self.beaconManager stopMonitoringForRegion:self.beaconRegion];
    //[self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];
    //self.beaconRegion = nil;
    //ChangeUUIDViewController *changeUUIDViewController = [[ChangeUUIDViewController alloc]initWithNibName:@"ChangeUUIDViewController" bundle:Nil];
    //[self.navigationController pushViewController:changeUUIDViewController animated:YES];
}

-(BOOL)isValidBeacon:(ESTBeacon*)beacon{
    BOOL flag = NO;
    int major = [beacon.major intValue];
    int minor = [beacon.minor intValue];
    if([beacon.proximityUUID isEqual:[[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"]] && (major == 12830) && (minor == 49469)){
        flag = YES;
    }
    return flag;
}

#pragma mark - Table View methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.detectedBeacons.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Looking for beacons..";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView =
    [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:kBeaconsHeaderViewIdentifier];
    headerView.frame= CGRectMake(0, 0, tableView.bounds.size.width, 28);
    headerView.contentView.backgroundColor =[UIColor colorWithRed:135/255.0 green:206/255.0 blue:250/255.0 alpha:1];    
    // Adds an activity indicator view to the section header
    UIActivityIndicatorView *indicatorView =
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [headerView addSubview:indicatorView];
    
    indicatorView.frame = (CGRect){kActivityIndicatorPosition, indicatorView.frame.size};
    
    [indicatorView startAnimating];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    ESTBeacon *beacon = self.detectedBeacons[indexPath.row];
    
    cell = [tableView dequeueReusableCellWithIdentifier:kBeaconCellIdentifier];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:kBeaconCellIdentifier];
    cell.backgroundColor = [UIColor cyanColor];
    cell.textLabel.text = beacon.proximityUUID.UUIDString;
    cell.detailTextLabel.text = [self detailsStringForBeacon:beacon];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    return cell;
}

- (NSString *)detailsStringForBeacon:(ESTBeacon *)beacon
{
    NSString *proximity;
    switch (beacon.proximity) {
        case CLProximityNear:
            proximity = @"Near";
            break;
        case CLProximityImmediate:
            proximity = @"Immediate";
            break;
        case CLProximityFar:
            proximity = @"Far";
            break;
        case CLProximityUnknown:
        default:
            proximity = @"Unknown";
            break;
    }
    
    NSString *format = @"%@, %@ • %@ • %.3f • %li";
    return [NSString stringWithFormat:format, beacon.major, beacon.minor, proximity, beacon.distance.doubleValue, beacon.rssi];
}



- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {}

@end
