//
//  WGBLECentralManager+Delegate.h
//  RmFM
//
//  Created by Eduoduo on 15/3/6.
//  Copyright (c) 2015年 Eduoduo. All rights reserved.
//

#import "WGBLECentralManager.h"

@interface WGBLECentralManager(Delegate)
<
CBCentralManagerDelegate
>
/**
 *  设置 CBCentralManagerDelegate，实现 必要的协议
 */
- (void)setupCentralManagerDelegate;
@end
