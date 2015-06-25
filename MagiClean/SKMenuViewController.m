//
//  CAMenuViewController.m
//  CampbellApp
//
//  Created by Ernesto Sánchez Kuri on 18/03/15.
//  Copyright (c) 2015 marquam. All rights reserved.
//

#import "SKMenuViewController.h"
#define WIDTH_OPENED (100.f)
#define MIN_SCALE_CONTROLLER (0.85f)
#define MIN_SCALE_TABLEVIEW (0.8f)
#define MIN_ALPHA_TABLEVIEW (0.001f)
#define DELTA_OPENING (65.f)
#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad
@interface SKMenuViewController ()<UITableViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, assign) CGPoint startLocation;
@property (nonatomic, assign) CGPoint lastLocation;
@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, assign) CGFloat widthOpened;
@property (nonatomic, assign) CGFloat minScaleController;
@property (nonatomic, assign) CGFloat minScaleTableView;
@property (nonatomic, assign) CGFloat minAlphaTableView;
@property (nonatomic, strong) NSArray *menuItems;

@end

@implementation SKMenuViewController

+(instancetype)sharedMenu
{
    static  SKMenuViewController *controller = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [[SKMenuViewController alloc]init];
    });
    return controller;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self.menuDelegate respondsToSelector:@selector(tableViewForMenu:)]) {
        self.tableView = [self.menuDelegate tableViewForMenu:self];
        self.tableView.delegate = self;
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.widthOpened = self.view.frame.size.width / 1.8;
        self.minAlphaTableView = MIN_ALPHA_TABLEVIEW;
        self.minScaleController = 0.9f;
        self.minScaleTableView = 0.9f;
    }else{
        self.widthOpened = self.view.frame.size.width / 2.3;
        self.minAlphaTableView = MIN_ALPHA_TABLEVIEW;
        self.minScaleController = MIN_SCALE_CONTROLLER;
        self.minScaleTableView = MIN_SCALE_TABLEVIEW;
    }
    
    
    
    if ([self.menuDelegate respondsToSelector:@selector(widthControllerForMenu:)]) {
        self.widthOpened = [self.menuDelegate widthControllerForMenu:self];
    }
    if ([self.menuDelegate respondsToSelector:@selector(minScaleForMenu:)]) {
        self.minScaleController = [self.menuDelegate minScaleForMenu:self];
    }
    if ([self.menuDelegate respondsToSelector:@selector(minScaleTableForMenu:)]) {
        self.minScaleTableView = [self.menuDelegate minScaleTableForMenu:self];
    }
    if ([self.menuDelegate respondsToSelector:@selector(minAlphaTableForMenu:)]) {
        self.minAlphaTableView = [self.menuDelegate minAlphaTableForMenu:self];
    }
    
    _isMenuOpened = FALSE;
    [self openViewControllerAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UIWindow *frontWindow = [[UIApplication sharedApplication] keyWindow];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGesture:)];
    panGesture.delegate = self;
    [frontWindow addGestureRecognizer:panGesture];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if(self.isMenuOpened)
        [self closeMenuAnimated];
}

#pragma mark - Gestures

