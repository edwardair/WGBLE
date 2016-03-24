//
//  WGBLECentralManager+Initializer.m
//  RmFM
//
//  Created by RayMi on 15/3/6.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "WGBLECentralManager+Connect.h"
#import "WGBLECentralManager+Delegate.h"
#import "WGBLECentralManager+Scan.h"

@implementation WGBLECentralManager (Delegate)

- (void)setupCentralManagerDelegate {
    self.centralManager.delegate = self;
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"%s", __FUNCTION__);
    
    if (central.state == CBCentralManagerStatePoweredOn) {
        self->_centralManagerEnable = YES;
    } else {
        self->_centralManagerEnable = NO;
        
        //蓝牙不可用，断开已连接的CBPeripherals
        for (WGBLEPeripheral *wgPeripheral in self.connectingPeriperals) {
            [self disConnect:wgPeripheral];
        }
        //清空已搜索到的BLE
        [self.foundPeripherals removeAllObjects];
        
        [self stopScan];
    }
    
    if (self.centralManagerOnChangeState) {
        self.centralManagerOnChangeState(central.state);
    }
}

- (void)centralManager:(CBCentralManager *)central
      willRestoreState:(NSDictionary *)dict {
    NSLog(@"%s，功能未集成", __FUNCTION__);
}

- (void)centralManager:(CBCentralManager *)central
didRetrievePeripherals:(NSArray *)peripherals {
    NSLog(@"%s，功能未集成", __FUNCTION__);
}

- (void)centralManager:(CBCentralManager *)central
didRetrieveConnectedPeripherals:(NSArray *)peripherals {
    NSLog(@"%s，功能未集成", __FUNCTION__);
}

@end
