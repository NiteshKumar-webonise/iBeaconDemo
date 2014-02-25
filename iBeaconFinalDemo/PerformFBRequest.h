//
//  PerformFBRequest.h
//  FriendFinder5
//
//  Created by Webonise on 04/10/13.
//  Copyright (c) 2013 Webonise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PerformFBRequestResponce.h"
#import "MBProgressHUD.h"
@interface PerformFBRequest : NSObject
@property (retain,nonatomic) id<PerformFBRequestResponce> delegate;
@property (strong, nonatomic) FBRequestConnection *requestConnection;
@property (strong, nonatomic) MBProgressHUD *loadProgress;
@property bool showProgress;
- (void)sendRequestswithGraphPath:(NSString*)graphpath;
- (void)showLoadingWithLabel:(NSString *)loadingMsg withView:(UIView *)view;
@end
