//
//  ViewController.m
//  RmFM
//
//  Created by 峰 on 15/3/3.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "WGBLECentralManager.h"
#import "WGBLECentralManager+Delegate.h"
#import "WGBLECentralManager+Scan.h"
#import "WGBLECentralManager+Connect.h"

@interface ViewController ()
<
UITableViewDataSource,UITableViewDelegate
>
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (nonatomic,strong) NSMutableArray *results;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _results = [NSMutableArray array];
    
    typeof(self) __weak weakSelf = self;

    [WGBLECentralManager sharedCentralManager].centralManagerOnChangeState = ^(CBCentralManagerState state){

    };
    
    
    [WGBLECentralManager sharedCentralManager].onScanNewPeripheral = ^(CBPeripheral *new){
        NSLog(@"scan:%@",new);
        weakSelf.results = [NSMutableArray arrayWithArray:[WGBLECentralManager sharedCentralManager].foundPeripherals];
        [weakSelf.table reloadData];
    };
    
}

- (IBAction)start:(id)sender {
    [[WGBLECentralManager sharedCentralManager] scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FFF0"]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @NO }];
}
- (IBAction)endScna:(id)sender {
    [[WGBLECentralManager sharedCentralManager] stopScan];
}

#pragma mark - UITableView
- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
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
    WGBLEPeripheral *wgPeripheral = _results[indexPath.row];
    
    [[WGBLECentralManager sharedCentralManager]connect:wgPeripheral
                                             Completed:^(BOOL success, WGBLEPeripheral *peripheral,NSError *error) {
                                                 if (success) {
                                                     //连接peripheral成功，检索service
                                                     [peripheral discoverServicesWithUUIDStrings:@[@"FFF0"]];
                                                     
                                                     //
                                                     
                                                     typeof(peripheral) __weak ww = peripheral;
                                                     peripheral.onDidDiscoverService = ^(CBService *service){
                                                         NSLog(@"检测到service:%@",service.UUID.UUIDString);
                                                                                                                  
                                                         [ww discoverCharacteristicsWithUUIDStrings:@[@"FFF1"] WithService:service];
                                                     };
                                                     
                                                     peripheral.onDidDiscoverCharacteristic = ^(CBService *service,CBCharacteristic *characteristic){
                                                         NSLog(@"检测到characteristic:%@",characteristic.UUID.UUIDString);
//                                                         [ww.peripheral readValueForCharacteristic:characteristic];
                                                         [ww addNotifyCharacteristic:characteristic WithNotifyEnable:YES];
                                                         [ww.peripheral readRSSI];
                                                         //equal to
                                                         //[ww.peripheral setNotifyValue:YES forCharacteristic:characteristic];
                                                     };
                                                     
                                                     peripheral.onUpdateValueForCharacteristic = ^(CBCharacteristic *characteristic){
                                                         NSLog(@"接收到值：%@",hexadecimalStringWithData(characteristic.value));
                                                     };
                                                     
                                                 }else{
                                                     NSLog(@"连接CBPeripheral失败：%@",error.userInfo[@"desc"]);

                                                 }
                                             }];
    
}

@end
