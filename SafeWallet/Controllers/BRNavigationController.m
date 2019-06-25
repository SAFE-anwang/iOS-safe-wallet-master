//
//  BRNavigationController.m
//  dashwallet
//
//  Created by joker on 2018/6/28.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRNavigationController.h"
#import "UIImage+Color.h"

@interface BRNavigationController () <UIGestureRecognizerDelegate>

@end

@implementation BRNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.navigationBar.translucent = false;
    self.interactivePopGestureRecognizer.delegate = self;
    [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,[UIFont systemFontOfSize:20 weight:UIFontWeightBold], NSFontAttributeName,nil]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.childViewControllers.count > 0) {
        CGFloat height = 40;
        CGFloat width = 50;
        BOOL iphoneSE = SCREEN_HEIGHT <= 568.0;
        if(iphoneSE) {
            height = 36;
            width = 45;
        }
        UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, width, height)]; // 50， 40
        UIImage *img = [[UIImage imageNamed:@"navi_back"] renderingColor:[UIColor whiteColor]];
        [backButton setImage:img forState:(UIControlStateNormal)];
        [backButton setImage:img forState:(UIControlStateHighlighted)];
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        [UIFont systemFontOfSize:15 weight:(UIFontWeightLight)];
        spaceItem.width = -18;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 11.0) {

            backButton.contentEdgeInsets = UIEdgeInsetsMake(0, -15,0, 0);
            backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15,0, 0);
        }
        
        [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        viewController.navigationItem.leftBarButtonItems = @[spaceItem, backItem];
        viewController.hidesBottomBarWhenPushed = YES;
    }
    
    
    [super pushViewController:viewController animated:animated];
}

- (void)back {
    [self popViewControllerAnimated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return self.childViewControllers.count > 1;
}

@end
