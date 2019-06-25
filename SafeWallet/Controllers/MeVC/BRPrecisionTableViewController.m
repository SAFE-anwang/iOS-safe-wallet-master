//
//  BRPrecisionTableViewController.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/7/26.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRPrecisionTableViewController.h"
#import "BRPrecisionCell.h"

@interface BRPrecisionTableViewController ()

@property (nonatomic,strong) NSArray *dataSource;

@end

@implementation BRPrecisionTableViewController

- (NSArray *)dataSource {
    if(_dataSource == nil) {
        _dataSource = @[NSLocalizedString(@"SAFE,8 decimal places", nil), NSLocalizedString(@"SAFE,6 decimal places", nil), NSLocalizedString(@"SAFE,4 decimal places", nil), NSLocalizedString(@"mSAFE,2 decimal places", nil), NSLocalizedString(@"μSAFE,no decimal places", nil)];
        
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Denomination and precision", nil);
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellName = @"BRPrecisionCell";
    BRPrecisionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(cell == nil) {
        cell = [[BRPrecisionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = self.dataSource[indexPath.row];
    if([[[NSUserDefaults standardUserDefaults] objectForKey:BRPrecision_Name] isEqual:[NSString stringWithFormat:@"%ld", indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        if(![[NSUserDefaults standardUserDefaults] objectForKey:BRPrecision_Name] && indexPath.row == 2) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", indexPath.row] forKey:BRPrecision_Name];
    [self.tableView reloadData];
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 49;
}




@end
