//
//  CustomDatePickerViewController.h
//  ChevroletApp
//
//  Created by Ernesto Sánchez Kuri on 04/03/15.
//  Copyright (c) 2015 SK Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomPicker.h"

@protocol MyCVDatePickerDelegate;

@interface CustomDatePickerViewController : UIViewController<CustomPicker, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic) CGFloat pickerHeight;
@property (weak, nonatomic) id<MyCVDatePickerDelegate> delegate;
@property (strong, nonatomic) id pickerTag;
@property (weak, nonatomic) IBOutlet UIDatePicker *pickerView;
@property (weak, nonatomic) IBOutlet UIView *fadeView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnCancel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnDone;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *flexSpace;
@property (nonatomic) NSDate *selectedDate;
@property (nonatomic) BOOL shouldGetDate;

- (id)initWithDelegate:(id<MyCVDatePickerDelegate>)delegate;
- (void)showInViewController:(UIViewController *)parentVC;
@end

@protocol MyCVDatePickerDelegate <NSObject>

- (void)pickerWasCancelled:(CustomDatePickerViewController *)picker;
- (void)picker:(CustomDatePickerViewController *)picker pickedDate:(NSDate *)date;

@end