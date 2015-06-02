//
//  WGBLEPeripheral+Discover.h
//  RmFM
//
//  Created by RayMi on 15/3/7.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "WGBLEPeripheral.h"
#import <CoreBluetooth/CoreBluetooth.h>
@interface WGBLEPeripheral (Discover)<CBPeripheralDelegate>
- (void)setupPeripheralDelegate;




@end
