//
//  BeaconRegion.h
//  iBeaconFinalDemo
//
//  Created by Webonise on 14/02/14.
//  Copyright (c) 2014 Webonise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface BeaconRegion : CLBeaconRegion
+ (instancetype)targetRegion;
@end
