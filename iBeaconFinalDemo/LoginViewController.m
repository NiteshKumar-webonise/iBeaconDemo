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
@synthesize btnGooglSignIn;

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
    //[signIn trySilentAuthentication];
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
        [appDelegate.session openWithBehavior:FBSessionLoginBehaviorWithNoFallbackToWebView //FBSessionLoginBehaviorForcingWebView
                            completionHandler:^(FBSession *session,FBSessionState status,NSError *error) {
            
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
        [self dismisLoginController];
    } else {
        //log out
    }
    
}

-(void)dismisLoginController{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)showLoadingWithLabel:(NSString *)loadingMsg withView:(UIView *)view{
    self.mbProgressHUD = [MBProgressHUD showHUDAddedTo:view animated:NO];
    self.mbProgressHUD.labelText = loadingMsg;
}


#pragma mark -Google signIn delegate
- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    if(error){
        NSLog(@"Received error %@",error);
    }else{
        NSLog(@"auth object %@",auth);
        [self.mbProgressHUD hide:YES];
        AppDelegate *appDelegate= [[UIApplication sharedApplication] delegate];
        appDelegate.isCallBackAuthenticate=NO;
        //[self dismisLoginController];
        [self reportAuthStatus];
    }
    
}

#pragma mark -checkStatus
- (BOOL)reportAuthStatus {
    BOOL status;
    if ([GPPSignIn sharedInstance].authentication) {
        self.authStatus = @"Status: Authenticated";
        status=YES;
    } else {
        // To authenticate, use Google+ sign-in button.
        self.authStatus = @"Status: Not authenticated";
        status=NO;
    }
    NSLog(@"Authentication status:%@",self.authStatus);
    [self refreshUserInfo];
    return status;
}

// Update the interface elements containing user data to reflect the
// currently signed in user.
- (void)refreshUserInfo {
    NSString *userName,*emailAddress;
    
    if ([GPPSignIn sharedInstance].authentication == nil) {
        userName = @"";
        emailAddress = @"";
        //self.userAvatar.image = [UIImage imageNamed:kPlaceholderAvatarImageName];
        return;
    }
    
    emailAddress = [GPPSignIn sharedInstance].userEmail;
    NSLog(@"User email address is:%@",emailAddress);
    // The googlePlusUser member will be populated only if the appropriate
    // scope is set when signing in.
    GTLPlusPerson *person = [GPPSignIn sharedInstance].googlePlusUser;
    if (person == nil) {
        return;
    }
    
    userName= person.displayName;
    NSLog(@"User name is :%@",userName);
    
    // Load avatar image asynchronously, in background
    dispatch_queue_t backgroundQueue =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(backgroundQueue, ^{
        NSData *avatarData = nil;
        NSString *imageURLString = person.image.url;
        if (imageURLString) {
            NSURL *imageURL = [NSURL URLWithString:imageURLString];
            avatarData = [NSData dataWithContentsOfURL:imageURL];
        }
        
        if (avatarData) {
            // Update UI from the main thread when available
            dispatch_async(dispatch_get_main_queue(), ^{
                //self.userAvatar.image = [UIImage imageWithData:avatarData];
            });
        }
    });
}


@end
