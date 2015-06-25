//
//  PedidosListViewController.m
//  MagiClean
//
//  Created by Ernesto Sánchez Kuri on 18/06/15.
//  Copyright (c) 2015 Sankurlabs. All rights reserved.
//

#import "PedidosListViewController.h"
#import "PedidosRegistrarViewController.h"

@interface PedidosListViewController ()
@property (nonatomic) NSArray *pedidosArray;
@property (nonatomic) BOOL willRegister;
@property (nonatomic, strong) Pedido *selectedPedido;
@end

@implementation PedidosListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.btnAdd.target = self;
    self.btnAdd.action = @selector(addPedido);
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    self.pedidosArray = [cdh savedClients];
    [self.tblPedidos reloadData];
}

-(void)addPedido
{
    [self performSegueWithIdentifier:@"registerPedido" sender:self];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

/*- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return <#row height#>
}*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"noPedidoCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    //cell.textLabel.text = @"";
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
