//
//  ClientesViewController.m
//  MagiClean
//
//  Created by Ernesto Sánchez Kuri on 03/06/15.
//  Copyright (c) 2015 Sankurlabs. All rights reserved.
//

#import "ClientesViewController.h"
#import "ClienteDetalleViewController.h"

@interface ClientesViewController ()
@property (nonatomic) NSArray *clientArray;
@property (nonatomic) BOOL willRegister;
@property (nonatomic, strong) Cliente *selectedClient;
@end

@implementation ClientesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clientArray = [[NSArray alloc]init];
    //[self hardcodedClient];
    // Do any additional setup after loading the view.
    self.btnAdd.target = self;
    self.btnAdd.action = @selector(addClient);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    self.clientArray = [cdh savedClients];
    [self.tblClientes reloadData];
}

/*-(void)hardcodedClient
{
    NSDictionary *cliente = @{
                              @"clientName" : @"Ernesto Sánchez Kuri",
                              @"pedidosActuales": @"5",
                              @"telefono" : @"4491388206",
                              };
    [self.clientArray addObject:cliente];
}*/

-(void)addClient{
    self.willRegister = YES;
    [self performSegueWithIdentifier:@"clientSegue" sender:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.clientArray.count > 0) {
        return self.clientArray.count;
    }
    return 1;
}

/*- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return <#row height#>
}*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier;
    UITableViewCell* cell;
    if (self.clientArray.count > 0) {
        cellIdentifier = @"clientCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        UILabel *lblNombre = (UILabel *)[cell viewWithTag:1001];
        UILabel *lblPedidos = (UILabel *)[cell viewWithTag:1002];
        UILabel *lblTelefono = (UILabel *)[cell viewWithTag:1003];
        
        Cliente *currentClient = [self.clientArray objectAtIndex:indexPath.row];
        [lblNombre setText:[NSString stringWithFormat:@"%@ %@", currentClient.nombreCliente, currentClient.apellidoCliente]];
        [lblPedidos setText:[NSString stringWithFormat:@"Pedidos pendientes: 0"]];
        [lblTelefono setText:[NSString stringWithFormat:@"Teléfono: %@", currentClient.telefonoCliente]];
        
        
    }else{
        cellIdentifier = @"noClientCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
    }
    
    
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.willRegister = NO;
    self.selectedClient = [self.clientArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"clientSegue" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"clientSegue"]) {
         UINavigationController *navController = [segue destinationViewController];
        ClienteDetalleViewController *clientController = (ClienteDetalleViewController *)[navController viewControllers][0];
        clientController.selectedClient = self.selectedClient;
        clientController.willRegister = self.willRegister;
        
    }
}


@end
