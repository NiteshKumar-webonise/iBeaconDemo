//
//  CloudAuthVC.h
//  iBeaconFinalDemo
//
//  Created by Nitesh_iMac on 8/18/14.
//  Copyright (c) 2014 Webonise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CloudAuthVC : UIViewController
+(void)setAuthenticationStatus:(BOOL)statusValue;
+(BOOL)getAuthenticationStatus;
@end
