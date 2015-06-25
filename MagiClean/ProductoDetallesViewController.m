//
//  ProductoDetallesViewController.m
//  MagiClean
//
//  Created by Ernesto Sánchez Kuri on 08/06/15.
//  Copyright (c) 2015 Sankurlabs. All rights reserved.
//

#import "ProductoDetallesViewController.h"
#import "UIImage+customProperties.h"
#import "ListaProductoViewController.h"
#import "MCModels.h"

@interface ProductoDetallesViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic) NSMutableArray *productArray;
@property (nonatomic) UIImage *originalImage;

@end

@implementation ProductoDetallesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.productArray = [[NSMutableArray alloc]init];
    [self fillProducts];
    [self.txtNotas setDelegate:self];
    [self.txtCantidad setDelegate:self];
    [self.txtBarcode setDelegate:self];
    [self.txtProducto setDelegate:self];
    [self.txtCategoria setDelegate:self];
    [self.txtPrecioCompra setDelegate:self];
    [self.txtPrecioVenta setDelegate:self];
    [self.txtProveedor setDelegate:self];
    self.btnGuardar.target = self;
    self.btnGuardar.action = @selector(saveProductInformation);
    cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    [self fillProducts];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

-(void)viewDidLayoutSubviews
{
    _scrollView.scrollEnabled = YES;
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.txtCategoria.frame.origin.y + self.txtCategoria.frame.size.height + 50);
}

-(void)fillProducts
{
   UIImage *productImage = [UIImage loadImageFromDocumentDirectory:self.productoActual.imagenProducto];
    if (productImage) {
        productImage = [UIImage imageWithImage:productImage scaledToNewSize:CGSizeMake(130, 130)];
        
        productImage = [UIImage imageWithRoundCorner:productImage andCornerSize:CGSizeMake(self.imgProducto.frame.size.height * 0.5, self.imgProducto.frame.size.height * 0.5)];
    }
    self.title = @"Producto";
    [self.imgProducto clipsToBounds];
    [self.imgProducto.layer setBorderWidth:2];
    [self.imgProducto.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    [self.imgProducto setImage:productImage];
    [self.imgProducto.layer setCornerRadius:50];
    [self.txtCantidad setText:self.productoActual.cantidadDisponible];
    [self.txtNotas setText:self.productoActual.notasProducto];
    [self.txtProveedor setText:self.productoActual.proveedorProducto];
    [self.txtProducto setText:self.productoActual.nombreProducto];
    [self.txtPrecioCompra setText:self.productoActual.precioCompra];
    [self.txtPrecioVenta setText:self.productoActual.precioVenta];
    [self.txtBarcode setText:self.productoActual.codigoBarras];
    [self.txtCategoria setText:self.productoActual.productoCategoria.nombreCategoria];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showActionSheet)];
    self.imgProducto.userInteractionEnabled = YES;
    [self.imgProducto addGestureRecognizer:tap];
   // [self.productArray addObjectsFromArray:@[productOne]];
}

-(void)saveProductInformation
{
    NSString *stringWithoutSpaces = [self.txtProducto.text
                                     stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    
    NSString *imageName =[NSString stringWithFormat:@"%@.png",stringWithoutSpaces];
    if (self.originalImage) {
       [UIImage saveImageToDocumentsDirectory:self.originalImage withName:imageName];
    }else{
        imageName = @"";
    }
    NSDictionary *productInfo = @{
                                  @"nombreProducto" :(self.txtProducto.text.length > 0) ? self.txtProducto.text : self.productoActual.nombreProducto,
                                  @"cantidadDisponible" : (self.txtCantidad.text.length > 0) ? self.txtCantidad.text : @"0",
                                  @"proveedorProducto" : (self.txtProveedor.text.length > 0) ? self.txtProveedor.text : @"",
                                  @"precioCompra" : (self.txtPrecioCompra.text.length > 0) ? self.txtPrecioCompra.text : @"",
                                  @"precioVenta" : (self.txtPrecioVenta.text.length > 0) ? self.txtPrecioVenta.text : @"",
                                  @"notasProducto": (self.txtNotas.text.length > 0) ? self.txtNotas.text : @"",
                                  @"imagenProducto" : (self.originalImage) ? imageName : @"",
                                  @"productoID" : self.productoActual.productoID,
                                  @"codigoBarras": (self.txtBarcode.text.length > 0) ? self.txtBarcode.text : @""
                                  };
    
    __weak __typeof__(self) weakSelf = self;
    [cdh setNewProduct:productInfo withSuccess:^(id success) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Guardado" message:@"Se ha guardado la información del producto actual" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelOption = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }];
        [alert addAction:cancelOption];
        [weakSelf presentViewController:alert animated:NO completion:nil];
    } orError:^(NSString *errorString, NSDictionary *errorDict) {
        
    }];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showActionSheet
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"¿Qué deseas hacer?" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cameraOption = [UIAlertAction actionWithTitle:@"Tomar foto" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self openFromLibrary:NO];
    }];
    UIAlertAction *galleryOption = [UIAlertAction actionWithTitle:@"Tomar desde galería" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self openFromLibrary:YES];
    }];
    UIAlertAction *cancelOption = [UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    [actionSheet addAction:cameraOption];
    [actionSheet addAction:galleryOption];
    [actionSheet addAction:cancelOption];
    
    
    UIPopoverPresentationController *popover = actionSheet.popoverPresentationController;
    if (popover)
    {
        popover.sourceView = self.imgProducto;
        popover.sourceRect = self.imgProducto.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    
    [self presentViewController:actionSheet animated:YES completion:nil];
    
    
}

-(void)openFromLibrary:(BOOL)library
{
    if (library) {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:nil];
    }else{
        if (![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Este dispositivo no cuenta con una cámara disponible" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelOption = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                
            }];
            [alert addAction:cancelOption];
            [self presentViewController:alert animated:NO completion:nil];
            return;
        }
        
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:nil];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.originalImage = chosenImage;
    chosenImage = [UIImage imageWithImage:chosenImage scaledToSize:CGSizeMake(100, 100)];
    chosenImage = [UIImage imageWithRoundCorner:chosenImage andCornerSize:CGSizeMake(self.imgProducto.frame.size.height * 0.5, self.imgProducto.frame.size.height * 0.5)];
    self.imgProducto.image = chosenImage;
    
    
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
    
    
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
