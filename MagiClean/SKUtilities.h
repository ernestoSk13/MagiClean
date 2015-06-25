//
//  SKUtilities.h
//  MagiClean
//
//  Created by Ernesto Sánchez Kuri on 04/06/15.
//  Copyright (c) 2015 Sankurlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKMenuViewController.h"
#import "MyDropdownViewController.h"
@interface SKUtilities : NSObject
+(id)sharedInstance;
@property(nonatomic, strong)MyDropdownViewController *viewControllerObject;
@end
