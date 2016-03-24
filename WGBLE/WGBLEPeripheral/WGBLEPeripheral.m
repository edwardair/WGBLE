//
//  WGBLEPeripheral.m
//  RmFM
//
//  Created by RayMi on 15/3/7.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "WGBLEPeripheral+Discover.h"
#import "WGBLEPeripheral.h"
@interface WGBLEPeripheral ()
/**
 *  nitify enable中的characteristic，方便setNofity=NO
 */
@property(nonatomic, strong) NSMutableArray *notifyEnableCharacteristics;
/**
 *  nitify unEnable中的characteristic，方便setNofity=YES
 */
@property(nonatomic, strong) NSMutableArray *notifyUnEnableCharacteristics;

@end
@implementation WGBLEPeripheral
@synthesize discoveringCharacteristicUUIDStrings =
_discoveringCharacteristicUUIDStrings;

#pragma mark -
- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
    self = [super init];
    if (self) {
        _peripheral = peripheral;
        _notifyEnableCharacteristics = @[].mutableCopy;
        _notifyUnEnableCharacteristics = @[].mutableCopy;
    }
    return self;
}

#pragma mark - setNotify
- (NSArray *)readNotifyEnableCharacteristics {
    return [NSArray arrayWithArray:_notifyEnableCharacteristics];
}
- (NSArray *)readNotifyUnEnableCharacteristics {
    return [NSArray arrayWithArray:_notifyUnEnableCharacteristics];
}

- (BOOL)addNotifyCharacteristic:(CBCharacteristic *)characteristic
               WithNotifyEnable:(BOOL)notifyEnable {
    
    //重复添加的CBCharacteristic，需要将对应的CBCharacteristic从已有数组中移除
    [self removeNotifyCharacteristic:characteristic];
    
    if (notifyEnable) {
        [_notifyEnableCharacteristics addObject:characteristic];
    } else {
        [_notifyUnEnableCharacteristics addObject:characteristic];
    }
    [_peripheral setNotifyValue:notifyEnable forCharacteristic:characteristic];
    
    return YES;
}
- (BOOL)updateNotifyCharacteristic:(CBCharacteristic *)characteristic
                  WithNotifyEnable:(BOOL)notifyEnable {
    CBCharacteristic *c1 =
    isCharacteristicExist(characteristic, _notifyEnableCharacteristics);
    CBCharacteristic *c2 =
    isCharacteristicExist(characteristic, _notifyUnEnableCharacteristics);
    if (c1 && c2) {
        assert(@"error:"
               @"enable及unEnable数组同时存在characteristic，需要检查代码，保证两"
               @"数组中最多只有一个数组包含同一个CBCharacteristic");
    }
    
    if (!c1 && !c2) {
        NSLog(@"error：需要修改的characteristic不存在");
        return NO;
    }
    
    if (notifyEnable) {
        if (c1) {
            NSLog(@"warning:setNofity=YES，但是characteristic已存在，不重复设置");
            return YES;
        } else {
            
            [_notifyEnableCharacteristics addObject:c2];
            [_notifyUnEnableCharacteristics removeObject:c2];
            
            NSLog(@"setNofity=YES 成功");
            return YES;
        }
    } else {
        if (c2) {
            NSLog(@"warning:setNofity=NO，但是characteristic已存在，不重复设置");
            return YES;
        } else {
            
            [_notifyUnEnableCharacteristics addObject:c1];
            [_notifyEnableCharacteristics removeObject:c1];
            
            NSLog(@"setNofity=NO 成功");
            return YES;
        }
    }
}
- (BOOL)removeNotifyCharacteristic:(CBCharacteristic *)characteristic {
    CBCharacteristic *c1 =
    isCharacteristicExist(characteristic, _notifyEnableCharacteristics);
    CBCharacteristic *c2 =
    isCharacteristicExist(characteristic, _notifyUnEnableCharacteristics);
    if (c1 && c2) {
        assert(@"error:"
               @"enable及unEnable数组同时存在characteristic，需要检查代码，保证两"
               @"数组中最多只有一个数组包含同一个CBCharacteristic");
    }
    
    if (!c1 && !c2) {
        NSLog(@"提示:需要移除的CBCharacteristic不存在");
        return NO;
    } else if (c1) {
        [_notifyEnableCharacteristics removeObject:c1];
    } else if (c2) {
        [_notifyUnEnableCharacteristics removeObject:c2];
    }
    
    NSLog(@"成功移除characteristic");
    
    return YES;
}

