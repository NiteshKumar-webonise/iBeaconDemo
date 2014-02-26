//
//  UserData.h
//  iBeaconFinalDemo
//
//  Created by Webonise on 26/02/14.
//  Copyright (c) 2014 Webonise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserData : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * email;

@end
