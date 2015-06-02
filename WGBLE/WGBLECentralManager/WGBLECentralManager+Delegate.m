//
//  WGBLECentralManager+Initializer.m
//  RmFM
//
//  Created by Eduoduo on 15/3/6.
//  Copyright (c) 2015年 Eduoduo. All rights reserved.
//

#import "WGBLECentralManager+Delegate.h"


@implementation WGBLECentralManager (Delegate)

- (void)setupCentralManagerDelegate{
    self.centralManager.delegate = self;
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"%s", __FUNCTION__);
    
    if (central.state==CBCentralManagerStatePoweredOn) {
        self->_centralManagerEnable = YES;
    }else{
        self->_centralManagerEnable = NO;
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

//- (void)centralManager:(CBCentralManager *)central
// didDiscoverPeripheral:(CBPeripheral *)peripheral
//     advertisementData:(NSDictionary *)advertisementData
//                  RSSI:(NSNumber *)RSSI {
//    NSLog(@"%s，功能未集成", __FUNCTION__);
//}

//- (void)centralManager:(CBCentralManager *)central
//  didConnectPeripheral:(CBPeripheral *)peripheral {
//    NSLog(@"%s，功能未集成", __FUNCTION__);
//}

//- (void)centralManager:(CBCentralManager *)central
//didFailToConnectPeripheral:(CBPeripheral *)peripheral
//                 error:(NSError *)error {
//    NSLog(@"%s，功能未集成", __FUNCTION__);
//}
//
//- (void)centralManager:(CBCentralManager *)central
//didDisconnectPeripheral:(CBPeripheral *)peripheral
//                 error:(NSError *)error {
//    NSLog(@"%s，功能未集成", __FUNCTION__);
//}

@end
