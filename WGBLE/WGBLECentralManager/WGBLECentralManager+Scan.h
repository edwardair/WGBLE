//
//  WGBLECentralManager+Scan.h
//  RmFM
//
//  Created by Eduoduo on 15/3/6.
//  Copyright (c) 2015年 Eduoduo. All rights reserved.
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
