//
//  WebserviceHelperClass.h
//  iBeaconFinalDemo
//
//  Created by Webonise on 18/02/14.
//  Copyright (c) 2014 Webonise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import "AFNetworking.h"

@protocol WebserviceDelegate <NSObject>
@optional
-(void) apiCallResponse:(id)response andServiceTag:(int)tag andResponseHeader:(NSDictionary *)headers;
-(void) apiCallResponse:(id)response andServiceTag:(int)tag;
@required
-(void) apiCallError:(NSError *)error andServiceTag:(int)tag;
@end

@interface WebserviceHelperClass : NSObject{
    MBProgressHUD *loadingView;
}

@property (retain, nonatomic) id <WebserviceDelegate> delegate;
@property (retain, nonatomic) UIView *loadingViewToAdd;
@property (retain, nonatomic) UIFont *loadingViewFont;
@property (retain, nonatomic) NSString *loadingViewText;
@property (nonatomic) BOOL showLoadingView;

-(void)callWebServiceForPOSTRequest:(NSString *)urlString withParameters:(NSDictionary *)parameters withServiceTag:(int)tag;
-(void)callWebServiceForPOSTRequestWithHeader:(NSString *)urlString withParameters:(NSDictionary *)parameters  withServiceTag:(int)tag;
-(void)callWebServiceForGETRequest:(NSString *)urlString withParameters:(NSDictionary *)parameters withServiceTag:(int)tag;
-(void)doRequest:(NSURL *)url withParameters:(NSDictionary *)parameters withServiceTag:(int)tag withIsHeader:(BOOL)isHeader;
-(void)callWebServiceForPOSTRequestForUploadFile:(NSString *)urlString withParameters:(NSDictionary *)parameters withContentType:(NSString *)mimeType withFileName:(NSString *)fileName withKeyName:(NSString *)keyName withServiceTag:(int)tag ;

@end
