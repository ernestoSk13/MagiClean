//
//  HomeViewController.m
//  MagiClean
//
//  Created by Ernesto Sánchez Kuri on 02/06/15.
//  Copyright (c) 2015 Sankurlabs. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.btnMenu.target = self;
   // self.btnMenu.action = @selector(openMenu);
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Customize your menubar programmatically here.
   
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    cdh = [[CoreDataHelper alloc]init];
    self.menuController = [SKMenuViewController sharedMenu];
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
