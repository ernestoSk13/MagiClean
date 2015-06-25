//
//  ListaProductoViewController.h
//  MagiClean
//
//  Created by Ernesto Sánchez Kuri on 04/06/15.
//  Copyright (c) 2015 Sankurlabs. All rights reserved.
//

#import "BaseViewController.h"

@interface ListaProductoViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblProducts;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnAddProduct;
@property (nonatomic) NSString *categoryID;
@end
