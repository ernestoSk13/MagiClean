//
//  ClienteDetalleViewController.h
//  MagiClean
//
//  Created by Ernesto Sánchez Kuri on 17/06/15.
//  Copyright (c) 2015 Sankurlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "MCModels.h"

@interface ClienteDetalleViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIImageView *imgCliente;
@property (weak, nonatomic) IBOutlet UITextField *txtNombre;
@property (weak, nonatomic) IBOutlet UITextField *txtTelefono;
@property (weak, nonatomic) IBOutlet UITextField *txtCorreo;
@property (weak, nonatomic) IBOutlet UITextField *txtDireccion;
@property (weak, nonatomic) IBOutlet UITextField *txtCalleNumero;

@property (weak, nonatomic) IBOutlet UIButton *btnPedidos;
@property (weak, nonatomic) IBOutlet UIButton *btnAdeudos;
@property (weak, nonatomic) IBOutlet UIButton *btnLlamar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnGuardar;
@property (nonatomic) BOOL willRegister;

@property (nonatomic, strong) Cliente *selectedClient;
@end
