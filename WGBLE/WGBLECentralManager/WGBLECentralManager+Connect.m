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
- (void)connect:(WGBLEPeripheral *)peripheral Completed:(PeripheralConnectResult )result{
    if (!self.centralManagerEnable) {
        NSLog(@"ERROR: centralManager powered off or not usefull");
        return;
    }
    //检测   peripheral为非连接状态，才可连接
    if (peripheral.connectState!=kBLEConnectState_DisConnect) {
        [self disConnect:peripheral];
    }
//    else{
////        WGLogValue(@"warning : connect not implement,cause peripheral is in connectState = %@",@(peripheral.connectState),nil);
//        result(NO,peripheral,[NSError errorWithDomain:@"ConnectError" code:-1 userInfo:@{@"desc":@"peripheral已连接，不可重复连接"}]);
//
//    }
    
    [self.centralManager connectPeripheral:peripheral.peripheral
                                   options:@{
                                             CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                             CBCentralManagerRestoredStatePeripheralsKey:@YES
                                             }];
    self->_onPeripheralConnectResult = [result copy];

}
- (void)disConnect:(WGBLEPeripheral *)peripheral{

    if (peripheral.connectState==kBLEConnectState_Connected ||
        peripheral.connectState==kBLEConnectState_Connecting) {
        [self.centralManager cancelPeripheralConnection:peripheral.peripheral];
    }else{
        NSLog(@"warning : disConnect not implement,cause peripheral is not in connecting or connected");
    }
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"%s", __FUNCTION__);
    
    WGBLEPeripheral *wgPeripheral = [self wgPeripheralFromFoundPeripherals:peripheral];
    if (!wgPeripheral) {
        NSLog(@"error：scan数组中未查找到对应连接成功的peripheral，此处由于断开的是非控制下的peripheral，将忽略、断开peripheral");
        [self.centralManager cancelPeripheralConnection:peripheral];
        
    }else if ([self.connectingPeriperals containsObject:wgPeripheral]){
        NSLog(@"error：连接成功的peripheral已存在，无法重复记录在connectingPeripherals数组中，可能是由于直接断开蓝牙再重连导致的检测不到peripheral的disConnect回调，但不影响BLE连接");
        
        if (self.onPeripheralConnectResult) {
            self.onPeripheralConnectResult(YES,wgPeripheral,nil);
        }

    }else{
        //临时存储
        //MARK: DEBUG检测，此成功回调中，获取CBPeripheral.state是否对应
#if DEBUG
        if (peripheral.state!=CBPeripheralStateConnected) {
            assert(@"成功回调，但是state!=CBPeripheralStateConnected");
        }
#endif
        [self.connectingPeriperals addObject:wgPeripheral];
        
        if (self.onPeripheralConnectResult) {
            self.onPeripheralConnectResult(YES,wgPeripheral,nil);
        }
    }
}
- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
    
    if (self.onPeripheralConnectResult) {
        self.onPeripheralConnectResult(NO,[self wgPeripheralFromFoundPeripherals:peripheral],[NSError errorWithDomain:@"ConnectError" code:-1 userInfo:@{@"desc":@"连接失败"}]);
    }
    
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
    
    //断开连接，将connectingPeripherals中移除对应的WGBLEPeripheral
    WGBLEPeripheral *wgPeripheral = [self wgPeripheralFromConnectedPeripherals:peripheral];
    if (!wgPeripheral) {
        NSLog(@"warning:将要移除的wgPeripheral不存在,此处由于断开的是非控制下的peripheral，将忽略、不返回断开回调");
    }else{
        //MARK: DEBUG检测，此断开成功回调中，获取CBPeripheral.state是否对应
#if DEBUG
        if (peripheral.state!=CBPeripheralStateDisconnected) {
            assert(@"成功回调，但是state!=CBPeripheralStateDisconnected");
        }
#endif
        
        //移除
        [self.connectingPeriperals removeObject:wgPeripheral];
        if (self.onPeripheralDisConnectResult) {
            self.onPeripheralDisConnectResult(YES,wgPeripheral,nil);
        }
    }
    
}

@end
