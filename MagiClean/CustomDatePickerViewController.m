//
//  CustomDatePickerViewController.m
//  ChevroletApp
//
//  Created by Ernesto Sánchez Kuri on 04/03/15.
//  Copyright (c) 2015 SK Labs. All rights reserved.
//

#import "CustomDatePickerViewController.h"

@interface CustomDatePickerViewController ()
- (void)dismissPickerView;
@property (nonatomic)CGFloat smallWidth;
@property (nonatomic)CGFloat mediumWidth;
@property (nonatomic)CGFloat iPadWidth;
@property (nonatomic)CGFloat iPadLandscape;
@end

@implementation CustomDatePickerViewController
@synthesize fadeView            = _fadeView;

@synthesize delegate            = _delegate;
@synthesize pickerTag           = _pickerTag;
@synthesize pickerHeight        = _pickerHeight;
//@synthesize toolbarLabel        = _toolbarLabel;
@synthesize pickerView          = _pickerView;

- (id)init
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        self = [self initWithNibName:@"CustomDatePickerViewController" bundle:nil];
    }else{
        self = [self initWithNibName:@"CustomDatePickerViewController" bundle:nil];
    }
    return self;
}

- (id)initWithDelegate:(id<MyCVDatePickerDelegate>)delegate
{
    self = [self init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        self.pickerHeight = 460;
    }else{
        self.pickerHeight = 960;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.smallWidth = self.flexSpace.width - 100;
    self.mediumWidth = self.flexSpace.width - 55;
    self.iPadWidth = 648 - 35;
    self.iPadLandscape = 648 + 180;
    self.pickerView.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidUnload
{
    [self setPickerView:nil];
    [self setFadeView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self.delegate pickerWasCancelled:self];
    [self dismissPickerView];
}

- (IBAction)doneButtonPressed:(id)sender {
    [self.delegate picker:self pickedDate:[self.pickerView date]];
    [self dismissPickerView];
}

- (void)dismissPickerView
{
    [UIView animateWithDuration:0.3 delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.frame = CGRectMake(0, self.parentViewController.view.frame.size.height, self.view.frame.size.width, self.pickerHeight);
                     } completion:^(BOOL finished) {
                         [self.view removeFromSuperview];
                         [self removeFromParentViewController];
                     }];
}

- (void)showInViewController:(UIViewController *)parentVC
{
    [self.view setNeedsDisplay];
    self.fadeView.alpha = 0.0;
    [self.view setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.6]];
    self.view.frame = CGRectMake(0, parentVC.view.frame.size.height, self.view.frame.size.width, self.pickerHeight);
//    CGRect framOne = self.view.frame;
    [parentVC addChildViewController:self];
    [parentVC.view addSubview:self.view];
    [UIView animateWithDuration:0.3 delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if (self.parentViewController.view.frame.size.width <= 320) {
                             self.flexSpace.width = self.smallWidth;
                         }else if (self.parentViewController.view.frame.size.width == 375){
                             self.flexSpace.width = self.mediumWidth;
                         }else if (self.parentViewController.view.frame.size.width == 768){
                             self.flexSpace.width = self.iPadWidth;
                         }else if (self.parentViewController.view.frame.size.width >= 1024){
                             self.flexSpace.width = self.iPadLandscape;
                         }
                         self.view.frame = CGRectMake(0, 0,  self.parentViewController.view.frame.size.width, self.parentViewController.view.frame.size.height);
                     } completion:^(BOOL finished) {
                         //[self.pickerView setDate:[NSDate date] animated:YES];
                     }];
//    CGRect frameTwo = self.view.frame;
}



@end

