//
//  ListaProductoViewController.m
//  MagiClean
//
//  Created by Ernesto Sánchez Kuri on 04/06/15.
//  Copyright (c) 2015 Sankurlabs. All rights reserved.
//

#import "ListaProductoViewController.h"
#import "UIImage+customProperties.h"
#import "RegistrarCategoriaViewController.h"
#import "ProductoDetallesViewController.h"

@interface ListaProductoViewController ()
@property (nonatomic) NSArray *productArray;
@property (nonatomic, strong) Producto *selectedProduct;
@end

@implementation ListaProductoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.productArray = [[NSMutableArray alloc]init];
    //[self fillProducts];
    self.btnAddProduct.target = self;
    self.btnAddProduct.action = @selector(addNewProduct);
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    self.productArray = [cdh savedProductsOnDBForCategory:self.categoryID];
    [self.tblProducts reloadData];
}

-(void)addNewProduct
{
    
    [self performSegueWithIdentifier:@"newProductSegue" sender:self];
}


-(void)fillProducts
{
    NSDictionary *productOne = @{
                                 @"productId" : @"1",
                                 @"productName" : @"Jabon líquido 600 ml",
                                 @"productImage" : [UIImage imageNamed:@"jabonManos"],
                                 @"productQuantity": @"5"
                                 };
    NSDictionary *productTwo = @{
                                 @"productId" : @"2",
                                 @"productName" : @"Jabon neutro en barra",
                                 @"productImage" : [UIImage imageNamed:@"jabonNeutro"],
                                 @"productQuantity": @"30"
                                 };
    NSDictionary *productThree = @{
                                   @"productId" : @"3",
                                   @"productName" : @"Detergente 20 lt",
                                   @"productImage" : [UIImage imageNamed:@"detergente"],
                                   @"productQuantity": @"10"
                                   };
  //  [self.productArray addObjectsFromArray:@[productOne, productTwo, productThree]];
    
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.productArray.count > 0) {
       return self.productArray.count;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 165.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* cellIdentifier;
    UITableViewCell* cell;
    if (self.productArray.count > 0) {
        cellIdentifier = @"productCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        UIImageView *imgView = (UIImageView*)[cell viewWithTag:1001];
        UILabel *lblProductTitle = (UILabel *)[cell viewWithTag:1002];
        UILabel *lblProductPrice = (UILabel *)[cell viewWithTag:1003];
        UILabel *lblProductQuantity = (UILabel *)[cell viewWithTag:1004];
        Producto *currentProduct = [self.productArray objectAtIndex:indexPath.row];
        UIImage *productImage = [UIImage loadImageFromDocumentDirectory:currentProduct.imagenProducto];
        productImage = [UIImage imageWithImage:productImage scaledToNewSize:CGSizeMake(imgView.frame.size.width, imgView.frame.size.height)];
        
        [imgView setImage:productImage];
        [lblProductTitle setText:currentProduct.nombreProducto];
        lblProductPrice.text = (currentProduct.precioVenta) ? [NSString stringWithFormat:@"Precio de Venta:\n$ %@",currentProduct.precioVenta] : @"";
        lblProductQuantity.text = (currentProduct.cantidadDisponible) ? [NSString stringWithFormat:@"Cantidad Disponible: %@",currentProduct.cantidadDisponible] : @"Cantidad Disponible: 0";
    }else{
        cellIdentifier = @"noProductCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
    }
    
    return cell;
}



#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.productArray count] > 0) {
        self.selectedProduct = [self.productArray objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"productDetailSegue" sender:self];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"newProductSegue"]) {
        UINavigationController *navController = [segue destinationViewController];
        RegistrarCategoriaViewController *rvc = (RegistrarCategoriaViewController *)[navController viewControllers][0];
        rvc.registerType = @"producto";
        rvc.idCategoria = self.categoryID;
        rvc.lvc = self;
    }else if ([segue.identifier isEqualToString:@"productDetailSegue"]){
        UINavigationController *navController = [segue destinationViewController];
        ProductoDetallesViewController *pvc = (ProductoDetallesViewController *)[navController viewControllers][0];
        pvc.productoActual = self.selectedProduct;
    }
}

@end