- (void)enteredBackground {
    for (CBCharacteristic *c in _notifyEnableCharacteristics) {
        [self updateNotifyCharacteristic:c WithNotifyEnable:NO];
    }
}

- (void)enteredForeground {
    for (CBCharacteristic *c in _notifyUnEnableCharacteristics) {
        [self updateNotifyCharacteristic:c WithNotifyEnable:YES];
    }
}

#pragma mark - getter
- (kBLEConnectState)connectState {
    return (kBLEConnectState)_peripheral.state;
}

- (NSMutableDictionary *)discoveringCharacteristicUUIDStrings {
    if (!_discoveringCharacteristicUUIDStrings) {
        _discoveringCharacteristicUUIDStrings = @{}.mutableCopy;
    }
    return _discoveringCharacteristicUUIDStrings;
}

#pragma mark - selector
//查找Service
- (void)discoverServicesWithUUIDStrings:(NSArray *)uuidStrings {
    
    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:uuidStrings.count];
    for (NSString *uuidString in uuidStrings) {
        [tmp addObject:[CBUUID UUIDWithString:uuidString]];
    }
    
    _discoveringServiceUUIDStrings = [NSArray arrayWithArray:tmp];
    
    [self setupPeripheralDelegate];
    [_peripheral discoverServices:tmp];
}
//查找Characteristics
- (void)discoverCharacteristicsWithUUIDStrings:(NSArray *)uuidStrings
                                   WithService:(CBService *)service {
    
    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:uuidStrings.count];
    for (NSString *uuidString in uuidStrings) {
        [tmp addObject:[CBUUID UUIDWithString:uuidString]];
    }
    
    [self.discoveringCharacteristicUUIDStrings
     setObject:[NSArray arrayWithArray:tmp]
     forKey:service.UUID.UUIDString];
    
    [_peripheral discoverCharacteristics:tmp forService:service];
}

//通过UUID获取本地记录的Service
- (CBService *)serviceWithUUIDString:(NSString *)uuidString {
    if (self.connectState != kBLEConnectState_Connected) {
        return nil;
    }
    for (CBService *service in _peripheral.services) {
        if ([service.UUID.UUIDString isEqualToString:uuidString]) {
            return service;
        }
    }
    return nil;
}
//通过UUID获取本地记录的Characteristic
- (CBCharacteristic *)characteristicWithUUIDString:(NSString *)uuidString {
    if (self.connectState != kBLEConnectState_Connected) {
        return nil;
    }
    
    for (CBService *service in _peripheral.services) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID.UUIDString isEqualToString:uuidString]) {
                return characteristic;
            }
        }
    }
    return nil;
}

#pragma mark - read write
- (void)readValueForCharacteristicUUIDString:(NSString *)uuidString {
    [_peripheral
     readValueForCharacteristic:[self
                                 characteristicWithUUIDString:uuidString]];
}
- (void)write:(NSData *)data
ForCharacteristicUUIDString:(NSString *)uuidString
         type:(CBCharacteristicWriteType)type {
    CBCharacteristic *c = [self characteristicWithUUIDString:uuidString];
    
#if TEST | REAL_NONE_MI
    // TODO: 测试环境，直接返回成功
    if (self.onWriteValueForCharacteristic) {
        self.onWriteValueForCharacteristic(c, nil);
    }
    
#else
    if (c) {
        if (c.properties & (CBCharacteristicPropertyWrite |
                            CBCharacteristicPropertyWriteWithoutResponse)) {
            [_peripheral writeValue:data forCharacteristic:c type:type];
        } else {
            NSLog(@"CBCharacteristic "
                  @"不支持CBCharacteristicPropertyWrite或者CBCharacteristicPropertyW"
                  @"riteWithoutResponse");
            if (self.onWriteValueForCharacteristic) {
                self.onWriteValueForCharacteristic(
                                                   c, [NSError errorWithDomain:@"WGBLE"
                                                                          code:-1
                                                                      userInfo:@{
                                                                                 NSURLErrorFailingURLErrorKey :
                                                                                     @"CBCharacteristicWriteType not support"
                                                                                 }]);
            }
        }
        
    } else {
        NSLog(@"CBCharacteristic 不存在，无法write");
        if (self.onWriteValueForCharacteristic) {
            self.onWriteValueForCharacteristic(
                                               c, [NSError errorWithDomain:@"WGBLE"
                                                                      code:-1
                                                                  userInfo:@{
                                                                             NSURLErrorFailingURLErrorKey :
                                                                                 @"CBCharacteristic not exist"
                                                                             }]);
        }
    }
    
#endif
}

@end
