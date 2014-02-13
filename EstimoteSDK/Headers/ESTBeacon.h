//
//  ESTBeacon.h
//  EstimotePrivSDK7
//
//  Version : 1.0.0
//  Created by Marcin Klimek on 9/19/13.
//  Copyright (c) 2013 Estimote. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "ESTBeaconDefinitions.h"

////////////////////////////////////////////////////////////////////
// Estimote beacon delegate protocol


/**
 
 ESTBeaconDelegate defines beacon connection delegate mathods. Connection is asynchronous operation so you need to be prepared that eg. beaconDidDisconnectWith: method can be invoked without previous action.
 
 */

@protocol ESTBeaconDelegate <NSObject>

@optional

/**
 * Delegate method that indicates error in beacon connection.
 *
 * @param error information about reason of error
 *
 * @return void
 */
- (void)beaconConnectionDidFail:(NSError*)error;

/**
 * Delegate method that indicates success in beacon connection.
 *
 * @return void
 */
- (void)beaconConnectionDidSucceeded;

/**
 * Delegate method that beacon did disconnect with device.
 *
  * @param error information about reason of error
 *
 * @return void
 */
- (void)beaconDidDisconnectWithError:(NSError*)error;

@end


////////////////////////////////////////////////////////////////////
// Interface definition

/**
 
 The ESTBeacon class represents a beacon that was encountered during region monitoring. You do not create instances of this class directly. The ESTBeaconManager object reports encountered beacons to its associated delegate object. You can use the information in a beacon object to identify which beacon was encountered.
 
 
ESTBeacon class contains basic Apple CLBeacon object reference as well as some additional functionality. It allows to  connect with Estimote beacon to read / write its characteristics.
 
 */

@interface ESTBeacon : NSObject

@property (nonatomic)           ESTBeaconFirmwareState  firmwareState;
@property (nonatomic)           id <ESTBeaconDelegate>  delegate;

/////////////////////////////////////////////////////
// bluetooth beacon available when used with
// startEstimoteBeaconsDiscoveryForRegion:

@property (nonatomic, strong)   CBPeripheral*           peripheral;
@property (nonatomic, strong)   NSString*               macAddress;
@property (nonatomic, strong)   NSNumber*               measuredPower;
@property (nonatomic, strong)   NSNumber*               major;
@property (nonatomic, strong)   NSNumber*               minor;
@property (nonatomic, strong)   NSNumber*               rssi;

/////////////////////////////////////////////////////
// properties filled when read characteristic

@property (nonatomic, strong)   NSNumber*               power;
@property (nonatomic, strong)   NSNumber*               frequency;
@property (nonatomic, strong)   NSNumber*               baterryLevel;

@property (nonatomic, strong)   NSString*               hardwareVersion;
@property (nonatomic, strong)   NSString*               firmwareVersion;

/////////////////////////////////////////////////////
// core location properties

@property (nonatomic, strong)   CLBeacon*               ibeacon;


@property (nonatomic, readonly)   BOOL                  isConnected;


/**
 * Connect device to particular beacon
 *
 * @return void
 */
-(void)connectToBeacon;

/**
 * Disconnect device with particular beacon
 *
 * @return void
 */
-(void)disconnectBeacon;

/**
 * Read major of connected beacon
 *
 * @param completition Block handling operation completition
 *
 * @return Point Major and Minor points
 */
- (void)readBeaconMajorWithCompletition:(ESTUnsignedCompletitionBlock)completition;

/**
 * Read minor of connected beacon
 *
 * @param completition block handling operation completition
 *
 * @return Point Major and Minor points
 */
- (void)readBeaconMinorWithCompletition:(ESTUnsignedCompletitionBlock)completition;

/**
 * Read frequency and minor of connected beacon
 *
 * @param completition block handling operation completition
 *
 * @return void
 */
- (void)readBeaconFrequencyWithCompletition:(ESTUnsignedCompletitionBlock)completition;


/**
 * Read power of connected beacon
 *
 * @param completition block handling operation completition
 *
 * @return float value of beacon power
 */
- (void)readBeaconPowerWithCompletition:(ESTUnsignedCompletitionBlock)completition;

/**
 * Read battery level of connected beacon
 *
 * @param completition block handling operation completition
 *
 * @return void
 */
- (void)readBeaconBatteryWithCompletition:(ESTUnsignedCompletitionBlock)completition;

/**
 * Read firmware version of connected beacon
 *
 * @param completition Block handling operation completition
 *
 * @return void
 */
- (void)readBeaconFirmwareVersionWithCompletition:(ESTStringCompletitionBlock)completition;

/**
 * Read hardware version of connected beacon
 *
 * @param completition block handling operation completition
 *
 * @return void
 */
- (void)readBeaconHardwareVersionWithCompletition:(ESTStringCompletitionBlock)completition;


/**
 * Write major param of connected beacon.
 *
 * @param major major beacon value
 * @param completition block handling operation completition
 *
 * @return void
 */
- (void)writeBeaconMajor:(short)major withCompletition:(ESTUnsignedCompletitionBlock)completition;

/**
 * Write minor param of connected beacon.
 *
 * @param minor minor beacon value
 * @param completition block handling operation completition
 *
 * @return void
 */
- (void)writeBeaconMinor:(short)minor withCompletition:(ESTUnsignedCompletitionBlock)completition;

/**
 * Write frequency of connected beacon.
 *
 * @param frequency advertising beacon frequency
 * @param completition block handling operation completition
 *
 * @return void
 */
- (void)writeBeaconFrequency:(short)frequency withCompletition:(ESTUnsignedCompletitionBlock)completition;


/**
 * Write power of connected beacon.
 *
 * @param power advertising beacon power
 * @param completition block handling operation completition
 *
 * @return void
 */
- (void)writeBeaconPower:(ESTBeaconPower)power withCompletition:(ESTUnsignedCompletitionBlock)completition;


/**
 * Update firmware of connected beacon.
 *
 * @param completition Block handling operation completition
 *
 * @return void
 */
-(void)updateBeaconFirmwareWithProgress:(ESTStringCompletitionBlock)progress
                        andCompletition:(ESTCompletitionBlock)completition;

@end
