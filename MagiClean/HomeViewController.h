//
//  HomeViewController.h
//  MagiClean
//
//  Created by Ernesto Sánchez Kuri on 02/06/15.
//  Copyright (c) 2015 Sankurlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "SKMenuViewController.h"

@interface HomeViewController : BaseViewController
@property (nonatomic, strong) SKMenuViewController *menuController;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnMenu;
@end
