//
//  Cliente.h
//  MagiClean
//
//  Created by Ernesto Sánchez Kuri on 17/06/15.
//  Copyright (c) 2015 Sankurlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Pedido.h"

@class NSManagedObject;

@interface Cliente : NSManagedObject

@property (nonatomic, retain) NSString * nombreCliente;
@property (nonatomic, retain) NSString * apellidoCliente;
@property (nonatomic, retain) NSString * telefonoCliente;
@property (nonatomic, retain) NSString * correoCliente;
@property (nonatomic, retain) NSString * direccionCliente;
@property (nonatomic, retain) NSString * calleNumero;
@property (nonatomic, retain) NSString * idCliente;
@property (nonatomic, retain) NSSet *clientePedido;
@end

@interface Cliente (CoreDataGeneratedAccessors)

- (void)addClientePedidoObject:(Pedido *)value;
- (void)removeClientePedidoObject:(Pedido *)value;
- (void)addClientePedido:(NSSet *)values;
- (void)removeClientePedido:(NSSet *)values;

@end
