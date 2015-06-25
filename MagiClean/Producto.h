//
//  Producto.h
//  
//
//  Created by Ernesto Sánchez Kuri on 10/06/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Categorias;

@interface Producto : NSManagedObject

@property (nonatomic, retain) NSString * productoID;
@property (nonatomic, retain) NSString * nombreProducto;
@property (nonatomic, retain) NSString * precioVenta;
@property (nonatomic, retain) NSString * precioCompra;
@property (nonatomic, retain) NSString * codigoBarras;
@property (nonatomic, retain) NSString * imagenProducto;
@property (nonatomic, retain) NSString * notasProducto;
@property (nonatomic, retain) NSString * cantidadDisponible;
@property (nonatomic, retain) NSString * proveedorProducto;
@property (nonatomic, retain) Categorias *productoCategoria;

@end
