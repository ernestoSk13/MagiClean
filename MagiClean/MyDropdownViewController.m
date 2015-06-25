//
//  ViewController.m
//  MagiClean
//
//  Created by Ernesto Sánchez Kuri on 02/06/15.
//  Copyright (c) 2015 Sankurlabs. All rights reserved.
//

#import "MyDropdownViewController.h"
#import "AppDelegate.h"
#import "HomeViewController.h"
#import "InventarioViewController.h"
#import "ClientesViewController.h"
#import "VentasViewController.h"
#import "AppDelegate.h"
#import "SKUtilities.h"


@interface MyDropdownViewController ()<SKMenuDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) AppDelegate *appDelegate;
@end

@implementation MyDropdownViewController
-(void)awakeFromNib
{
    [super awakeFromNib];
    
}
-(void)initialSetup
{
    [[SKUtilities sharedInstance]setViewControllerObject:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.menuItems = @[@"Home", @"Inventario", @"Clientes", @"Ventas"];
    self.menuController  = [SKMenuViewController sharedMenu];
    self.menuController.menuDelegate = self;
    //[self captureBlur];
    [self.view addSubview:self.menuController.view];
    [self addChildViewController:self.menuController];

    // Do any additional setup after loading the view, typically from a nib.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TableViewSegue"]) {
        self.tableView = ((UITableViewController *)segue.destinationViewController).tableView;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
    }
}

-(void)captureBlur
{
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *currentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //Blur
    CIImage *imageToBlur = [CIImage imageWithCGImage:currentImage.CGImage];
    CIFilter *gaussianBlur = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBlur setValue:imageToBlur forKey:@"inputImage"];
    CIImage *outputImage = [gaussianBlur valueForKey:@"outputImage"];
    
    UIImage *blurredI = [[UIImage alloc]initWithCIImage:outputImage];
    
    UIImageView *newView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    newView.image = blurredI;
    [self.view insertSubview:newView belowSubview:self.view];
    
}

#pragma mark - Menu Delegate


-(UIViewController *)menu:(SKMenuViewController *)menu viewControllerAtIndexpath:(NSIndexPath *)indexpath
{
    UIStoryboard *storyboard = self.storyboard;
    UIViewController *vc = nil;
    
    vc.view.autoresizesSubviews = YES;
    vc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    switch (indexpath.row) {
        case 0:
            vc = [storyboard instantiateViewControllerWithIdentifier:@"homeVC"];
            break;
        case 1:
            vc = [storyboard instantiateViewControllerWithIdentifier:@"inventarioVC"];
            // ((CAOpentTicketsViewController *)vc).comesFromMenu = YES;
            break;
        case 2:
            vc = [storyboard instantiateViewControllerWithIdentifier:@"clientesVC"];
            break;
        case 3:
            vc = [storyboard instantiateViewControllerWithIdentifier:@"ventasVC"];
            break;
        default:
            break;
    }
    return vc;
}
-(UITableView *)tableViewForMenu:(SKMenuViewController *)menu
{
    return self.tableView;
}
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

#pragma mark -TableView DataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.view.frame.size.height < 500) {
        return 30;
    }
    return 44.0f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.menuItems count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
    UITableViewCell *cell;
    
    CellIdentifier = @"ItemCell";
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:CellIdentifier];
    }
    
    
    // Configure the cell...
    cell.backgroundColor = [UIColor darkGrayColor];
    [cell.contentView setBackgroundColor:[UIColor darkGrayColor]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.textLabel setText:self.menuItems[indexPath.row]];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 150.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
