//
//  WGBELCentralManager.h
//  RmFM
//
//  Created by RayMi on 15/3/6.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>
#import "WGBLEPeripheral.h"

@class WGBLEPeripheral;

#pragma mark - WGBLE

//********************************************************************************

//MARK: Central Manager State Change Block callback
typedef void(^CentralManagerOnChangeState)(CBCentralManagerState state);

//MARK: scan
typedef NS_ENUM(NSInteger, kBLEScanState){
    kBLEScanState_NotScan,
    kBLEScanState_Scaning,
};
typedef void(^BLEOnScanNewPeripheral)(CBPeripheral *newPeripheral);

//MARK: connect/disconnect peripher
/**
 *  监听  connect、disConnect是否成功
 *  不需要接收回调的可不设置
 *
 *  @param success  成功、失败
 *  @param connect 当前连接状态
 */
typedef void (^PeripheralConnectResult)(BOOL success,WGBLEPeripheral *peripheral, NSError *error);
typedef void (^PeripheralDisConnectResult)(BOOL success,WGBLEPeripheral *peripheral, NSError *error);


//********************************************************************************

@interface WGBLECentralManager : NSObject
{
    @private
    kBLEScanState _scanState;
    PeripheralConnectResult _onPeripheralConnectResult;
    BOOL _centralManagerEnable;
}

#pragma mark - self common properties
@property (nonatomic,strong,readonly) CBCentralManager *centralManager;
/**
 *  BLE是否可用及蓝牙是否开启，BLE支持设备为iPhone4s（含）以上
 */
@property (nonatomic,readonly) BOOL centralManagerEnable;

#pragma mark - Central Manager State Change Block callback
/**
 *  centralManager在改变状态时的回调方法
 *  由于block唯一性，一般在静态方法中设置全局
 *  注：为保证唯一性，多次设置无效，只记录第一次设置，可通过先设置nil，再重设！！
 */
@property (nonatomic,copy) CentralManagerOnChangeState centralManagerOnChangeState;

#pragma mark - Initializer
/**
 *  设置默认的线程，需要在 sharedCentralManager方法前设置，否则默认为nil
 */
+ (void)setQueue:(dispatch_queue_t )queue;
/**
 *  返回当前设置的线程
 */
+ (dispatch_queue_t )queue;

/**
 *  单例，默认初始化
 */
+ (instancetype)sharedCentralManager;
/**
 *  自定义线程初始化Manager
 *  建议使用 sharedCentralManager，特殊情况可以使用此方法额外创建Manager
 *
 *  @param queue 自定义线程
 *
 *  @return WGBLECentralManager
 */
- (id)initWithQueue:(dispatch_queue_t )queue;




#pragma mark - scan
@property (nonatomic,readonly) kBLEScanState scanState;
/**
 *  scan到的 peripheral数组，对象类型为 WGBLEPeripheral class
 */
@property (nonatomic,strong,readonly) NSMutableArray *foundPeripherals;
@property (nonatomic,copy) BLEOnScanNewPeripheral onScanNewPeripheral;



#pragma mark - connect/disconnect peripher
/**
 *  连接中的 peripheral数组，对象类型为 WGBLEPeripheral class
 */
@property (nonatomic,strong,readonly) NSMutableArray *connectingPeriperals;
@property (nonatomic,copy,readonly) PeripheralConnectResult onPeripheralConnectResult;
@property (nonatomic,copy) PeripheralConnectResult onPeripheralDisConnectResult;

/**
 *  根据 CBPeripheral *查找scan数组中的WGBLEPeripheral *对象
 *
 *  @param peripherl CBPeripheral
 *
 *  @return nil if not exist
 */
- (WGBLEPeripheral *)wgPeripheralFromFoundPeripherals:(CBPeripheral *)peripheral;
/**
 *  根据 CBPeripheral *查找已连接数组中的WGBLEPeripheral *对象
 *
 *  @param peripherl CBPeripheral
 *
 *  @return nil if not exist
 */
- (WGBLEPeripheral *)wgPeripheralFromConnectedPeripherals:(CBPeripheral *)peripheral;


@end








