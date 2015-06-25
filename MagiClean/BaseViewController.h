//
//  BaseViewController.h
//  MagiClean
//
//  Created by Ernesto Sánchez Kuri on 02/06/15.
//  Copyright (c) 2015 Sankurlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyDropdownViewController.h"
#import "AppDelegate.h"
#import "CoreDataHelper.h"
#import "UIColor+customProperties.h"

@interface BaseViewController : UIViewController <UITextFieldDelegate>
{
    CoreDataHelper *cdh;
    AppDelegate *appDelegate;
}
@end
