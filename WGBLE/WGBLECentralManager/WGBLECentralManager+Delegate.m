//
//  WGBLECentralManager+Initializer.m
//  RmFM
//
//  Created by RayMi on 15/3/6.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "WGBLECentralManager+Delegate.h"
#import "WGBLECentralManager+Connect.h"

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
        
        //蓝牙关闭，清空已记录的BLE
        [self.connectingPeriperals removeAllObjects];
        [self.foundPeripherals removeAllObjects];
        
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
//    WGLogFormatMsg(@"%s，%@，功能未集成", __FUNCTION__,peripheral);
//}
//
//- (void)centralManager:(CBCentralManager *)central
//  didConnectPeripheral:(CBPeripheral *)peripheral {
//    WGLogFormatMsg(@"%s，%@，功能未集成", __FUNCTION__,peripheral);
//}
//
//- (void)centralManager:(CBCentralManager *)central
//didFailToConnectPeripheral:(CBPeripheral *)peripheral
//                 error:(NSError *)error {
//    WGLogFormatMsg(@"%s，%@，功能未集成", __FUNCTION__,peripheral);
//}
//
//- (void)centralManager:(CBCentralManager *)central
//didDisconnectPeripheral:(CBPeripheral *)peripheral
//                 error:(NSError *)error {
//    WGLogFormatMsg(@"%s，%@，功能未集成", __FUNCTION__,peripheral);
//}

@end
