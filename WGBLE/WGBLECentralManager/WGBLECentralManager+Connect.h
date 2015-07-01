//
//  WGBLECentralManager+Connect.h
//  RmFM
//
//  Created by RayMi on 15/3/6.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "WGBLECentralManager.h"

@class WGBLEPeripheral;

@interface WGBLECentralManager (Connect)

/**
 *  当 peripheral处于 “未连接” 状态，则 connect
 *  else  “连接中”、“已连接” 发出警告
 *
 *  @param peripheral 需要连接的peripheral
 *  @param result     连接成功、失败回调
 */
- (void)connect:(WGBLEPeripheral *)peripheral Completed:(PeripheralConnectResult )result;
/**
 *  当 peripheral处于 “已连接” 状态，则 disConenct
 *  当 peripheral处于 “连接中” 状态，则 cancelConnect
 *  else 发出警告
 *
 *  @param peripheral 需要取消、断开连接的peripheral
 *  成功回调会通过 PeripheralDisConnectResult block返回
 */
- (void)disConnect:(WGBLEPeripheral *)peripheral;

@end
