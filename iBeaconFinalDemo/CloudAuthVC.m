//
//  CloudAuthVC.m
//  iBeaconFinalDemo
//
//  Created by Nitesh_iMac on 8/18/14.
//  Copyright (c) 2014 Webonise. All rights reserved.
//

#import "CloudAuthVC.h"
#import "ESTBeaconManager.h"
#import "Reachability.h"


@interface CloudAuthVC() <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtAppId;
@property (weak, nonatomic) IBOutlet UITextField *txtAppToken;
@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;

@end


@implementation CloudAuthVC
bool internetStatus = false;
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Estimote Authorization";
    
//    self.txtAppId.delegate    = self;
//    self.txtAppToken.delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    NSString *remoteHostName = @"www.google.com";
    
    self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
	[self.hostReachability startNotifier];
	[self updateInterfaceWithReachability:self.hostReachability];
}

- (void) reachabilityChanged:(NSNotification *)note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
	[self updateInterfaceWithReachability:curReach];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    if (reachability == self.hostReachability)
	{
		//[self configureTextField:self.remoteHostStatusField imageView:self.remoteHostImageView reachability:reachability];
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        BOOL connectionRequired = [reachability connectionRequired];
        NSLog(@"connectionRequired %hhd",connectionRequired);
        if(netStatus == NotReachable || connectionRequired == YES){
            internetStatus = false;
        }else if (netStatus == ReachableViaWWAN ){
            internetStatus = true;
        }else if (netStatus == ReachableViaWiFi){
            internetStatus = true;
        }
        //internetStatus = (netStatus != ReachableViaWWAN);
        //self.summaryLabel.text = baseLabelText;
    }
    
//	if (reachability == self.internetReachability)
//	{
//		//[self configureTextField:self.internetConnectionStatusField imageView:self.internetConnectionImageView reachability:reachability];
//	}
//    
//	if (reachability == self.wifiReachability)
//	{
//		//[self configureTextField:self.localWiFiConnectionStatusField imageView:self.localWiFiConnectionImageView reachability:reachability];
//	}
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.txtAppToken resignFirstResponder];
    [self.txtAppId resignFirstResponder];
}

- (IBAction)authenticate:(UIButton *)sender {
	[self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
    if (internetStatus) {
        NSLog(@"net is on");
       [ESTBeaconManager setupAppID:self.txtAppId.text andAppToken:self.txtAppToken.text];
       [CloudAuthVC setAuthenticationStatus:true];
       [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"No Internet connection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)dismiss:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

+(void)setAuthenticationStatus:(BOOL)statusValue{
    [[NSUserDefaults standardUserDefaults] setBool:statusValue forKey:@"AuthStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getAuthenticationStatus{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"AuthStatus"];
}

@end
