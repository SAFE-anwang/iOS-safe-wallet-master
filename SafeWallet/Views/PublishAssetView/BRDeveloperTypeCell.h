//
//  BRDeveloperTypeCell.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/8.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRLabel.h"

//@protocol BRDeveloperTypeCellDelegate <NSObject>
//
//@optional
//
//- (void) developerTypeCellLoadTypeView;
//
//@end

@interface BRDeveloperTypeCell : UITableViewCell

//@property (nonatomic, weak) id<BRDeveloperTypeCellDelegate> delegate;

@property (nonatomic, strong) BRLabel *title;

@property (nonatomic, strong) UILabel *name;

@end
