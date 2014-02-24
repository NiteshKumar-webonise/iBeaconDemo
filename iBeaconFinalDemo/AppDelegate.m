//
//  AppDelegate.m
//  iBeaconFinalDemo
//
//  Created by Webonise on 11/02/14.
//  Copyright (c) 2014 Webonise. All rights reserved.
//

#import "AppDelegate.h"
#define FACEBOOK_LOGIN @"FacebookLogin"
#define GOOGLE_LOGIN @"GoogleLogin"
#define TWITTER_LOGIN @"TwitterLogin"

@implementation AppDelegate
@synthesize body,login_type;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // present local notification
//    UILocalNotification *notification = [[UILocalNotification alloc] init];
//    notification.alertBody = @"Enter";
//    notification.soundName = UILocalNotificationDefaultSoundName;
//    notification.applicationIconBadgeNumber=1;
//    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    login_type = NO_LOGIN_TYPE;  //initialising login type null if not logged in at all
    body = @"default";
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //[self localNotificationWithAlertBody:body];
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation{
    BOOL returnValue=FALSE;
    if([self.login_type isEqualToString:GOOGLE_LOGIN]){
        returnValue= [GPPURLHandler handleURL:url
                            sourceApplication:sourceApplication
                                   annotation:annotation];
        self.isCallBackAuthenticate=YES;
        
    }else if ([self.login_type isEqualToString:FACEBOOK_LOGIN]){
        returnValue=[FBAppCall handleOpenURL:url
                           sourceApplication:sourceApplication
                                 withSession:self.session];
    }
    return returnValue;
}

-(void)localNotificationWithAlertBody:(NSString*)msg{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state==UIApplicationStateBackground||state==UIApplicationStateInactive){
        
        if(state==UIApplicationStateBackground){
             NSLog(@"App is in background mode");
        }else if(state==UIApplicationStateInactive){
             NSLog(@"App is in Inactive mode");
        }
        NSLog(@"App is in background mode");
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = msg;
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

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    //application.applicationIconBadgeNumber=0;
    [FBAppEvents activateApp];
    [FBAppCall handleDidBecomeActiveWithSession:self.session];
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
