//
//  WGBLECentralManager+Initializer.m
//  RmFM
//
//  Created by RayMi on 15/3/6.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "WGBLECentralManager+Connect.h"
#import "WGBLECentralManager+Scan.h"

@implementation WGBLECentralManager (Scan)

#pragma mark -
- (void)scan {
    [self scanForPeripheralsWithServices:nil options:nil];
}
- (void)scanForPeripheralsWithServices:(NSArray *)serviceUUIDs
                               options:(NSDictionary *)options {
    if (!self.centralManagerEnable) {
        NSLog(@"ERROR: centralManager powered off or not usefull");
        return;
    }
    NSLog(@"start 'scan' peripheral,no time out");
    
    //开始搜索时，清空已搜索到的BLE
    [self.foundPeripherals removeAllObjects];
    [self stopScan];
    
    self->_scanState = kBLEScanState_Scaning;
    [self.centralManager scanForPeripheralsWithServices:serviceUUIDs
                                                options:options];
}
- (void)stopScan {
    if (self.scanState != kBLEScanState_NotScan) {
        [self.centralManager stopScan];
        self->_scanState = kBLEScanState_NotScan;
    } else {
        NSLog(@"repeat 'stopScan' has no effect");
    }
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    NSLog(@"%s", __FUNCTION__);
    
    if (![self.foundPeripherals
          containsObject:[self wgPeripheralFromFoundPeripherals:peripheral]]) {
        WGBLEPeripheral *newPeripheral = [[WGBLEPeripheral alloc] initWithPeripheral:peripheral
                                                                   advertisementData:advertisementData
                                                                                RSSI:RSSI];
        [self.foundPeripherals addObject:newPeripheral];
        
        if (self.onScanNewPeripheral) {
            self.onScanNewPeripheral(peripheral);
        }
    }
}

@end
