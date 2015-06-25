//
//  PedidosRegistrarViewController.h
//  MagiClean
//
//  Created by Ernesto Sánchez Kuri on 18/06/15.
//  Copyright (c) 2015 Sankurlabs. All rights reserved.
//

#import "BaseViewController.h"
#import "MCModels.h"

@import MapKit;
@interface PedidosRegistrarViewController : BaseViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnCategoria;
@property (weak, nonatomic) IBOutlet UIButton *btnProducto;
@property (weak, nonatomic) IBOutlet UITextField *txtCantidad;
@property (weak, nonatomic) IBOutlet UIStepper *stepperCantidad;
@property (weak, nonatomic) IBOutlet UILabel *lblTotal;
@property (weak, nonatomic) IBOutlet UIButton *btnStatus;
@property (weak, nonatomic) IBOutlet UIView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *btnCLiente;
@property (weak, nonatomic) IBOutlet UIButton *btnFechaPedido;
@property (weak, nonatomic) IBOutlet UIButton *btnFechaEntrega;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) Pedido *currentPedido;
@property (nonatomic) BOOL willRegister;
@end
