//
//  CoreDateHelper.h
//  CampbellApp
//
//  Created by Ernesto Sánchez Kuri on 29/03/15.
//  Copyright (c) 2015 marquam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MCModels.h"

typedef void (^SavedContexSuccess)(id success);
typedef void (^SavedContextError)(NSString *errorString, NSDictionary *errorDict);
@interface CoreDataHelper : NSObject<NSXMLParserDelegate>
{
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    
}
@property (nonatomic, retain) NSArray *itemsInDB;
@property (nonatomic, readonly) NSManagedObjectContext       *importContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly) NSPersistentStore            *store;
@property (nonatomic, strong) NSXMLParser *parser;

+(CoreDataHelper *)sharedModelHelper;
- (void)setupCoreData;
-(NSArray *)getInfoForItem:(NSString *)itemName;
- (id)singleInstanceOf:(NSString *)entityName where:(NSString *)condition isEqualTo:(id)value;

- (NSArray *)allInstancesOf:(NSString *)entityName
                      where:(NSArray *)conditions
                  isEqualto:(NSArray*)values
                  orderedBy:(NSString *)property;
-(NSString *)applicationDocumentsDirectory;
- (void)importFromXML:(NSURL*)url;
//-(void)importFromServer:(id)parameters withSuccess:(SavedContexSuccess)importSuccess orError:(SavedContextError)importError;
/*-(void)getDestinationsAndProductsFromServer:(id)parameters
                                withSuccess:(SavedContexSuccess)importSuccess
                                    orError:(SavedContextError)importError;*/
/*-(void)getTicketsFromServer:(id)parameters
                withSuccess:(SavedContexSuccess)importSuccess
                    orError:(SavedContextError)importError;*/
//-(void)saveTicketToDB:(NSDictionary *)ticket withSuccess:(SavedContexSuccess)importSuccess orError:(SavedContextError)importError;
/*-(void)importRangesFromLoads:(id)parameters withSuccess:(SavedContexSuccess)importSuccess orError:(SavedContextError)importError;
-(void)getAllDestinationsAndProductsFromServer:(id)parameters withSuccess:(SavedContexSuccess)importSuccess orError:(SavedContextError)importError;*/
//Delegate Methods

// -----------Category------------//
-(void)setNewCategory:(NSDictionary *)params withSuccess:(SavedContexSuccess)success orError:(SavedContextError)saveError;
-(void)updateExistingCategory:(NSDictionary *)dict withSuccess:(SavedContexSuccess)success onError:(SavedContextError)saveError;
-(NSArray *)savedCategoriesOnDB;
// -----------Product------------//
-(void)setNewProduct:(NSDictionary *)params withSuccess:(SavedContexSuccess)success orError:(SavedContextError)saveError;
-(void)updateExistingProduct:(NSDictionary *)dict withSuccess:(SavedContexSuccess)success onError:(SavedContextError)saveError;
-(NSArray *)savedProductsOnDBForCategory: (NSString *)category;
// -----------Cliente------------//
-(void)setNewClient:(NSDictionary *)params withSuccess:(SavedContexSuccess)success orError:(SavedContextError)saveError;
-(void)updateExistingClient:(NSDictionary *)dict withSuccess:(SavedContexSuccess)success onError:(SavedContextError)saveError;
-(NSArray *)savedClients;
// -----------Pedido------------//
-(void)setNewPedido:(NSDictionary *)params withSuccess:(SavedContexSuccess)success orError:(SavedContextError)saveError;
-(void)updateExistingPedido:(NSDictionary *)dict withSuccess:(SavedContexSuccess)success onError:(SavedContextError)saveError;
-(NSArray *)savedPedidoCliente: (NSString *)cliente;
-(NSArray *)savedPedidosTotales;



@end
