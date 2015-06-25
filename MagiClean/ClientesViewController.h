//
//  ClientesViewController.h
//  MagiClean
//
//  Created by Ernesto Sánchez Kuri on 03/06/15.
//  Copyright (c) 2015 Sankurlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ClientesViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UITableView *tblClientes;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnAdd;

@end
