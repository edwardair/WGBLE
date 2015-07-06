//
//  WGBLECentralManager.m
//  RmFM
//
//  Created by RayMi on 15/3/6.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "WGBLECentralManager.h"

#import "WGBLECentralManager+Delegate.h"
#import "WGBLECentralManager+Scan.h"
#import "WGBLECentralManager+Connect.h"


static dispatch_queue_t staticQueue;
@implementation WGBLECentralManager
@synthesize foundPeripherals = _foundPeripherals,
            connectingPeriperals = _connectingPeriperals;

+ (void)setQueue:(dispatch_queue_t)queue{
    staticQueue = queue;
}
+ (dispatch_queue_t)queue{
    return staticQueue;
}


+ (instancetype)sharedCentralManager{
    static dispatch_once_t onceToken;
    static WGBLECentralManager *centralManager;
    dispatch_once(&onceToken, ^{
        centralManager = [[WGBLECentralManager alloc]initWithQueue:[self queue]];
    });
    return centralManager;
}
- (id)initWithQueue:(dispatch_queue_t )queue{
    return [self initWithQueue:queue options:nil];
}
- (id )initWithQueue:(dispatch_queue_t)queue options:(NSDictionary *)options{
    self = [super init];
    if (self) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                               queue:queue
                                                             options:options];

        [self setupCentralManagerDelegate];
    }
    return self;
}


#pragma mark - getter

- (NSMutableArray *)foundPeripherals{
    if (!_foundPeripherals) {
        _foundPeripherals = @[].mutableCopy;
    }
    return _foundPeripherals;
}
- (NSMutableArray *)connectingPeriperals{
    if (!_connectingPeriperals) {
        _connectingPeriperals = @[].mutableCopy;
    }
    return _connectingPeriperals;
}
- (BOOL)centralManagerEnable{
    return _centralManagerEnable;
}

#pragma mark - setter
- (void)setCentralManagerOnChangeState:
(CentralManagerOnChangeState)centralManagerOnChangeState {
    if (!centralManagerOnChangeState) {
        _centralManagerOnChangeState = nil;
    } else if (!_centralManagerOnChangeState) {
        _centralManagerOnChangeState = centralManagerOnChangeState;
    } else {
        NSLog(@"error:"
              @"为保证唯一性，多次设置无效，只记录第一次设置，可通过先设置nil，再"
              @"重设");
    }
}


#pragma mark - 
- (WGBLEPeripheral *)wgPeripheralFromFoundPeripherals:(CBPeripheral *)peripheral{
    return [self wgPeripheralFromPeripherals:peripheral inArray:self.foundPeripherals];

}
- (WGBLEPeripheral *)wgPeripheralFromConnectedPeripherals:(CBPeripheral *)peripheral{
    return [self wgPeripheralFromPeripherals:peripheral inArray:self.connectingPeriperals];
}
- (WGBLEPeripheral *)wgPeripheralFromPeripherals:(CBPeripheral *)peripheral inArray:(NSArray *)container{
    NSString *uuidString = peripheral.identifier.UUIDString;
    WGBLEPeripheral *tmp;
    for (WGBLEPeripheral *wgPeripheral in container) {
        if (![wgPeripheral.peripheral.identifier.UUIDString isEqualToString:uuidString]) {
            continue;
        }
        
        tmp = wgPeripheral;
        
        break;
    }
    return tmp;
}



@end
