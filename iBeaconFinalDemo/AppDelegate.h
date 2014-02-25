//
//  AppDelegate.h
//  iBeaconFinalDemo
//
//  Created by Webonise on 11/02/14.
//  Copyright (c) 2014 Webonise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) FBSession *session;
@property (strong, nonatomic) NSString *login_type;
@property BOOL isCallBackAuthenticate;
@end
