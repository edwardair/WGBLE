//
//  WGBLECentralManager+Initializer.m
//  RmFM
//
//  Created by RayMi on 15/3/6.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "WGBLECentralManager+Connect.h"
#import "WGBLEPeripheral.h"

@implementation WGBLECentralManager (Connect)

#pragma mark -
- (void)connect:(WGBLEPeripheral *)peripheral
      Completed:(PeripheralConnectResult)result {
    self->_onPeripheralConnectResult = [result copy];
    
    if (!self.centralManagerEnable) {
        NSLog(@"ERROR: centralManager powered off or not usefull");
        return;
    }
    //检测   peripheral为非连接状态，才可连接
    if (peripheral.connectState != kBLEConnectState_DisConnect) {
        NSLog(@"warning : connect not implement,cause peripheral is in "
              @"connectState = %@",
              @(peripheral.connectState), nil);
        result(NO, peripheral,
               [NSError errorWithDomain:@"ConnectError"
                                   code:-1
                               userInfo:@{
                                          @"desc" : @"peripheral已连接，不可重复连接"
                                          }]);
    } else { //开始连接peripheral
        [self.centralManager
         connectPeripheral:peripheral.peripheral
         options:@{
                   CBConnectPeripheralOptionNotifyOnDisconnectionKey : @YES,
                   CBCentralManagerRestoredStatePeripheralsKey : @YES
                   }];
    }
}
- (void)disConnect:(WGBLEPeripheral *)peripheral {
    if (peripheral.connectState == kBLEConnectState_Connected ||
        peripheral.connectState == kBLEConnectState_Connecting) {
        [self.centralManager cancelPeripheralConnection:peripheral.peripheral];
    } else {
        NSLog(@"warning : disConnect not implement,cause peripheral is not in "
              @"connecting or connected");
    }
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"%@连接成功", peripheral);
    
    WGBLEPeripheral *wgPeripheral =
    [self wgPeripheralFromFoundPeripherals:peripheral];
    if (wgPeripheral) {
        if (![self.connectingPeriperals containsObject:wgPeripheral]) {
            [self.connectingPeriperals addObject:wgPeripheral];
        }
        if (self.onPeripheralConnectResult) {
            self.onPeripheralConnectResult(YES, wgPeripheral, nil);
        }
    } else {
        NSLog(@"warning:%@已连接，但并未包含在foundPeripherals数组中", peripheral);
    }
}
- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    NSLog(@"%@连接失败", peripheral);
    
    WGBLEPeripheral *wgPeripheral =
    [self wgPeripheralFromConnectedPeripherals:peripheral];
    if (wgPeripheral) {
        [self.connectingPeriperals removeObject:wgPeripheral];
    }
    if (self.onPeripheralConnectResult) {
        self.onPeripheralConnectResult(
                                       NO, [self wgPeripheralFromFoundPeripherals:peripheral],
                                       [NSError errorWithDomain:@"ConnectError"
                                                           code:-1
                                                       userInfo:@{
                                                                  @"desc" : @"连接失败"
                                                                  }]);
    }
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    NSLog(@"%@连接已断开", peripheral);
    
    //断开连接，将connectingPeripherals中移除对应的WGBLEPeripheral
    WGBLEPeripheral *wgPeripheral =
    [self wgPeripheralFromConnectedPeripherals:peripheral];
    if (wgPeripheral) {
#if DEBUG
        // MARK: DEBUG检测，此断开成功回调中，获取CBPeripheral.state是否对应
        if (peripheral.state != CBPeripheralStateDisconnected) {
            assert(@"成功回调，但是state!=CBPeripheralStateDisconnected");
        }
#endif
        //移除
        [self.connectingPeriperals removeObject:wgPeripheral];
        if (self.onPeripheralDisConnectResult) {
            self.onPeripheralDisConnectResult(YES, wgPeripheral, nil);
        }
    }
}

@end
