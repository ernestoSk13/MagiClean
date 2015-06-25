//
//  ClienteDetalleViewController.m
//  MagiClean
//
//  Created by Ernesto Sánchez Kuri on 17/06/15.
//  Copyright (c) 2015 Sankurlabs. All rights reserved.
//

#import "ClienteDetalleViewController.h"
#import "MCModels.h"

@interface ClienteDetalleViewController ()

@end

@implementation ClienteDetalleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadUI];
    if (!self.willRegister) {
        [self loadData];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    self.btnGuardar.target = self;
    self.btnGuardar.action = @selector(saveClientDetails);
}

-(void)loadUI
{
    self.title = @"Cliente";
    [self.btnPedidos.layer setCornerRadius:10];
    [self.btnAdeudos.layer setCornerRadius:10];
    [self.btnLlamar.layer setCornerRadius:10];
    [self.txtNombre setDelegate:self];
    [self.txtTelefono setDelegate:self];
    [self.txtDireccion setDelegate:self];
    [self.txtCorreo setDelegate:self];
    [self.txtCalleNumero setDelegate:self];
    
}

-(void)loadData
{
    [self.txtNombre setText:[NSString stringWithFormat:@"%@ %@", self.selectedClient.nombreCliente, self.selectedClient.apellidoCliente]];
    [self.txtTelefono setText:self.selectedClient.telefonoCliente];
    [self.txtCorreo setText:self.selectedClient.correoCliente];
    [self.txtDireccion setText:self.selectedClient.direccionCliente];
    [self.txtCalleNumero setText:self.selectedClient.calleNumero];
}

-(NSInteger)randomIDnumber
{
    NSUInteger r = arc4random_uniform(999998) + 1;
    return r;
}

-(void)saveClientDetails
{
    NSArray *myArray = [self.txtNombre.text componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    NSString *nombre = myArray[0];
    NSString *apellido = myArray[1];
    
    NSDictionary *productInfo = @{
                                  @"idCliente" :[NSString stringWithFormat:@"%ld", (long)[self randomIDnumber]],
                                  @"nombreCliente" : (nombre > 0) ? nombre : @"",
                                  @"apellidoCliente" : (apellido > 0) ? apellido : @"",
                                  @"telefonoCliente" : (self.txtTelefono.text.length > 0) ? self.txtTelefono.text : @"",
                                  @"correoCliente" : (self.txtCorreo.text.length > 0) ? self.txtCorreo.text : @"",
                                  @"direccionCliente": (self.txtDireccion.text.length > 0) ? self.txtDireccion.text : @"",
                                  @"calleNumero": (self.txtCalleNumero.text.length > 0) ? self.txtCalleNumero.text : @""
                                  };
    
    __weak __typeof__(self) weakSelf = self;
    [cdh setNewClient:productInfo withSuccess:^(id success) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Guardado" message:@"Se ha guardado la información del cliente actual" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelOption = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }];
        [alert addAction:cancelOption];
        [weakSelf presentViewController:alert animated:NO completion:nil];
    } orError:^(NSString *errorString, NSDictionary *errorDict) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Hubo un error, intenta de nuevo" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelOption = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }];
        [alert addAction:cancelOption];
        [weakSelf presentViewController:alert animated:NO completion:nil];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
