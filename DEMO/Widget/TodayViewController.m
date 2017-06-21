//
//  TodayViewController.m
//  Widget
//
//  Created by RayMi on 2017/4/28.
//  Copyright © 2017年 WG. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "WGBLE.h"

@interface TodayViewController ()
<NCWidgetProviding,
UITableViewDataSource,UITableViewDelegate
>
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (nonatomic,strong) NSMutableArray *results;
@property (nonatomic,assign) BOOL isConnected;
@end

@implementation TodayViewController
- (void)dealloc{
    NSLog(@"Widget------------dealloc:%p",self);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Widget----------------Widget Start:%p",self);

#ifdef __IPHONE_10_0
    //如果需要折叠
    self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
#endif
    
    _results = [NSMutableArray array];
    
    typeof(self) __weak weakSelf = self;
    
    [WGBLECentralManager sharedCentralManager].centralManagerOnChangeState = ^(CBCentralManagerState state){
        
    };
    
    
    [WGBLECentralManager sharedCentralManager].onScanNewPeripheral = ^(CBPeripheral *new){
        @synchronized (weakSelf) {
            NSLog(@"Widget----scan:%@",new);
            
            if (!self.isConnected) {
                weakSelf.results = [NSMutableArray arrayWithArray:[WGBLECentralManager sharedCentralManager].foundPeripherals];
                [weakSelf.table reloadData];
                
                [weakSelf connectPeripheral:weakSelf.results.firstObject];
            }
        }
    };
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self start:nil];
    });

    
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    NSLog(@"Widget----------------%s",__FUNCTION__);
//    //获得数据
//    NSString * newValue = [RITL_ShareDataDefaultsManager getData];
//    
//    if ([newValue isEqualToString:self.textLabel.text])//表明没有更新
//    {
//        completionHandler(NCUpdateResultNoData);
//    }
//    else//需要刷新
//    {
//        completionHandler(NCUpdateResultNewData);
//    }
    completionHandler(NCUpdateResultNewData);
}

#ifdef __IPHONE_10_0

// available NS_AVAILABLE_IOS(10_0)
- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize
{
    NSLog(@"Widget----------------%s",__FUNCTION__);

    switch (activeDisplayMode)
    {
            //如果是正常折叠的高度
        case NCWidgetDisplayModeCompact:
        {
            //设置当前的高度
            self.preferredContentSize = maxSize;//宽度会自动变为屏幕的宽度，这里就索性给0了
        }
            break;
            
            //如果是展开的高度
        case NCWidgetDisplayModeExpanded:
        {
            self.preferredContentSize = maxSize;
        }
            break;
    }
}

#else

// 表示当前widget的内嵌边距，如果不设置，那么返回的就是默认的defaultMarginInsets，不过在iOS10以及以后就不会再调用该方法了
// Widgets wishing to customize the default margin insets can return their preferred values.
// Widgets that choose not to implement this method will receive the default margin insets.
// This method will not be called on widgets linked against iOS versions 10.0 and later.
- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets
{
    return UIEdgeInsetsMake(0, 20, 0, 0);//随便写一下
}

#endif

#pragma mark - UITableView
- (IBAction)start:(id)sender {
    [[WGBLECentralManager sharedCentralManager] scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FFF0"]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @NO }];
}
- (IBAction)endScna:(id)sender {
    [[WGBLECentralManager sharedCentralManager] stopScan];
}

#pragma mark - UITableView
- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"Widget----------------%s",__FUNCTION__);

    return _results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *idfer = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idfer];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:idfer];
    }
    
    CBPeripheral *peripheral = [(WGBLEPeripheral *)_results[indexPath.row] peripheral];
    
    cell.textLabel.text = peripheral.name;
    cell.detailTextLabel.text = peripheral.services.description;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WGBLEPeripheral *wgPeripheral = _results[indexPath.row];
    [self connectPeripheral:wgPeripheral];
}
- (void)connectPeripheral:(WGBLEPeripheral *)wgPeripheral{
    
    [[WGBLECentralManager sharedCentralManager]connect:wgPeripheral
                                             Completed:^(BOOL success, WGBLEPeripheral *peripheral,NSError *error) {
                                                 if (success) {
                                                     //连接peripheral成功，检索service
                                                     [peripheral discoverServicesWithUUIDStrings:@[@"FFF0"]];
                                                     
                                                     //
                                                     
                                                     typeof(peripheral) __weak ww = peripheral;
                                                     peripheral.onDidDiscoverService = ^(CBService *service){
                                                         NSLog(@"Widget----检测到service:%@",service.UUID.UUIDString);
                                                         
                                                         [ww discoverCharacteristicsWithUUIDStrings:@[@"FFF1"] WithService:service];
                                                     };
                                                     
                                                     peripheral.onDidDiscoverCharacteristic = ^(CBService *service,CBCharacteristic *characteristic){
                                                         NSLog(@"Widget----检测到characteristic:%@",characteristic.UUID.UUIDString);
                                                         //                                                         [ww.peripheral readValueForCharacteristic:characteristic];
                                                         [ww addNotifyCharacteristic:characteristic WithNotifyEnable:YES];
                                                         [ww.peripheral readRSSI];
                                                         //equal to
                                                         //[ww.peripheral setNotifyValue:YES forCharacteristic:characteristic];
                                                     };
                                                     
                                                     peripheral.onUpdateValueForCharacteristic = ^(CBCharacteristic *characteristic){
                                                         NSLog(@"Widget----接收到值：%@",hexadecimalStringWithData(characteristic.value));
                                                     };
                                                     
                                                 }else{
                                                     UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"连接CBPeripheral失败：%@",error.userInfo[@"desc"]] preferredStyle:UIAlertControllerStyleAlert];
                                                     [self presentViewController:alert animated:YES completion:^{
                                                         
                                                     }];
                                                 }
                                             }];
    
}

@end
