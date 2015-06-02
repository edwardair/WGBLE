//
//  WGBLEPeripheral+Discover.m
//  RmFM
//
//  Created by RayMi on 15/3/7.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "WGBLEPeripheral+Discover.h"

@implementation WGBLEPeripheral (Discover)
- (void)setupPeripheralDelegate{
    self.peripheral.delegate = self;
}

#pragma mark - 检测UUIDString是否包含在数组中
- (BOOL)isUUIDString:(NSString *)uuidString ExistInArray:(NSArray *)array{
    //TODO: 使用NSFilter过滤，提高效率
    for (CBUUID *uuid in array) {
        if ([uuidString isEqualToString:uuid.UUIDString]) {
            return YES;
        }
    }
    return NO;
}


#pragma mark - CBPeripheral delegate
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    NSLog(@"%s，方法未集成",__FUNCTION__);
    
    
}
- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral {
    NSLog(@"%s，方法未集成",__FUNCTION__);
    
}
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices {
    NSLog(@"%s，方法未集成",__FUNCTION__);
    
}
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"%s，方法未集成",__FUNCTION__);
    
}
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    NSLog(@"%s，方法未集成",__FUNCTION__);
    
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    NSLog(@"%s",__FUNCTION__);
    
    if (error){
        NSLog(@"Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
        return;
    }
    
    //TODO: 为提高遍历效率，可是通过NSFilter类，对peripheral.services进行_discoveringServiceUUIDStrings包含过滤
    
    for (CBService *service in peripheral.services){
        //有2种情况，会启用回调，表示查找到需要的service
        //case 1:discoveringServiceUUIDStrings为nil或者count==0，表示查找所有service
        //case 2:discoveringServiceUUIDStrings存在并且count>0，表示仅查找需要的service
        if (self.discoveringServiceUUIDStrings.count==0 ||//case 1
            [self isUUIDString:service.UUID.UUIDString ExistInArray:self.discoveringServiceUUIDStrings]//case 2
            ) {
            if (self.onDidDiscoverService) {
                self.onDidDiscoverService(service);
            }
        }

    }


    
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error{
    NSLog(@"%s，方法未集成",__FUNCTION__);
    
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    NSLog(@"%s",__FUNCTION__);
    
    if (error){
        NSLog(@"Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        return;
    }
    
    //TODO: 为提高遍历效率，可是通过NSFilter进行过滤
    NSArray *characteristicUUIDStrings = self.discoveringCharacteristicUUIDStrings[service.UUID.UUIDString];
    for (CBCharacteristic *characteristic in service.characteristics){
        //有2种情况，会启用回调，表示查找到需要的characteristic
        //case 1:characteristicUUIDStrings为nil或者count==0，表示查找所有characteristic
        //case 2:characteristicUUIDStrings存在并且count>0，表示仅查找需要的characteristic
        if (characteristicUUIDStrings.count==0 ||//case 1
            [self isUUIDString:characteristic.UUID.UUIDString ExistInArray:characteristicUUIDStrings]//case 2
            ) {
            if (self.onDidDiscoverCharacteristic) {
                self.onDidDiscoverCharacteristic(service,characteristic);
            }
        }
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"%s",__FUNCTION__);
    
    
    if (![peripheral isEqual:self.peripheral]) {
        NSLog(@"检测到 其他peripheral的值");
        return ;
    }
    
    if ([error code] != 0) {
        NSLog(@"Error %@\n", error);
        return ;
    }
    
    //TODO: 为提高遍历效率，可是通过NSFilter进行过滤
    //TODO: 测试  此处检测到得CBCharacteristic一定为程序需要的特征值？

    if (self.onUpdateValueForCharacteristic) {
        self.onUpdateValueForCharacteristic(characteristic);
    }
    
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"%s，方法未集成",__FUNCTION__);
    
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    if (error){
        NSLog(@"%@",error);
        
        //遇到错误，将notification移除
        [self updateNotifyCharacteristic:characteristic WithNotifyEnable:NO];
        
        [self removeNotifyCharacteristic:characteristic];
        
    }
    
    NSLog(@"%s，方法未集成",__FUNCTION__);
    
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"%s，方法未集成",__FUNCTION__);
    
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    NSLog(@"%s，方法未集成",__FUNCTION__);
    
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    NSLog(@"%s，方法未集成",__FUNCTION__);
    
}

@end
