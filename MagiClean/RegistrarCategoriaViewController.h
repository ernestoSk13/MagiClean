//
//  RegistrarCategoriaViewController.h
//  MagiClean
//
//  Created by Ernesto Sánchez Kuri on 04/06/15.
//  Copyright (c) 2015 Sankurlabs. All rights reserved.
//

#import "BaseViewController.h"
#import "InventarioViewController.h"
#import "ListaProductoViewController.h"

@interface RegistrarCategoriaViewController : BaseViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnGuardar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnCancelar;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITextField *txtCategoria;
@property (weak, nonatomic) IBOutlet UITextField *txtCantidad;
@property (weak, nonatomic) IBOutlet UILabel *lblRegisterType;
@property (weak, nonatomic) InventarioViewController *ivc;
@property (weak, nonatomic) ListaProductoViewController *lvc;
@property (nonatomic) NSString *idCategoria;
@property (nonatomic) NSString *registerType;
@end
