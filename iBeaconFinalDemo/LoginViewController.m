//
//  LoginViewController.m
//  iBeaconFinalDemo
//
//  Created by Webonise on 24/02/14.
//  Copyright (c) 2014 Webonise. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

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
    [self googleLoginSettings];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)googleLoginSettings{
    //[self reportAuthStatus];
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    //self.signInButton.style=kGPPSignInButtonStyleWide;
    [self.btnGooglSignIn addTarget:self action:@selector(setLoginType) forControlEvents:UIControlEventTouchUpInside];
    signIn.shouldFetchGooglePlusUser=YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.clientID=CLIENT_ID;
    signIn.scopes=[NSArray arrayWithObjects:kGTLAuthScopePlusLogin, nil];
    signIn.delegate=self;
    [signIn trySilentAuthentication];
}

-(void)setLoginType{
    AppDelegate *appDelegate= [[UIApplication sharedApplication] delegate];
    appDelegate.login_type=GOOGLE_LOGIN;
    
}

#pragma mark -Facebook signIn delegate
-(IBAction)facebookLoginAction:(id)sender{
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    if(!appDelegate.session.isOpen){
        appDelegate.session = [[FBSession alloc] initWithPermissions:@[@"basic_info",@"email"]];
        appDelegate.login_type=FACEBOOK_LOGIN;
        [appDelegate.session openWithBehavior:FBSessionLoginBehaviorForcingWebView completionHandler:^(FBSession *session,FBSessionState status,NSError *error) {
            
            if(error){
                
                [self handleAuthError:error];
            }
            
            switch (status) {
                case FBSessionStateOpen:
                    if (!error) {
                        // We have a valid session
                        NSLog(@"User session found");
                        [self actionAfterLogin];
                    }
                    break;
                case FBSessionStateClosed:
                    NSLog(@"FBSessionStateClosed");
                case FBSessionStateClosedLoginFailed:
                    NSLog(@"FBSessionStateClosedLoginFailed");
                    [FBSession.activeSession closeAndClearTokenInformation];
                    break;
                default:
                    break;
            }
            if (!error) {
                [self actionAfterLogin];
            }
        }];
        
    }
}

- (void)handleAuthError:(NSError *)error{
    NSString *alertMessage, *alertTitle;
    NSLog(@"Error %@",error.debugDescription);
    NSLog(@"Error Dic %@",error.userInfo);
    NSLog(@"Error %@",[error fberrorUserMessage]);
    [error fberrorUserMessage];
    if (error.fberrorShouldNotifyUser) {
        // If the SDK has a message for the user, surface it.
        alertTitle = @"Something Went Wrong";
        alertMessage = error.fberrorUserMessage;
    } else if (error.fberrorCategory == FBErrorCategoryUserCancelled) {
        // The user has cancelled a login. You can inspect the error
        // for more context. For this sample, we will simply ignore it.
        NSLog(@"user cancelled login");
    } else {
        // For simplicity, this sample treats other errors blindly.
        alertTitle  = @"Unknown Error";
        alertMessage = @"Error. Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (void)actionAfterLogin{
    // get the app delegate, so that we can reference the session property
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (appDelegate.session.isOpen) {
        //[self.performFBRequest showLoadingWithLabel:@"Loading..." withView:self.view];
        //[self.performFBRequest sendRequestswithGraphPath:@"me?fields=id,name,first_name,last_name,email,picture.width(120).height(59),username"];
        
        [self dismisLoginController];
    } else {
        //log out
    }
    
}

-(void)dismisLoginController{
    [self dismissViewControllerAnimated:NO completion:nil];
}


@end