-(void)panGesture:(UIPanGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.startLocation = [sender locationInView:self.view];
    }else if (sender.state == UIGestureRecognizerStateEnded
              &&(self.isMenuOpened
                 || (self.startLocation.x < DELTA_OPENING && !self.isMenuOnRight)
                 || (self.startLocation.x > self.currentViewController.view.frame.size.width - DELTA_OPENING && self.isMenuOnRight))){
                  CGFloat dx = self.lastLocation.x - self.startLocation.x;
                  if (self.isMenuOnRight)
                  {
                      if ((self.isMenuOpened && dx > 0.f) || self.view.frame.origin.x > 3*self.view.frame.size.width / 4)
                          [self closeMenuAnimated];
                      else
                          [self openMenuAnimated];
                  }
                  else
                  {
                      if ((self.isMenuOpened && dx < 0.f) || self.view.frame.origin.x < self.view.frame.size.width / 4){
                          [self closeMenuAnimated];
                         
                      }else{
                          [self openMenuAnimated];
                      }
                  }
              }else if (sender.state == UIGestureRecognizerStateChanged
                        && (self.isMenuOpened
                            || ((self.startLocation.x < DELTA_OPENING && !self.isMenuOnRight)
                                || (self.startLocation.x > self.currentViewController.view.frame.size.width -DELTA_OPENING && self.isMenuOnRight))))
                  [self menuDragging:sender];
    
    
    
}
-(void)menuDragging:(UIPanGestureRecognizer *)sender
{
    CGPoint stopLocation = [sender locationInView:self.view];
    self.lastLocation = stopLocation;
    
    CGFloat dx = stopLocation.x - self.startLocation.x;
    
    CGFloat distance = dx;
    
    CGFloat width = (self.isMenuOnRight) ? (-self.view.frame.size.width + self.widthOpened) : (self.view.frame.size.width - self.widthOpened);
    
    
    CGFloat scaleController = 1 - ((self.view.frame.origin.x / width) * (1-self.minScaleController));
    
    CGFloat scaleTableView = 1 - ((1 - self.minScaleTableView) + ((self.view.frame.origin.x / width) * (-1+self.minScaleTableView)));
    
    CGFloat alphaTableView = 1 - ((1 - self.minAlphaTableView) + ((self.view.frame.origin.x / width) * (-1+self.minAlphaTableView)));
    
    
    if (scaleTableView < self.minScaleTableView)
        scaleTableView = self.minScaleTableView;
    
    if (scaleController > 1.f)
        scaleController = 1.f;
    
    self.tableView.transform = CGAffineTransformMakeScale(scaleTableView, scaleTableView);
    
    self.tableView.alpha = alphaTableView;
    
    self.currentViewController.view.transform = CGAffineTransformMakeScale(scaleController, scaleController);
    
    CGRect frame = self.view.frame;
    frame.origin.x = frame.origin.x + distance;
    
    if (self.isMenuOnRight)
    {
        if (frame.origin.x < -frame.size.width)
            frame.origin.x = -frame.size.width;
        if (frame.origin.x > 0.f)
            frame.origin.x = 0.f;
    }
    else
    {
        if (frame.origin.x < 0.f)
            frame.origin.x = 0.f;
        if (frame.origin.x > (frame.size.width))
            frame.origin.x = (frame.size.width);
    }
    
    self.view.frame = frame;
    
    frame = self.currentViewController.view.frame;
    if (self.isMenuOnRight){
        frame.origin.x = self.view.frame.size.width - frame.size.width;
    }else{
        frame.origin.x = 0.f;
    }
    self.currentViewController.view.frame = frame;
}


- (void)openViewControllerAtIndexPath:(NSIndexPath*)indexPath
{
    if ([self.menuDelegate respondsToSelector:@selector(menu:viewControllerAtIndexpath:)])
    {
        BOOL firstTime = FALSE;
        if (self.currentViewController == nil)
            firstTime = TRUE;
        
        _currentViewController = [self.menuDelegate menu:self viewControllerAtIndexpath:indexPath];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeMenuAnimated)];
        tapGesture.delegate = self;
        [self.currentViewController.view addGestureRecognizer:tapGesture];
        
        CGRect frame = self.view.frame;
        frame.origin.x = 0.f;
        frame.origin.y = 0.f;
        self.currentViewController.view.frame = frame;
        
        frame = self.view.frame;
        frame.origin.x = 0.f;
        frame.origin.y = 0.f;
        self.view.frame = frame;
        
        self.currentViewController.view.autoresizesSubviews = TRUE;
        self.currentViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        [self.view addSubview:self.currentViewController.view];
        [self addChildViewController:self.currentViewController];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        [self.view addGestureRecognizer:panGesture];
        
        //if (!firstTime)
            //[self openingAnimation];
    }
    
}

