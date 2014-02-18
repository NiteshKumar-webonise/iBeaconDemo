//
//  WebserviceHelperClass.m
//
//  Created by Nithal Paldewar  on 08/05/13.
//  Copyright (c) 2013 Webonise Lab. All rights reserved.
//

#import "WebserviceHelperClass.h"

@implementation WebserviceHelperClass
@synthesize delegate;
@synthesize showLoadingView;
@synthesize loadingViewFont,loadingViewToAdd,loadingViewText;

#pragma mark - LoadingView

-(void)setLoadingView {
    if(showLoadingView){
        if(!loadingViewToAdd)
            loadingViewToAdd = [[UIApplication sharedApplication] keyWindow];
        
        loadingView = [MBProgressHUD showHUDAddedTo:loadingViewToAdd animated:YES];
        loadingView.detailsLabelFont = loadingViewFont;
        loadingView.detailsLabelText = loadingViewText;
    }
}

#pragma mark - Service call types

// Service call for the POST request
-(void)callWebServiceForPOSTRequest:(NSString *)urlString withParameters:(NSDictionary *)parameters  withServiceTag:(int)tag {
    [self setLoadingView];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    [self doRequest:url withParameters:parameters withServiceTag:tag withIsHeader:NO];
}

// Service call for the POST request and response headers
-(void)callWebServiceForPOSTRequestWithHeader:(NSString *)urlString withParameters:(NSDictionary *)parameters  withServiceTag:(int)tag {
    [self setLoadingView];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    [self doRequest:url withParameters:parameters withServiceTag:tag withIsHeader:YES];
}


-(void)doRequest:(NSURL *)url withParameters:(NSDictionary *)parameters withServiceTag:(int)tag withIsHeader:(BOOL)isHeader  {
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setAllowsInvalidSSLCertificate:YES];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    
    [client postPath:@""
          parameters:parameters
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 if(showLoadingView)
                     [loadingView hide:YES];
                 
                 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                 if (isHeader) {
                     [delegate apiCallResponse:responseObject andServiceTag:tag andResponseHeader:[[operation response] allHeaderFields]];
                 } else {
                     [delegate apiCallResponse:responseObject andServiceTag:tag];
                 }
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 if(showLoadingView)
                     [loadingView hide:YES];
                 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                 [delegate apiCallError:error andServiceTag:tag];
             }
     ];
}

// Service call for the GET request
-(void)callWebServiceForGETRequest:(NSString *)urlString withParameters:(NSDictionary *)parameters withServiceTag:(int)tag {
    [self setLoadingView];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setAllowsInvalidSSLCertificate:YES];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    
    [client getPath:@""
         parameters:parameters
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if(showLoadingView)
                    [loadingView hide:YES];
                
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                [delegate apiCallResponse:responseObject andServiceTag:tag];
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if(showLoadingView)
                    [loadingView hide:YES];
                
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                [delegate apiCallError:error andServiceTag:tag];
            }
     ];
}


#pragma mark - service call for uploading media files

// Service call for the POST request with some media files
-(void)callWebServiceForPOSTRequestForUploadFile:(NSString *)urlString withParameters:(NSDictionary *)parameters withContentType:(NSString *)mimeType withFileName:(NSString *)fileName withKeyName:(NSString *)keyName withServiceTag:(int)tag {
    
    [self setLoadingView];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];// specify your audioname
    NSData *audioData = [[NSData alloc] initWithContentsOfFile:filePath];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [httpClient setAllowsInvalidSSLCertificate:YES];
    
    NSURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:audioData name:keyName fileName:fileName mimeType:mimeType];
    }];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            if(showLoadingView)
                                                                                                [loadingView hide:YES];
                                                                                            
                                                                                            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                                                            [delegate apiCallResponse:JSON andServiceTag:tag];
                                                                                            
                                                                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            if(showLoadingView)
                                                                                                [loadingView hide:YES];
                                                                                            
                                                                                            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                                                            [delegate apiCallError:error andServiceTag:tag];
                                                                                            
                                                                                        }];
    [operation start];
}


@end
