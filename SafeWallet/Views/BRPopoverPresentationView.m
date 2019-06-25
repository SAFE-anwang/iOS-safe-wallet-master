//
//  BRPopoverPresentationView.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/6/5.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRPopoverPresentationView.h"
#import "BRCommonDataModel.h"
#import "BRPutCandyModel.h"

@interface BRPopoverPresentationView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,assign) BRPopoverPresentationViewType popType;

@property (nonatomic,strong) UIButton *backButton;

@end

@implementation BRPopoverPresentationView

- (UITableView *)tableView {
    if(_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.layer.masksToBounds = YES;
        _tableView.layer.cornerRadius = 5;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (void)setDataSoure:(NSArray *)dataSoure {
    _dataSoure = dataSoure;
    [self.tableView reloadData];
}

- (void)setSelectModel:(BRCommonDataModel *)selectModel {
    _selectModel = selectModel;
    if (selectModel) {
        if ([_dataSoure containsObject:selectModel]) {
            NSInteger index = [_dataSoure indexOfObject:selectModel];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:false scrollPosition:(UITableViewScrollPositionMiddle)];
        }
    }
}

- (void)setSelectCandy:(BRPutCandyModel *)selectCandy {
    _selectCandy = selectCandy;
    if (selectCandy) {
        if ([_dataSoure containsObject:selectCandy]) {
            NSInteger index = [_dataSoure indexOfObject:selectCandy];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:false scrollPosition:(UITableViewScrollPositionMiddle)];
        }
    }
}

#pragma mark - 弹出此弹窗
/** 弹出此弹窗 */
- (void)show{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    self.tableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN,  CGFLOAT_MIN);
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:5.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.tableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    } completion:^(BOOL finished) {
        self.tableView.transform = CGAffineTransformIdentity;
    }];
}

- (void)dismiss{
//    [UIView animateWithDuration:0.1 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:5.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        self.tableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.05, 1.05);
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:0.3
//                         animations:^{
//                             self.tableView.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.001, 0.001);
//                         }
//                         completion:^(BOOL finished) {
//                             [self removeFromSuperview];
//                         }];
//    }];
    [self removeFromSuperview];
}

- (void) setUpUI {
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor clearColor];
    
    self.backButton = [[UIButton alloc] initWithFrame:self.frame];
    self.backButton.backgroundColor = [UIColor blackColor];
    self.backButton.alpha = 0.3;
    [self.backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.backButton];
}

- (instancetype)initWithShowRegion:(CGSize)size type:(BRPopoverPresentationViewType) type {
    
    if (self = [super init]) {
        [self setUpUI];
        self.tableView.frame = CGRectMake((SCREEN_WIDTH - size.width) * 0.5, (SCREEN_HEIGHT - size.height) * 0.5 - 50, size.width, size.height);
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.popType = type;
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)backButtonClicked{
    [self dismiss];
}

#pragma mark - UITableViewDelegate UITableViewDataSoure
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSoure.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellName = @"cellPopoverPresentation";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.selectedTextColor = MAIN_COLOR;
        cell.selectedBackgroundView = [UIView new];
    }
    if(self.popType == BRPopoverPresentationViewTypePublishAsset) {
        BRCommonDataModel *commonDataModel = self.dataSoure[indexPath.row];
        cell.textLabel.text = commonDataModel.assetName;
    } else if(self.popType == BRPopoverPresentationViewTypePutCandy) {
        BRPutCandyModel *putCandyModel = self.dataSoure[indexPath.row];
        cell.textLabel.text = putCandyModel.assetName;
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if([self.delegate respondsToSelector:@selector(popoverPresentationViewForIndexPath:)]) {
        [self.delegate popoverPresentationViewForIndexPath:indexPath.row];
    }
    
    [self dismiss];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (void)dealloc {
    BRLogFunc;
}

@end
