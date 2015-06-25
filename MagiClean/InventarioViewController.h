//
//  InventarioViewController.h
//  MagiClean
//
//  Created by Ernesto Sánchez Kuri on 02/06/15.
//  Copyright (c) 2015 Sankurlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface InventarioViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnAdd;
@property (weak, nonatomic) IBOutlet UITableView *tblInventario;
@end
