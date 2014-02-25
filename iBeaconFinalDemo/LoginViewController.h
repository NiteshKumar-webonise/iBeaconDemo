//
//  LoginViewController.h
//  iBeaconFinalDemo
//
//  Created by Webonise on 24/02/14.
//  Copyright (c) 2014 Webonise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface LoginViewController : UIViewController <GPPSignInDelegate>

@property (nonatomic, retain) IBOutlet GPPSignInButton *btnGooglSignIn;
@property (nonatomic,retain) MBProgressHUD *mbProgressHUD;
@property (retain, nonatomic) NSString *authStatus;

-(IBAction)facebookLoginAction:(id)sender;
@end
