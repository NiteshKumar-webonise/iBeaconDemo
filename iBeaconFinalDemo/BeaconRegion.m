//
//  BeaconRegion.m
//  iBeaconFinalDemo
//
//  Created by Webonise on 14/02/14.
//  Copyright (c) 2014 Webonise. All rights reserved.
//

#import "BeaconRegion.h"

@implementation BeaconRegion
static BeaconRegion *_sharedInstance = nil;



+ (instancetype)targetRegion {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[BeaconRegion alloc] init];
    });
    return _sharedInstance;
}

- (id)init {
    
    // initialize a new CLBeaconRegion with application-specific UUID and human-readable identifier
    self = [super initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"]
                             identifier:@"EstimoteSampleRegion"];
    
    if (self) {
        self.notifyEntryStateOnDisplay = YES;     // only notify user if app is active
        self.notifyOnEntry = YES;                 // notify user on region entrance
        self.notifyOnExit = YES;                  // notify user on region exit
    }
    return self;
}

@end
