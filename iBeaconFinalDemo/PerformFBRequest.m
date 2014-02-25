//
//  PerformFBRequest.m
//  FriendFinder5
//
//  Created by Webonise on 04/10/13.
//  Copyright (c) 2013 Webonise. All rights reserved.
//

#import "PerformFBRequest.h"
#import "AppDelegate.h"
@implementation PerformFBRequest
@synthesize delegate,showProgress;


- (void)sendRequestswithGraphPath:(NSString*)graphpath {
    NSLog(@"in sendRequestswithGraphPath");
    NSString *fbid=graphpath;
    
    
    // create the connection object
    FBRequestConnection *newConnection = [[FBRequestConnection alloc] init];
    
    // for each fbid in the array, we create a request object to fetch
    // the profile, along with a handler to respond to the results of the request
    
    // create a handler block to handle the results of the request for fbid's profile
    FBRequestHandler handler =
    ^(FBRequestConnection *connection, id result, NSError *error) {
        if (error){
            NSLog(@"there is problem in connection");
            [self.loadProgress hide:YES];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"There is problem in connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
            
            return ;
        }
        [self.delegate thisIsmyResult:result];
        
    };
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // create the request object, using the fbid as the graph path
    // as an alternative the request* static methods of the FBRequest class could
    // be used to fetch common requests, such as /me and /me/friends
    FBRequest *request = [[FBRequest alloc] initWithSession:app.session
                                                  graphPath:fbid];
    
    // add the request to the connection object, if more than one request is added
    // the connection object will compose the requests as a batch request; whether or
    // not the request is a batch or a singleton, the handler behavior is the same,
    // allowing the application to be dynamic in regards to whether a single or multiple
    // requests are occuring
    [newConnection addRequest:request completionHandler:handler];
    
    // if there's an outstanding connection, just cancel
    [self.requestConnection cancel];
    
    // keep track of our connection, and start it
    self.requestConnection = newConnection;
    [newConnection start];
}

- (void)showLoadingWithLabel:(NSString *)loadingMsg withView:(UIView *)view {
    self.loadProgress = [MBProgressHUD showHUDAddedTo:view animated:NO];
    self.loadProgress.labelText = loadingMsg;
}



@end
