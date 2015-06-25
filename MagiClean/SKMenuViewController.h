//
//  CAMenuViewController.h
//  CampbellApp
//
//  Created by Ernesto Sánchez Kuri on 18/03/15.
//  Copyright (c) 2015 marquam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SKMenuViewController;

@protocol SKMenuDelegate <NSObject>
@required

-(UITableView *)tableViewForMenu: (SKMenuViewController *)menu;
-(UIViewController *)menu:(SKMenuViewController *)menu viewControllerAtIndexpath:(NSIndexPath *)indexpath;

@optional

-(CGFloat)widthControllerForMenu:(SKMenuViewController *)menu;
-(CGFloat)minScaleForMenu:(SKMenuViewController *)menu;
-(CGFloat)minScaleTableForMenu:(SKMenuViewController *)menu;
-(CGFloat)minAlphaTableForMenu:(SKMenuViewController *)menu;

@end

@interface SKMenuViewController : UIViewController
@property  (nonatomic, readonly, strong) UIViewController *currentViewController;
@property  (nonatomic, weak)   id<SKMenuDelegate> menuDelegate;
@property (nonatomic, assign,readonly) BOOL isMenuOpened;
@property  (nonatomic, assign) BOOL isMenuOnRight;
+(instancetype)sharedMenu;
-(void)openMenuAnimated;
-(void)closeMenuAnimated;
-(void)reloadMenuAfterRegister;
@property (nonatomic, strong)UIImage *logoImage;
@end
