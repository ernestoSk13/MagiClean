//
//  Pedido.h
//  MagiClean
//
//  Created by Ernesto Sánchez Kuri on 17/06/15.
//  Copyright (c) 2015 Sankurlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Cliente, Producto;

@interface Pedido : NSManagedObject

@property (nonatomic, retain) NSString * idPedido;
@property (nonatomic, retain) NSString * cantidadPedido;
@property (nonatomic, retain) NSString * precioTotal;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * fechaPedido;
@property (nonatomic, retain) NSString * fechaEntrega;
@property (nonatomic, retain) Producto *productoPedido;
@property (nonatomic, retain) Cliente *pedidoCliente;

@end
