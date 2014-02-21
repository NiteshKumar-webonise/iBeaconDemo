//
//  UIDevice+Hardware.h
//  TestTable
//
//  Created by Inder Kumar Rathore on 19/01/13.
//  Copyright (c) 2013 Rathore. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IS_IPAD (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
#define DEVICE_IOS_VERSION [[UIDevice currentDevice].systemVersion floatValue]
#define DEVICE_HARDWARE_BETTER_THAN(i) [[UIDevice currentDevice] isCurrentDeviceHardwareBetterThan:i]

typedef enum
{
    NOT_AVAILABLE,//0
    
    IPHONE_2G,//1
    IPHONE_3G,
    IPHONE_3GS,
    IPHONE_4,//4
    IPHONE_4_CDMA,//5
    IPHONE_4S,//6
    IPHONE_5,//7
    IPHONE_5_CDMA_GSM,//8
    IPHONE_5C,//9
    IPHONE_5C_CDMA_GSM,
    IPHONE_5S,//10
    IPHONE_5S_CDMA_GSM,//11
    
    IPOD_TOUCH_1G,//12
    IPOD_TOUCH_2G,
    IPOD_TOUCH_3G,
    IPOD_TOUCH_4G,
    IPOD_TOUCH_5G,//16
    
    IPAD,//17
    IPAD_2,
    IPAD_2_WIFI,
    IPAD_2_CDMA,
    IPAD_3,//21
    IPAD_3G,//22
    IPAD_3_WIFI,//23
    IPAD_3_WIFI_CDMA,//24
    IPAD_4,//25
    IPAD_4_WIFI,//26
    IPAD_4_GSM_CDMA,//27
    
    IPAD_MINI,//28
    IPAD_MINI_WIFI,
    IPAD_MINI_WIFI_CDMA,
    IPAD_MINI_RETINA_WIFI,
    IPAD_MINI_RETINA_WIFI_CDMA,//32
    
    IPAD_AIR_WIFI,//33
    IPAD_AIR_WIFI_GSM,//34
    IPAD_AIR_WIFI_CDMA,//35
    
    SIMULATOR
} Hardware;


@interface UIDevice (Hardware)
/** This method retruns the hardware type */
- (NSString*)hardwareString;

/** This method returns the Hardware enum depending upon harware string */
- (Hardware)hardware;

/** This method returns the readable description of hardware string */
- (NSString*)hardwareDescription;

/** This method returs the readble description without identifier (GSM, CDMA, GLOBAL) */
- (NSString *)hardwareSimpleDescription;

/** This method returns YES if the current device is better than the hardware passed */
- (BOOL)isCurrentDeviceHardwareBetterThan:(Hardware)hardware;
@end
