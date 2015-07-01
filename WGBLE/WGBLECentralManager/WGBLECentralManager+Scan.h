//
//  WGBLECentralManager+Scan.h
//  RmFM
//
//  Created by RayMi on 15/3/6.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "WGBLECentralManager.h"

#pragma mark - Scan


@interface WGBLECentralManager (Scan)

/**
 *  scan可用的service
 */
- (void)scan;//scanForPeripheralsWithServices:nil options:nil
- (void)scanForPeripheralsWithServices:(NSArray *)serviceUUIDs options:(NSDictionary *)options;
- (void)stopScan;

@end
