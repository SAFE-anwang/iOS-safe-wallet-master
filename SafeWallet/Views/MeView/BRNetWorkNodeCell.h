//
//  BRNetWorkNodeCell.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/8.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRNetWorkNodeCell : UITableViewCell

@property (nonatomic,strong) UILabel *iPAddress;

@property (nonatomic,strong) UILabel *coinName;

@property (nonatomic,strong) UILabel *protocolName;

@property (nonatomic,strong) UILabel *blockNumber;

@property (nonatomic,strong) UILabel *speed;

@end
