//
//  ProductoDetallesViewController.h
//  MagiClean
//
//  Created by Ernesto Sánchez Kuri on 08/06/15.
//  Copyright (c) 2015 Sankurlabs. All rights reserved.
//

#import "BaseViewController.h"

@interface ProductoDetallesViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imgProducto;
@property (weak, nonatomic) IBOutlet UITextField *txtCantidad;
@property (weak, nonatomic) IBOutlet UITextField *txtNotas;
@property (weak, nonatomic) IBOutlet UITextField *txtProveedor;
@property (weak, nonatomic) IBOutlet UITextField *txtProducto;
@property (weak, nonatomic) IBOutlet UITextField *txtBarcode;
@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property (weak, nonatomic) IBOutlet UITextField *txtPrecioCompra;
@property (weak, nonatomic) IBOutlet UITextField *txtPrecioVenta;
@property (weak, nonatomic) IBOutlet UITextField *txtCategoria;

@property (nonatomic, strong) Producto *productoActual;



@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnGuardar;

@end
