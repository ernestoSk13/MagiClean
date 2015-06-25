//
//  Categorias.h
//  MagiClean
//
//  Created by Ernesto Sánchez Kuri on 04/06/15.
//  Copyright (c) 2015 Sankurlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Categorias : NSManagedObject

@property (nonatomic, retain) NSString * nombreCategoria;
@property (nonatomic, retain) NSString * imagenCategoria;
@property (nonatomic, retain) NSString * idCategoria;

@end
