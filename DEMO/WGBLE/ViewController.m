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
@property (nonatomic,assign) BOOL isConnected;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    _results = [NSMutableArray array];
    
    typeof(self) __weak weakSelf = self;

    [WGBLECentralManager sharedCentralManager].centralManagerOnChangeState = ^(CBCentralManagerState state){

    };
    
    
    [WGBLECentralManager sharedCentralManager].onScanNewPeripheral = ^(CBPeripheral *new){
        @synchronized (weakSelf) {
            NSLog(@"MainApp--------scan:%@",new);
            
            if (!self.isConnected) {
                weakSelf.results = [NSMutableArray arrayWithArray:[WGBLECentralManager sharedCentralManager].foundPeripherals];
                [weakSelf.table reloadData];

                [weakSelf connectPeripheral:weakSelf.results.firstObject];
            }
        }
    };
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self start:nil];
//    });
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
                                                         NSLog(@"MainApp----检测到service:%@",service.UUID.UUIDString);
                                                         
                                                         [ww discoverCharacteristicsWithUUIDStrings:@[@"FFF1"] WithService:service];
                                                     };
                                                     
                                                     peripheral.onDidDiscoverCharacteristic = ^(CBService *service,CBCharacteristic *characteristic){
                                                         NSLog(@"MainApp----检测到characteristic:%@",characteristic.UUID.UUIDString);
                                                         //                                                         [ww.peripheral readValueForCharacteristic:characteristic];
                                                         [ww addNotifyCharacteristic:characteristic WithNotifyEnable:YES];
                                                         [ww.peripheral readRSSI];
                                                         //equal to
                                                         //[ww.peripheral setNotifyValue:YES forCharacteristic:characteristic];
                                                     };
                                                     
                                                     peripheral.onUpdateValueForCharacteristic = ^(CBCharacteristic *characteristic){
                                                         NSLog(@"MainApp----接收到值：%@",hexadecimalStringWithData(characteristic.value));
                                                     };
                                                     
                                                 }else{
                                                     UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"连接CBPeripheral失败：%@",error.userInfo[@"desc"]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                                                     [alert show];
                                                 }
                                             }];

}
@end