-(void)openingAnimation
{
    self.currentViewController.view.transform = CGAffineTransformMakeScale(self.minScaleController, self.minScaleController);
    
    CGRect frame = self.view.frame;
    if (self.isMenuOnRight)
        frame.origin.x = -frame.size.width + self.widthOpened;
    else
        frame.origin.x = frame.size.width - self.widthOpened;
    self.view.frame = frame;
    
    self.tableView.alpha = 1.f;
    
    self.tableView.transform = CGAffineTransformMakeScale(1.f, 1.f);
    
    frame = self.currentViewController.view.frame;
    if (self.isMenuOnRight)
        frame.origin.x = self.view.frame.size.width - frame.size.width;
    else
        frame.origin.x = 0.f;
    
    self.currentViewController.view.frame = frame;
    
    [self closeMenuAnimated];
    
}
#pragma mark - Actions

- (void)openMenuAnimated
{
    [UIView animateWithDuration:0.3f animations:^{
        
        self.currentViewController.view.transform = CGAffineTransformMakeScale(self.minScaleController, self.minScaleController);
        
        CGRect frame = self.view.frame;
        
        if (self.isMenuOnRight)
            frame.origin.x = -frame.size.width + self.widthOpened;
        else
            frame.origin.x = frame.size.width - self.widthOpened;
        
        self.view.frame = frame;
        
        self.tableView.alpha = 1.f;
        
        self.tableView.transform = CGAffineTransformMakeScale(1.f, 1.f);
        
        frame = self.currentViewController.view.frame;
        if (self.isMenuOnRight)
            frame.origin.x = self.view.frame.size.width - frame.size.width;
        else
            frame.origin.x = 0.f;
        self.currentViewController.view.frame = frame;
    }];
    
    _isMenuOpened = TRUE;
}

- (void)closeMenuAnimated
{
    [UIView animateWithDuration:0.3f animations:^{
        
        self.currentViewController.view.transform = CGAffineTransformMakeScale(1.f, 1.f);
        
        CGRect frame = self.view.frame;
        frame.origin.x = 0.f;
        self.view.frame = frame;
        
        self.tableView.alpha = self.minAlphaTableView;
        
        self.tableView.transform = CGAffineTransformMakeScale(self.minScaleTableView, self.minScaleTableView);
        
        frame = self.currentViewController.view.frame;
        frame.origin.x = 0.f;
        self.currentViewController.view.frame = frame;
    }];
    
    _isMenuOpened = FALSE;
}

-(void)reloadMenuAfterRegister
{
    [self.tableView reloadData];
}



#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.currentViewController.view removeFromSuperview];
    [self.currentViewController removeFromParentViewController];
    [self openViewControllerAtIndexPath:indexPath];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.view.frame.size.height < 500) {
        return 100.0f;
    }
    return 150.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectNull];
    UIImageView *profileImageView = [[UIImageView alloc]initWithFrame:CGRectMake(30, 10, 114, 114)];
    if (self.view.frame.size.height < 500) {
        [profileImageView setFrame:CGRectMake(30, 0, 100, 100)];
    }
    [profileImageView setImage:[UIImage imageNamed:@"logo"]];
    [profileImageView.layer setCornerRadius:profileImageView.frame.size.height / 2];
    [profileImageView.layer setMasksToBounds:YES];
    [profileImageView setContentMode:UIViewContentModeScaleAspectFill];
    [headerView addSubview:profileImageView];
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}



#pragma mark - Setters

- (void)setIsMenuOnRight:(BOOL)isMenuOnRight
{
    if (self.view.superview == nil)
        _isMenuOnRight = isMenuOnRight;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view.superview.superview isMemberOfClass:[UITableViewCell class]] || [touch.view isMemberOfClass:[UIButton class]] || [touch.view isMemberOfClass:[UINavigationBar class]] || [touch.view.class isSubclassOfClass:[UIToolbar class]] || [touch.view.superview isMemberOfClass:[UITableViewCell class]] || [touch.view.superview isMemberOfClass:[UIToolbar class]]) {
        return NO;
    }
    
    
    return YES;
}

@end
