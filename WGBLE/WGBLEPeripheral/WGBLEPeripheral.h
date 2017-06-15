//
//  WGBLEPeripheral.h
//  RmFM
//
//  Created by RayMi on 15/3/7.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


static inline NSString *hexadecimalStringWithData(NSData *data) {
    /* Returns hexadecimal string of NSData. Empty string if data is empty.   */
    
    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
    
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger          dataLength  = [data length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return [NSString stringWithString:hexString];
}

/**
 * characteristic是否存在数组中  
 */
static inline CBCharacteristic *isCharacteristicExist(CBCharacteristic *characteristic,NSArray *container){
    NSString *uuidString = characteristic.UUID.UUIDString;
    //TODO: NSFilter过滤提高效率
    for (CBCharacteristic *c in container) {
        if ([uuidString isEqualToString:c.UUID.UUIDString]) {
            return c;
        }
    }
    return nil;
}




typedef NS_ENUM(NSInteger, kBLEConnectState){
    kBLEConnectState_DisConnect=0,//未连接状态
    kBLEConnectState_Connecting,//连接中
    kBLEConnectState_Connected,//已连接
};

typedef void(^DidDiscoverService)(CBService *service);
typedef void(^DidDiscoverCharacteristic)(CBService *service,CBCharacteristic *characteristic);
typedef void(^DidUpdateValueForCharacteristic)(CBCharacteristic *characteristic);
typedef void(^DidWriteValueForCharacteristic)(CBCharacteristic *characteristic,NSError *error);


@interface WGBLEPeripheral : NSObject
@property (nonatomic,readonly) kBLEConnectState connectState;
@property (nonatomic,strong,readonly) CBPeripheral *peripheral;
@property (nonatomic,strong,readonly) NSDictionary *adData;
@property (nonatomic,strong,readonly) NSNumber *RSSI;
//回调
@property (nonatomic,copy) DidDiscoverService onDidDiscoverService;
@property (nonatomic,copy) DidDiscoverCharacteristic onDidDiscoverCharacteristic;
@property (nonatomic,copy) DidUpdateValueForCharacteristic onUpdateValueForCharacteristic;
@property (nonatomic,copy) DidWriteValueForCharacteristic onWriteValueForCharacteristic;

/**
 *  @[NSString *]
 *  peripheral成功连接后，需要查找的service UUIDString，默认为nil，查找所有
 */
@property (nonatomic,strong,readonly) NSArray *discoveringServiceUUIDStrings;
/**
 *  @[NSString *(Characteristic UUID Strings)]
 *  查找到需要的service后，手动继续查找service对应的Characteristics，默认为nil，查找service下所有特征值
 */
@property (nonatomic,strong,readonly) NSMutableDictionary *discoveringCharacteristicUUIDStrings;



- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral;
- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral
                 advertisementData:(NSDictionary *)adData;
- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral
                 advertisementData:(NSDictionary *)adData
                              RSSI:(NSNumber *)RSSI;

/**
 *  peripheral成功连接后，需要手动调用此方法，查找可用service
    注：每次调用此方法，都会重置 _discoveringServiceUUIDStrings为最新传值的数组
 *
 *  @param uuidStrings @[NSString *]，将会保存为 _discoveringServiceUUIDStrings
 */
- (void)discoverServicesWithUUIDStrings:(NSArray *)uuidStrings;
/**
 *  peripheral成功连接后，需要手动调用此方法，查找可用service
    注：每次调用此方法，都会重置 _discoveringCharacteristicUUIDStrings为最新传值的数组
 *
 *  @param uuidStrings @[NSString *(Characteristic UUID Strings)]，将会保存为 _discoveringCharacteristicUUIDStrings
 *  @param service Characteristics所在的service
 */
- (void)discoverCharacteristicsWithUUIDStrings:(NSArray *)uuidStrings WithService:(CBService *)service;

/**
 *  nitify enable中的characteristic
 */
@property (nonatomic,readonly) NSArray *readNotifyEnableCharacteristics;
/**
 *  nitify unEnable中的characteristic
 */
@property (nonatomic,readonly) NSArray *readNotifyUnEnableCharacteristics;
/**
 *  发现Characteristic后，手动添加 临时保存
 *
 *  @param characteristic 需要记录的Characteristic
 *  @param nitifyEnable   启用 notify监听Characteristic的value变化，
    NO：保存在readNotifyUnEnableCharacteristics中，
    YES：保存在readNotifyEnableCharacteristics中
 *
 *  @return YES：需要记录的characteristic不存在于readNotifyEnableCharacteristics、readNotifyUnEnableCharacteristics，保存成功
            NO ：存在，无法添加，可以使用updateNotifyCharacteristic:WithNitifyEnable:修改notify状态
 */
- (BOOL)addNotifyCharacteristic:(CBCharacteristic *)characteristic WithNotifyEnable:(BOOL)notifyEnable;
/**
 *  将查找到的characteristic从 readNotifyEnableCharacteristics、readNotifyUnEnableCharacteristics中移除
 *
 *  @param characteristic characteristic description
 *  @param nitifyEnable   YES/NO
 *
 *  @return YES:设置成功；NO：characteristic不存在于readNotifyUnEnableCharacteristics中，设置失败
 */
- (BOOL)updateNotifyCharacteristic:(CBCharacteristic *)characteristic WithNotifyEnable:(BOOL)notifyEnable;
/**
 *  将查找到的characteristic从 readNotifyEnableCharacteristics、readNotifyUnEnableCharacteristics中移除
 *
 *  @param characteristic
 *
 *  @return YES: 移除成功；NO：characteristic不存在移除失败
 */
- (BOOL)removeNotifyCharacteristic:(CBCharacteristic *)characteristic;

/**
 *  app进入前后台，停止、开启 notify监听蓝牙值变化
 */
- (void)enteredBackground;
- (void)enteredForeground;

/**
 *  通过UUID获取对应的characteristic
 */
- (CBCharacteristic *)characteristicWithUUIDString:(NSString *)uuidString;
/**
 *  读、写操作
 */
- (void)readValueForCharacteristicUUIDString:(NSString *)uuidString;
- (void)write:(NSData *)data
ForCharacteristicUUIDString:(NSString *)uuidString
         type:(CBCharacteristicWriteType)type;

@end
