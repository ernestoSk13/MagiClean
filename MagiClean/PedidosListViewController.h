//
//  PedidosListViewController.h
//  MagiClean
//
//  Created by Ernesto Sánchez Kuri on 18/06/15.
//  Copyright (c) 2015 Sankurlabs. All rights reserved.
//

#import "BaseViewController.h"
#import "MCModels.h"

@interface PedidosListViewController : BaseViewController <UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblPedidos;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnAdd;
@property (nonatomic, strong) Cliente *currentClient;
@end
