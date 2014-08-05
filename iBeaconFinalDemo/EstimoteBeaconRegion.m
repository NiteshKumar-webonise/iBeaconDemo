//
//  EstimoteBeaconRegion.m
//  iBeaconFinalDemo
//
//  Created by Webonise on 20/02/14.
//  Copyright (c) 2014 Webonise. All rights reserved.
//

#import "EstimoteBeaconRegion.h"
#define ESTIMOTE_PROXIMITY_UUID [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"]
@implementation EstimoteBeaconRegion
static EstimoteBeaconRegion *_sharedInstance = nil;
+ (instancetype)targetRegion {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[EstimoteBeaconRegion alloc] init];
    });
    return _sharedInstance;
}

- (id)init {
    
    // initialize a new CLBeaconRegion with application-specific UUID and human-readable identifier
    NSUUID *UUID = ESTIMOTE_IOSBEACON_PROXIMITY_UUID;
    self = [super initWithProximityUUID:UUID
                             identifier:@"EstimoteSampleRegion"];
    
    if (self) {
        self.notifyEntryStateOnDisplay = YES;     // only notify user if app is active
        self.notifyOnEntry = YES;                 // notify user on region entrance
        self.notifyOnExit = YES;                  // notify user on region exit
    }
    return self;
}
@end
