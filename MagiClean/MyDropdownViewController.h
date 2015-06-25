//
//  ViewController.h
//  MagiClean
//
//  Created by Ernesto Sánchez Kuri on 02/06/15.
//  Copyright (c) 2015 Sankurlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKMenuViewController.h"
@import QuartzCore;
@interface MyDropdownViewController : UIViewController<UITableViewDelegate>
@property (nonatomic, strong) SKMenuViewController *menuController;
@property (weak, nonatomic) IBOutlet UIView *blurredView;
@end

