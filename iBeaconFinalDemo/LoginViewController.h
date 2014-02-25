//
//  LoginViewController.h
//  iBeaconFinalDemo
//
//  Created by Webonise on 24/02/14.
//  Copyright (c) 2014 Webonise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <GPPSignInDelegate>

@property (nonatomic, retain) IBOutlet UIButton *btnGooglSignIn;
-(IBAction)facebookLoginAction:(id)sender;
@end
