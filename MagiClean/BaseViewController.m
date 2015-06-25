//
//  BaseViewController.m
//  MagiClean
//
//  Created by Ernesto Sánchez Kuri on 02/06/15.
//  Copyright (c) 2015 Sankurlabs. All rights reserved.
//

#import "BaseViewController.h"
#import "UIColor+customProperties.h"

@interface BaseViewController ()
@property (nonatomic) BOOL hasScrollView;
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark -TextField Delegate Methods
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    [textField becomeFirstResponder];
    // Move the main window frame to make room for the keyboard.
    UIScrollView *scrollView;
    if ([textField.superview isKindOfClass:[UIScrollView class]]) {
        scrollView = (UIScrollView *)textField.superview;
        self.hasScrollView = YES;
    }
    CGFloat extraSpace = 0;
    CGRect textFieldFrame;
    textFieldFrame = textField.frame;
    if (textField.tag == 9999) {
        extraSpace = 80;
    }if (textField.tag == 888 || textField.tag == 777 || textField.tag == 666) {
        
        textFieldFrame.origin.y += 238;
    }
    
    BOOL hasNextTxt = NO;
    UITextField *view =(UITextField *)[self.view viewWithTag:textField.tag + 1];
    if (!view){
        hasNextTxt = NO;
    }else{
        hasNextTxt = YES;
    }
    
    CGRect currentFrame = self.view.frame;
    
    
    if ((textFieldFrame.origin.y + textFieldFrame.size.height) + 20 >  (self.view.frame.size.height / 2)) {
        
        
        currentFrame.origin.y = (self.view.frame.size.height / 2 - (textFieldFrame.origin.y + textFieldFrame.size.height)) - 40 - extraSpace;
        if (!hasNextTxt) {
            //currentFrame.origin.y = -(textFieldFrame.origin.y + textFieldFrame.size.height - (self.view.frame.size.height - textFieldFrame.origin.y));
        }
        
        
        // Animate the frame change.
        [UIView animateWithDuration:0.6
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             if (self.view.frame.size.height > 500 && self.view.frame.size.height < 1000) {
                                 NSLog(@"Here 1");
                                 if (self.hasScrollView) {
                                     [scrollView setContentOffset:CGPointMake(0, -currentFrame.origin.y) animated:YES];
                                 }else{
                                     self.view.frame = currentFrame;
                                 }
                             } else if(self.view.frame.size.height > 1000){
                                 NSLog(@"Here 2");
                             }else{
                                 if (self.hasScrollView) {
                                     [scrollView setContentOffset:CGPointMake(0, -currentFrame.origin.y) animated:YES];
                                 }else{
                                     self.view.frame = currentFrame;
                                 }
                                 NSLog(@"Here 3");
                             }
                             
                             
                         }
                         completion:^(BOOL finished) {
                         }
         ];
        
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}




-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL hasNextTxt = NO;
    UITextField *view =(UITextField *)[self.view viewWithTag:textField.tag + 1];
    if (!view){
        [textField resignFirstResponder];
    }else{
        hasNextTxt = YES;
        [view becomeFirstResponder];
    }
    UIScrollView *scrollView;
    if ([textField.superview isKindOfClass:[UIScrollView class]]) {
        scrollView = (UIScrollView *)textField.superview;
        self.hasScrollView = YES;
    }
    //[textField resignFirstResponder];
    [UIView animateWithDuration:0.6
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         if (!hasNextTxt) {
                             if (self.hasScrollView) {
                                 [scrollView setContentOffset:CGPointMake(0, -50)];
                             }else{
                                 self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                             }
                         }
                     }
                     completion:^(BOOL finished) {
                     }
     
     ];
    return YES;
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
