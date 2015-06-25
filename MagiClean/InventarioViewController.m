//
//  InventarioViewController.m
//  MagiClean
//
//  Created by Ernesto Sánchez Kuri on 02/06/15.
//  Copyright (c) 2015 Sankurlabs. All rights reserved.
//

#import "InventarioViewController.h"
#import "RegistrarCategoriaViewController.h"
#import "ListaProductoViewController.h"
#import "UIImage+customProperties.h"

@interface InventarioViewController ()
@property (nonatomic) NSArray *productArray;
@property (nonatomic) NSString *categoryID;
@property (nonatomic, strong) Categorias *currentCategory;
@end

@implementation InventarioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.productArray = [[NSMutableArray alloc] init];
    //[self fillProducts];
    self.productArray = [[NSArray alloc] init];
    self.btnAdd.target = self;
    self.btnAdd.action = @selector(insertNewProduct);
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    self.productArray = [cdh savedCategoriesOnDB];
    
     [self.tblInventario reloadData];
    
}


-(void)fillProducts
{
    NSDictionary *productOne = @{
                                 @"productId" : @"1",
                                 @"productName" : @"Jabon líquido",
                                 @"productImage" : [UIImage imageNamed:@"jabonManos"]
                                 };
    NSDictionary *productTwo = @{
                                 @"productId" : @"2",
                                 @"productName" : @"Jabon neutro",
                                 @"productImage" : [UIImage imageNamed:@"jabonNeutro"]
                                 };
    NSDictionary *productThree = @{
                                 @"productId" : @"3",
                                 @"productName" : @"Detergente",
                                 @"productImage" : [UIImage imageNamed:@"detergente"]
                                 };
 //   [self.productArray addObjectsFromArray:@[productOne, productTwo, productThree]];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)insertNewProduct
{
    NSLog(@"Insert new product category");
    [self performSegueWithIdentifier:@"registerSegue" sender:self];
    
    
}


#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.productArray.count == 0) {
        return 1;
    }
    return self.productArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 105.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier;
    UITableViewCell* cell;
    if ([self.productArray count]>0) {
        cellIdentifier = @"productCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        UIImageView *theImage = (UIImageView *)[cell viewWithTag:1001];
        UILabel *lblTitle = (UILabel *)[cell viewWithTag:1003];
        Categorias *categoria = [self.productArray objectAtIndex:indexPath.row];
        
        
        UIImage *productImage = [UIImage loadImageFromDocumentDirectory:categoria.imagenCategoria];
        productImage = [UIImage imageWithImage:productImage scaledToNewSize:CGSizeMake(theImage.frame.size.width, theImage.frame.size.height)];
        productImage = [UIImage imageWithRoundCorner:productImage andCornerSize:CGSizeMake(theImage.frame.size.width * 0.5, theImage.frame.size.height * 0.5)];
        [theImage setImage:productImage];
        [theImage.layer setCornerRadius:theImage.frame.size.height / 2];
        [lblTitle setText:categoria.nombreCategoria];
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
    self.currentCategory = [self.productArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"categorySegue" sender:self];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"registerSegue"]) {
        UINavigationController *navController = [segue destinationViewController];
        RegistrarCategoriaViewController *rvc = (RegistrarCategoriaViewController *)[navController viewControllers][0];
        rvc.registerType = @"categoría";
        rvc.ivc = self;
    }else if ([segue.identifier isEqualToString:@"categorySegue"]){
        UINavigationController *navController = [segue destinationViewController];
        ListaProductoViewController *lvc = (ListaProductoViewController *)[navController viewControllers][0];
        lvc.categoryID = self.currentCategory.idCategoria;
        [lvc setTitle:self.currentCategory.nombreCategoria];
        
    }
}


@end
