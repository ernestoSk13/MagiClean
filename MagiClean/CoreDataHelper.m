//
//  CoreDateHelper.m
//  CampbellApp
//
//  Created by Ernesto Sánchez Kuri on 29/03/15.
//  Copyright (c) 2015 marquam. All rights reserved.
//

#import "CoreDataHelper.h"
#import <CoreData/CoreData.h>
//#import "CoreDataImporter.h"
#import "MCModels.h"

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define debug 1
static CoreDataHelper *_sharedHelper;


@implementation CoreDataHelper
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - FILES
NSString *storeFilename = @"DataModel.sqlite";

+(CoreDataHelper *)sharedModelHelper
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedHelper = [[self alloc] init];
        
    });
    // returns the same object each time
    return _sharedHelper;
}

#pragma mark - SETUP
- (id)init {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    self = [super init];
    if (!self) {return nil;}
    
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                    initWithManagedObjectModel:_managedObjectModel];
    _managedObjectContext = [self managedObjectContext];//[[NSManagedObjectContext alloc]
          //  initWithConcurrencyType:NSMainQueueConcurrencyType];
   // [_managedObjectContext setPersistentStoreCoordinator:
   //  [self persistentStoreCoordinator]];
    
    
    /*_importContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_importContext performBlockAndWait:^{
        [_importContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
        [_importContext setUndoManager:nil]; // the default on iOS
    }];*/
    return self;
}
- (NSURL *)applicationStoresDirectory {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    NSURL *storesDirectory =
    [[NSURL fileURLWithPath:[self applicationDocumentsDirectory]]
     URLByAppendingPathComponent:@"Stores"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[storesDirectory path]]) {
        NSError *error = nil;
        if ([fileManager createDirectoryAtURL:storesDirectory
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:&error]) {
            if (debug==1) {
                NSLog(@"Successfully created Stores directory");}
        }
        else {NSLog(@"FAILED to create Stores directory: %@", error);}
    }
    return storesDirectory;
}

- (NSURL *)storeURL {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [[self applicationStoresDirectory]
            URLByAppendingPathComponent:storeFilename];
}

- (void)loadStore {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (_store) {return;} // Don’t load store if it’s already loaded
    
    BOOL useMigrationManager = NO;
    if (useMigrationManager &&
        [self isMigrationNecessaryForStore:[self storeURL]]) {
        [self performBackgroundManagedMigrationForStore:[self storeURL]];
    } else {
        NSDictionary *options =
        @{
          NSMigratePersistentStoresAutomaticallyOption:@YES
          ,NSInferMappingModelAutomaticallyOption:@YES
          //,NSSQLitePragmasOption: @{@"journal_mode": @"DELETE"} // Uncomment to disable WAL journal mode
          };
        NSError *error = nil;
        _store = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                            configuration:nil
                                                      URL:[self storeURL]
                                                  options:options
                                                    error:&error];
        if (!_store) {
            NSLog(@"Failed to add store. Error: %@", error);abort();
        }
        else         {NSLog(@"Successfully added store: %@", _store);}
    }
    
}

-(void)setupCoreData
{
    self.itemsInDB = @[@"Categorias",
                       @"Producto"];
    //[self setDefaultDataStoreAsInitialStore];
    [self loadStore];
  //  [self checkIfDefaultDataNeedsImporting];
}

#pragma mark - MIGRATION MANAGER
- (BOOL)isMigrationNecessaryForStore:(NSURL*)storeUrl {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self storeURL].path]) {
        if (debug==1) {NSLog(@"SKIPPED MIGRATION: Source database missing.");}
        return NO;
    }
    NSError *error = nil;
    NSDictionary *sourceMetadata =
    [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                               URL:storeUrl error:&error];
    NSManagedObjectModel *destinationModel = _persistentStoreCoordinator.managedObjectModel;
    if ([destinationModel isConfiguration:nil
              compatibleWithStoreMetadata:sourceMetadata]) {
        if (debug==1) {
            NSLog(@"SKIPPED MIGRATION: Source is already compatible");}
        return NO;
    }
    return YES;
}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:@"migrationProgress"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            float progress =
            [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
            //self.migrationVC.progressView.progress = progress;
            int percentage = progress * 100;
            NSString *string =
            [NSString stringWithFormat:@"Migration Progress: %i%%",
             percentage];
            NSLog(@"%@",string);
          //  self.migrationVC.label.text = string;
        });
    }
}

- (BOOL)replaceStore:(NSURL*)old withStore:(NSURL*)new {
    
    BOOL success = NO;
    NSError *Error = nil;
    if ([[NSFileManager defaultManager]
         removeItemAtURL:old error:&Error]) {
        
        Error = nil;
        if ([[NSFileManager defaultManager]
             moveItemAtURL:new toURL:old error:&Error]) {
            success = YES;
        }
        else {
            if (debug==1) {NSLog(@"FAILED to re-home new store %@", Error);}
        }
    }
    else {
        if (debug==1) {
            NSLog(@"FAILED to remove old store %@: Error:%@", old, Error);
        }
    }
    return success;
}
- (BOOL)migrateStore:(NSURL*)sourceStore {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    BOOL success = NO;
    NSError *error = nil;
    
    // STEP 1 - Gather the Source, Destination and Mapping Model
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator
                                    metadataForPersistentStoreOfType:NSSQLiteStoreType
                                    URL:sourceStore
                                    error:&error];
    
    NSManagedObjectModel *sourceModel =
    [NSManagedObjectModel mergedModelFromBundles:nil
                                forStoreMetadata:sourceMetadata];
    
    NSManagedObjectModel *destinModel = _managedObjectModel;
    
    NSMappingModel *mappingModel =
    [NSMappingModel mappingModelFromBundles:nil
                             forSourceModel:sourceModel
                           destinationModel:destinModel];
    
    // STEP 2 - Perform migration, assuming the mapping model isn't null
    if (mappingModel) {
        NSError *error = nil;
        NSMigrationManager *migrationManager =
        [[NSMigrationManager alloc] initWithSourceModel:sourceModel
                                       destinationModel:destinModel];
        [migrationManager addObserver:self
                           forKeyPath:@"migrationProgress"
                              options:NSKeyValueObservingOptionNew
                              context:NULL];
        
        NSURL *destinStore =
        [[self applicationStoresDirectory]
         URLByAppendingPathComponent:@"Temp.sqlite"];
        
        success =
        [migrationManager migrateStoreFromURL:sourceStore
                                         type:NSSQLiteStoreType options:nil
                             withMappingModel:mappingModel
                             toDestinationURL:destinStore
                              destinationType:NSSQLiteStoreType
                           destinationOptions:nil
                                        error:&error];
        if (success) {
            // STEP 3 - Replace the old store with the new migrated store
            if ([self replaceStore:sourceStore withStore:destinStore]) {
                if (debug==1) {
                    NSLog(@"SUCCESSFULLY MIGRATED %@ to the Current Model",
                          sourceStore.path);}
                [migrationManager removeObserver:self
                                      forKeyPath:@"migrationProgress"];
            }
        }
        else {
            if (debug==1) {NSLog(@"FAILED MIGRATION: %@",error);}
        }
    }
    else {
        if (debug==1) {NSLog(@"FAILED MIGRATION: Mapping Model is null");}
    }
    return YES; // indicates migration has finished, regardless of outcome
}
- (void)performBackgroundManagedMigrationForStore:(NSURL*)storeURL {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    // Show migration progress view preventing the user from using the app
   /* UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.migrationVC =
    [sb instantiateViewControllerWithIdentifier:@"migration"];
    UIApplication *sa = [UIApplication sharedApplication];
    UINavigationController *nc =
    (UINavigationController*)sa.keyWindow.rootViewController;
    [nc presentViewController:self.migrationVC animated:NO completion:nil];*/
    
    // Perform migration in the background, so it doesn't freeze the UI.
    // This way progress can be shown to the user
    dispatch_async(
                   dispatch_get_global_queue(
                                             DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                       BOOL done = [self migrateStore:storeURL];
                       if(done) {
                           // When migration finishes, add the newly migrated store
                           dispatch_async(dispatch_get_main_queue(), ^{
                               NSError *error = nil;
                               _store =
                               [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                          configuration:nil
                                                                    URL:[self storeURL]
                                                                options:nil
                                                                  error:&error];
                               if (!_store) {
                                   NSLog(@"Failed to add a migrated store. Error: %@",
                                         error);abort();}
                               else {
                                   NSLog(@"Successfully added a migrated store: %@",
                                         _store);}
                               //[self.migrationVC dismissViewControllerAnimated:NO
                                                                    //completion:nil];
                               //self.migrationVC = nil;
                           });
                       }
                   });
}

#pragma mark - VALIDATION ERROR HANDLING
- (void)showValidationError:(NSError *)anError {
    
    if (anError && [anError.domain isEqualToString:@"NSCocoaErrorDomain"]) {
        NSArray *errors = nil;  // holds all errors
        NSString *txt = @""; // the error message text of the alert
        
        // Populate array with error(s)
        if (anError.code == NSValidationMultipleErrorsError) {
            errors = [anError.userInfo objectForKey:NSDetailedErrorsKey];
        } else {
            errors = [NSArray arrayWithObject:anError];
        }
        // Display the error(s)
        if (errors && errors.count > 0) {
            // Build error message text based on errors
            for (NSError * error in errors) {
                NSString *entity =
                [[[error.userInfo objectForKey:@"NSValidationErrorObject"]entity]name];
                
                NSString *property =
                [error.userInfo objectForKey:@"NSValidationErrorKey"];
                
                switch (error.code) {
                    case NSValidationRelationshipDeniedDeleteError:
                        txt = [txt stringByAppendingFormat:
                               @"%@ delete was denied because there are associated %@\n(Error Code %li)\n\n", entity, property, (long)error.code];
                        break;
                    case NSValidationRelationshipLacksMinimumCountError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' relationship count is too small (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationRelationshipExceedsMaximumCountError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' relationship count is too large (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationMissingMandatoryPropertyError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' property is missing (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationNumberTooSmallError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' number is too small (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationNumberTooLargeError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' number is too large (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationDateTooSoonError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' date is too soon (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationDateTooLateError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' date is too late (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationInvalidDateError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' date is invalid (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationStringTooLongError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' text is too long (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationStringTooShortError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' text is too short (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationStringPatternMatchingError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' text doesn't match the specified pattern (Code %li).", property, (long)error.code];
                        break;
                    case NSManagedObjectValidationError:
                        txt = [txt stringByAppendingFormat:
                               @"generated validation error (Code %li)", (long)error.code];
                        break;
                        
                    default:
                        txt = [txt stringByAppendingFormat:
                               @"Unhandled error code %li in showValidationError method", (long)error.code];
                        break;
                }
            }
         
        }
    }
}

#pragma mark – DATA IMPORT
- (BOOL)isDefaultDataAlreadyImportedForStoreWithURL:(NSURL*)url
                                             ofType:(NSString*)type {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSError *error;
    NSDictionary *dictionary =
    [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:type
                                                               URL:url
                                                             error:&error];
    if (error) {
        NSLog(@"Error reading persistent store metadata: %@",
              error.localizedDescription);
    }
    else {
        NSNumber *defaultDataAlreadyImported =
        [dictionary valueForKey:@"DefaultDataImported"];
        if (![defaultDataAlreadyImported boolValue]) {
            NSLog(@"Default Data has NOT already been imported");
            return NO;
        }
    }
    if (debug==1) {NSLog(@"Default Data HAS already been imported");}
    return YES;
}
- (void)checkIfDefaultDataNeedsImporting:(NSArray *)parameters {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (![self isDefaultDataAlreadyImportedForStoreWithURL:[self storeURL]
                                                   ofType:NSSQLiteStoreType]) {
       /* [self importFromXML:[[NSBundle mainBundle]
                            URLForResource:@"DefaultData" withExtension:@"xml"]];*/
        
        [self setDefaultDataAsImportedForStore:_store];
       /**/
    }
}
- (void)setDefaultDataAsImportedForStore:(NSPersistentStore*)aStore {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // get metadata dictionary
    NSMutableDictionary *dictionary =
    [NSMutableDictionary dictionaryWithDictionary:[[aStore metadata] copy]];
    
    if (debug==1) {
        NSLog(@"__Store Metadata BEFORE changes__ \n %@", dictionary);
    }
    
    // edit metadata dictionary
    [dictionary setObject:@YES forKey:@"DefaultDataImported"];
    
    // set metadata dictionary
    [self.persistentStoreCoordinator setMetadata:dictionary forPersistentStore:aStore];
    
    if (debug==1) {NSLog(@"__Store Metadata AFTER changes__ \n %@", dictionary);}
}
- (void)setDefaultDataStoreAsInitialStore {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:self.storeURL.path]) {
        NSURL *defaultDataURL =
        [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                pathForResource:@"DefaultData" ofType:@"sqlite"]];
        NSError *error;
        if (![fileManager copyItemAtURL:defaultDataURL
                                  toURL:self.storeURL
                                  error:&error]) {
            NSLog(@"DefaultData.sqlite copy FAIL: %@",
                  error.localizedDescription);
        }
        else {
            NSLog(@"A copy of DefaultData.sqlite was set as the initial store for %@",
                  self.storeURL.path);
        }
    }
}

-(NSArray *)getInfoForItem:(NSString *)itemName
{
    // initializing NSFetchRequest
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //Setting Entity to be Queried
    NSEntityDescription *entity = [NSEntityDescription entityForName:itemName
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError* error;
    
    // Query on managedObjectContext With Generated fetchRequest
    NSArray *fetchedRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // Returning Fetched Records
    return fetchedRecords;
}

- (NSManagedObjectContext *) managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"database.sqlite"]];
    
    NSError *error = nil;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
        // Handle error
    }
    
    return persistentStoreCoordinator;
}
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (id)singleInstanceOf:(NSString *)entityName where:(NSString *)condition isEqualTo:(id)value
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSError *error;
    
    if (![context save:&error])
    {
        NSLog(@"Error: Couldn't fetch: %@", [error localizedDescription]);
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity  = [NSEntityDescription entityForName:entityName
                                               inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // If 'condition' is not nil, limit results to that condition
    if (condition && value)
    {
        NSPredicate *pred;
        if([value isKindOfClass:[NSManagedObject class]])
        {
            value = [((NSManagedObject *)value) objectID];
            pred = [NSPredicate predicateWithFormat:@"(%@ = %@)", condition, value];
        } else if ([value isKindOfClass:[NSString class]])
        {
            NSString *format  = [NSString stringWithFormat:@"%@ LIKE '%@'", condition, value];
            pred = [NSPredicate predicateWithFormat:format];
        } else {
            NSString *format  = [NSString stringWithFormat:@"%@ == %@", condition, value];
            pred = [NSPredicate predicateWithFormat:format];
        }
        [fetchRequest setPredicate:pred];
    }
    [fetchRequest setFetchLimit:1];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest
                                                     error:&error];
    
    return [fetchedObjects count] > 0 ? [fetchedObjects objectAtIndex:0] : nil;
}


- (NSArray *)allInstancesOf:(NSString *)entityName
                      where:(NSArray *)conditions
                  isEqualto:(NSArray*)values
                  orderedBy:(NSString *)property
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    
    NSError *error;
    
    if (![context save:&error])
    {
        NSLog(@"Error: Couldn't fetch: %@", [error localizedDescription]);
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity  = [NSEntityDescription entityForName:entityName
                                               inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // If 'condition' is not nil, limit results to that condition
    if (conditions && values)
    {
        NSPredicate *pred;
        
        NSMutableString *conditionString;
        
        for (int x = 0; x < [conditions count]; x++) {
            id value = values[x];
            if ([value isKindOfClass:[NSNumber class]]) {
                value = [NSString stringWithFormat:@"%@", [value stringValue]];
            }
            NSString *condition = conditions[x];
            if([value isKindOfClass:[NSManagedObject class]])
            {
                value = [((NSManagedObject *)value) objectID];
                if (x > 0) {
                    [conditionString appendString:[NSString stringWithFormat: @" AND %@ = %@", condition, value]];
                }else{
                    conditionString = [[NSMutableString alloc]initWithString:[NSString stringWithFormat: @"AND %@ = %@", condition, value]];
                }
            } else if ([value isKindOfClass:[NSString class]])
            {
                if (x > 0) {
                    [conditionString appendString:[NSString stringWithFormat: @" AND %@ LIKE '%@'", condition, value]];
                    
                }else{
                    conditionString = [[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"%@ LIKE '%@'", condition, value]];
                }
                
            } else {
                if (x > 0) {
                    [conditionString appendString:[NSString stringWithFormat: @" AND %@ == %@", condition, value]];
                }else{
                    conditionString = [[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"%@ == %@", condition, value]];
                }
            }
        }
        NSString *finalStringFormat = [NSString stringWithFormat:@"%@", conditionString];
        
        pred = [NSPredicate predicateWithFormat:finalStringFormat];
        [fetchRequest setPredicate:pred];
        
    }
    
    // If 'property' is not nil, have the results sorted
    if (property)
    {
        NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:property
                                                           ascending:YES];
        
        NSArray *sortDescriptors = [NSArray arrayWithObject:sd];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
    }
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest
                                                     error:&error];
    
    return fetchedObjects;
}


-(void)setNewCategory:(NSDictionary *)params withSuccess:(SavedContexSuccess)success orError:(SavedContextError)saveError
{
    NSArray *oldInfo = [self allInstancesOf:@"Categorias" where:@[@"idCategoria"] isEqualto:@[[params objectForKey:@"idCategoria"]] orderedBy:nil];
    if ([oldInfo count]> 0) {
    //for (Ticket *data in oldInfo) {
        [self updateExistingCategory:params withSuccess:^(id successOne) {
            success(successOne);
        } onError:^(NSString *errorString, NSDictionary *errorDict) {
            saveError(errorString, errorDict);
        }];
       // [self deleteEntity:data];
  //  }
    }else{
    
    
    Categorias *newCategory = [NSEntityDescription insertNewObjectForEntityForName:@"Categorias" inManagedObjectContext:[self managedObjectContext]];
    newCategory.idCategoria = (![[params objectForKey:@"idCategoria"] isKindOfClass:[NSNull class]]) ?  [params objectForKey:@"idCategoria"] : @"";
    newCategory.nombreCategoria = (![[params objectForKey:@"nombreCategoria"] isKindOfClass:[NSNull class]]) ?[params objectForKey:@"nombreCategoria"] : @"";
    newCategory.imagenCategoria = (![[params objectForKey:@"imagenCategoria"] isKindOfClass:[NSNull class]]) ? [params objectForKey:@"imagenCategoria"] : @"";
        [self saveContextWithSuccess:^(NSString *successString) {
            success(newCategory);
        } orError:^(NSString *errorString, NSDictionary *errorDict) {
            saveError(errorString, errorDict);
        }];
    }
}


-(void)updateExistingCategory:(NSDictionary *)dict withSuccess:(SavedContexSuccess)success onError:(SavedContextError)saveError
{
    NSString *existingCategoryId = [dict objectForKey:@"idCategoria"];
    Categorias *currentCategory = [self singleInstanceOf:@"Categorias" where:@"idCategoria" isEqualTo:existingCategoryId];
    if (   ![currentCategory.nombreCategoria isEqualToString:[dict objectForKey:@"nombreCategoria"]]
        || ![currentCategory.imagenCategoria isEqualToString:[dict objectForKey:@"imagenCategoria"]]
        ) {
        if ([(NSString *)[dict objectForKey:@"nombreCategoria"] length] > 0) {
            [currentCategory setValue:[dict objectForKey:@"nombreCategoria"] forKey:@"nombreCategoria"];
        }
        if ([(NSString *)[dict objectForKey:@"imagenCategoria"] length] > 0) {
            [currentCategory setValue:[dict objectForKey:@"imagenCategoria"] forKey:@"imagenCategoria"];
        }
    }
    
    [self saveContextWithSuccess:^(NSString *successString) {
        success(successString);
    } orError:^(NSString *errorString, NSDictionary *errorDict) {
        saveError(errorString, errorDict);
    }];
}


-(void)setNewProduct:(NSDictionary *)params withSuccess:(SavedContexSuccess)success orError:(SavedContextError)saveError
{
    NSArray *oldInfo = [self allInstancesOf:@"Producto" where:@[@"productoID"] isEqualto:@[[params objectForKey:@"productoID"]] orderedBy:nil];
    
    if ([oldInfo count]> 0) {
        [self updateExistingProduct:params withSuccess:^(id successSave) {
            success(successSave);
        } onError:^(NSString *errorString, NSDictionary *errorDict) {
            saveError(errorString, errorDict);
        }];
    }else{
    Producto *newProduct = [NSEntityDescription insertNewObjectForEntityForName:@"Producto" inManagedObjectContext:[self managedObjectContext]];
    newProduct.productoID =  [params objectForKey:@"productoID"];
    newProduct.nombreProducto = [params objectForKey:@"nombreProducto"];
    newProduct.precioCompra = [params objectForKey:@"precioCompra"];
    newProduct.proveedorProducto =  [params objectForKey:@"proveedorProducto"];
    newProduct.precioVenta = [params objectForKey:@"precioVenta"];
    newProduct.imagenProducto = [params objectForKey:@"imagenProducto"];
    newProduct.codigoBarras =  [params objectForKey:@"codigoBarras"];
    newProduct.notasProducto = [params objectForKey:@"notasProducto"];
    newProduct.productoCategoria = [self singleInstanceOf:@"Categorias" where:@"idCategoria" isEqualTo:[params objectForKey:@"idCategoria"]];
    newProduct.cantidadDisponible = [params objectForKey:@"cantidadDisponible"];
        
    [self saveContextWithSuccess:^(NSString *successString) {
        success(newProduct);
    } orError:^(NSString *errorString, NSDictionary *errorDict) {
        saveError(errorString, errorDict);
    }];
    }
    
}


-(void)updateExistingProduct:(NSDictionary *)dict withSuccess:(SavedContexSuccess)success onError:(SavedContextError)saveError
{
    NSString *existingProductId = [dict objectForKey:@"productoID"];
    Producto *currentProduct = [self singleInstanceOf:@"Producto" where:@"productoID" isEqualTo:existingProductId];
    if ([currentProduct.nombreProducto isEqualToString:[dict objectForKey:@"nombreProducto"]]
        || [currentProduct.precioCompra isEqualToString:[dict objectForKey:@"precioCompra"]]
        || ![currentProduct.precioVenta isEqualToString:[dict objectForKey:@"precioVenta"]]
        || ![currentProduct.codigoBarras isEqualToString:[dict objectForKey:@"codigoBarras"]]
        || ![currentProduct.imagenProducto isEqualToString:[dict objectForKey:@"imagenProducto"]]
        | ![currentProduct.notasProducto isEqualToString:[dict objectForKey:@"notasProducto"]]
        || ![currentProduct.proveedorProducto isEqualToString:[dict objectForKey:@"proveedorProducto"]]
        || ![currentProduct.cantidadDisponible isEqualToString:[dict objectForKey:@"cantidadDisponible"]]
        ) {
        if ([(NSString *)[dict objectForKey:@"nombreProducto"] length] > 0) {
            [currentProduct setValue:[dict objectForKey:@"nombreProducto"] forKey:@"nombreProducto"];
        }
        if ([(NSString *)[dict objectForKey:@"precioCompra"] length] > 0) {
            [currentProduct setValue:[dict objectForKey:@"precioCompra"] forKey:@"precioCompra"];
        }
        if ([(NSString *)[dict objectForKey:@"precioVenta"] length] > 0) {
            [currentProduct setValue:[dict objectForKey:@"precioVenta"] forKey:@"precioVenta"];
        }
        if ([(NSString *)[dict objectForKey:@"codigoBarras"] length] > 0) {
            [currentProduct setValue:[dict objectForKey:@"codigoBarras"] forKey:@"codigoBarras"];
        }
        if ([(NSString *)[dict objectForKey:@"imagenProducto"] length] > 0) {
            [currentProduct setValue:[dict objectForKey:@"imagenProducto"] forKey:@"imagenProducto"];
        }
        if ([(NSString *)[dict objectForKey:@"notasProducto"] length] > 0) {
            [currentProduct setValue:[dict objectForKey:@"notasProducto"] forKey:@"notasProducto"];
        }
        if ([(NSString *)[dict objectForKey:@"proveedorProducto"] length] > 0) {
            [currentProduct setValue:[dict objectForKey:@"proveedorProducto"] forKey:@"proveedorProducto"];
        }
        if ([(NSString *)[dict objectForKey:@"cantidadDisponible"] length] > 0) {
            [currentProduct setValue:[dict objectForKey:@"cantidadDisponible"] forKey:@"cantidadDisponible"];
        }
    }
    
    Categorias *selectedCategory =[self singleInstanceOf:@"Categorias" where:@"idCategoria" isEqualTo:[dict objectForKey:@"idCategoria"]];
    
    if ([(NSString *)[dict objectForKey:@"idCategoria"] length] > 0) {
        if (currentProduct.productoCategoria != selectedCategory) {
            currentProduct.productoCategoria = selectedCategory;
        }
    }
    
    
    [self saveContextWithSuccess:^(NSString *successString) {
        success(successString);
    } orError:^(NSString *errorString, NSDictionary *errorDict) {
        saveError(errorString, errorDict);
    }];
}

- (void)deleteEntity:(NSManagedObject *)entity
{
    [_managedObjectContext deleteObject:entity];
    [self saveContextWithSuccess:^(id success) {
        
    } orError:^(NSString *errorString, NSDictionary *errorDict) {
        
    }];
}

-(void)setNewClient:(NSDictionary *)params withSuccess:(SavedContexSuccess)success orError:(SavedContextError)saveError
{
    NSArray *oldInfo = [self allInstancesOf:@"Cliente" where:@[@"idCliente"] isEqualto:@[[params objectForKey:@"idCliente"]] orderedBy:nil];
    
    if ([oldInfo count]> 0) {
        [self updateExistingProduct:params withSuccess:^(id successSave) {
            success(successSave);
        } onError:^(NSString *errorString, NSDictionary *errorDict) {
            saveError(errorString, errorDict);
        }];
    }else{
        Cliente *newClient = [NSEntityDescription insertNewObjectForEntityForName:@"Cliente" inManagedObjectContext:[self managedObjectContext]];
        newClient.idCliente =  [params objectForKey:@"idCliente"];
        newClient.nombreCliente = [params objectForKey:@"nombreCliente"];
        newClient.apellidoCliente = [params objectForKey:@"apellidoCliente"];
        newClient.telefonoCliente = [params objectForKey:@"telefonoCliente"];
        newClient.correoCliente = [params objectForKey:@"correoCliente"];
        newClient.direccionCliente = [params objectForKey:@"direccionCliente"];
        newClient.calleNumero = [params objectForKey:@"calleNumero"];
        for (Pedido *clientPedido in [params objectForKey:@"pedidosCliente"]) {
            [newClient addClientePedidoObject:clientPedido];
        }
        
        [self saveContextWithSuccess:^(NSString *successString) {
            success(newClient);
        } orError:^(NSString *errorString, NSDictionary *errorDict) {
            saveError(errorString, errorDict);
        }];
    }
}

-(void)updateExistingClient:(NSDictionary *)dict withSuccess:(SavedContexSuccess)success onError:(SavedContextError)saveError
{
    NSString *existingClientId= [dict objectForKey:@"idCliente"];
    Cliente *currentClient = [self singleInstanceOf:@"Cliente" where:@"idCliente" isEqualTo:existingClientId];
    if (   ![currentClient.nombreCliente isEqualToString:[dict objectForKey:@"nombreCliente"]]
        || ![currentClient.apellidoCliente isEqualToString:[dict objectForKey:@"apellidoCliente"]]
        || ![currentClient.telefonoCliente isEqualToString:[dict objectForKey:@"telefonoCliente"]]
        || ![currentClient.correoCliente isEqualToString:[dict objectForKey:@"correoCliente"]]
        || ![currentClient.direccionCliente isEqualToString:[dict objectForKey:@"direccionCliente"]]
        || ![currentClient.calleNumero isEqualToString:[dict objectForKey:@"calleNumero"]]
        ) {
        if ([(NSString *)[dict objectForKey:@"nombreCliente"] length] > 0) {
            [currentClient setValue:[dict objectForKey:@"nombreCliente"] forKey:@"nombreCliente"];
        }
        if ([(NSString *)[dict objectForKey:@"apellidoCliente"] length] > 0) {
            [currentClient setValue:[dict objectForKey:@"apellidoCliente"] forKey:@"apellidoCliente"];
        }
        if ([(NSString *)[dict objectForKey:@"telefonoCliente"] length] > 0) {
            [currentClient setValue:[dict objectForKey:@"telefonoCliente"] forKey:@"telefonoCliente"];
        }
        if ([(NSString *)[dict objectForKey:@"correoCliente"] length] > 0) {
            [currentClient setValue:[dict objectForKey:@"correoCliente"] forKey:@"correoCliente"];
        }
        if ([(NSString *)[dict objectForKey:@"direccionCliente"] length] > 0) {
            [currentClient setValue:[dict objectForKey:@"direccionCliente"] forKey:@"direccionCliente"];
        }
        if ([(NSString *)[dict objectForKey:@"calleNumero"] length] > 0) {
            [currentClient setValue:[dict objectForKey:@"calleNumero"] forKey:@"calleNumero"];
        }
    }
    if ([(NSArray *)[dict objectForKey:@"pedidosCliente"] count] > 0) {
        for (Pedido *clientePedido in [dict objectForKey:@"pedidosCliente"]) {
            if ([currentClient.clientePedido containsObject:[self singleInstanceOf:@"Pedido" where:@"idPedido" isEqualTo:clientePedido.idPedido]]) {
                [currentClient removeClientePedidoObject:[self singleInstanceOf:@"Pedido" where:@"idPedido" isEqualTo:clientePedido.idPedido]];
            }
            [currentClient addClientePedidoObject:[self singleInstanceOf:@"Pedido" where:@"idPedido" isEqualTo:clientePedido.idPedido]];
        }
    }
    [self saveContextWithSuccess:^(NSString *successString) {
        success(successString);
    } orError:^(NSString *errorString, NSDictionary *errorDict) {
        saveError(errorString, errorDict);
    }];
}



-(NSArray *)savedCategoriesOnDB
{
    NSArray *savedData = [self allInstancesOf:@"Categorias" where:nil isEqualto:nil orderedBy:@"idCategoria"];
    return savedData;
}

-(NSArray *)savedProductsOnDBForCategory:(NSString *)category
{
    NSArray *savedData = [self allInstancesOf:@"Producto" where:@[@"productoCategoria.idCategoria"] isEqualto:@[category] orderedBy:@"productoID"];
    return savedData;
}

-(NSArray *)savedClients
{
    NSArray *savedData = [self allInstancesOf:@"Cliente" where:nil isEqualto:nil orderedBy:@"idCliente"];
    return savedData;
}



- (void)saveContextWithSuccess:(SavedContexSuccess)success orError:(SavedContextError)saveError
{
    NSError *error = nil;
    
    NSManagedObjectContext *context = _managedObjectContext;
    
    
    if (context != nil)
    {
        if ([context hasChanges] && ![context save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            saveError(error.description, [error userInfo]);
            abort();
        }
    }
    success(@"saved successfully");
}

#pragma mark – DATA IMPORT


- (void)importFromXML:(NSURL*)url {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    self.parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    self.parser.delegate = self;
    
    NSLog(@"**** START PARSE OF %@", url.path);
    [self.parser parse];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"SomethingChanged" object:nil];
    NSLog(@"***** END PARSE OF %@", url.path);
}
- (NSDictionary*)selectedUniqueAttributes {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSMutableArray *entities   = [NSMutableArray new];
    NSMutableArray *attributes = [NSMutableArray new];
    
    // Select an attribute in each entity for uniqueness
    [entities addObject:@"Tract"];[attributes addObject:@"tractId"];
    [entities addObject:@"Product"];[attributes addObject:@"productId"];
    [entities addObject:@"Destination"];[attributes addObject:@"destinationId"];
    [entities addObject:@"Ticket"];[attributes addObject:@"loadId"];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:attributes
                                                           forKeys:entities];
    return dictionary;
}


#pragma mark - DELEGATE: NSXMLParser 
- (void)parser:(NSXMLParser *)parser
parseErrorOccurred:(NSError *)parseError {
    if (debug==1) {
        NSLog(@"Parser Error: %@", parseError.localizedDescription);
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"finishedImporting" object:nil];
    NSLog(@"Finished Parsing");
    NSLog(@"Saved in %@", [self applicationDocumentsDirectory]);
}


/*
- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
    
    [self.importContext performBlockAndWait:^{
        
        // STEP 1: Process only the 'item' element in the XML file
        if ([elementName isEqualToString:@"Tract"]) {
            
            // STEP 2: Prepare the Core Data Importer
            CoreDataImporter *importer =
            [[CoreDataImporter alloc] initWithUniqueAttributes:
             [self selectedUniqueAttributes]];
            
            // STEP 3a: Insert a unique 'Item' object
            NSManagedObject *tract =
            [importer insertBasicObjectInTargetEntity:@"Tract"
                                targetEntityAttribute:@"tractId"
                                   sourceXMLAttribute:@"tractId"
                                        attributeDict:attributeDict
                                              context:self.managedObjectContext];
            
            // STEP 5: Create relationships
            [tract setValue:[attributeDict objectForKey:@"tractName"] forKey:@"tractName"];
            [tract setValue:[attributeDict objectForKey:@"tractShortName"] forKey:@"tractShortName"];
            [tract setValue:[attributeDict objectForKey:@"latitude"] forKey:@"latitude"];
            [tract setValue:[attributeDict objectForKey:@"longitude"] forKey:@"longitude"];
            [tract setValue:[attributeDict objectForKey:@"loggerId"] forKey:@"loggerId"];
            [tract setValue:[attributeDict objectForKey:@"managementZoneId"] forKey:@"managementZoneId"];
            // STEP 6: Save new objects to the persistent store.
            [CoreDataImporter saveContext:self.managedObjectContext];
            
            // STEP 7: Turn objects into faults to save memory
            [self.managedObjectContext refreshObject:tract mergeChanges:NO];
             NSLog(@"Tract ===== %@",tract.description);
        }else if ([elementName isEqualToString:@"Ticket"]) {
            
            // STEP 2: Prepare the Core Data Importer
            CoreDataImporter *importer =
            [[CoreDataImporter alloc] initWithUniqueAttributes:
             [self selectedUniqueAttributes]];
            
            // STEP 3a: Insert a unique 'Item' object
            NSManagedObject *ticket =
            [importer insertBasicObjectInTargetEntity:@"Ticket"
                                targetEntityAttribute:@"loadId"
                                   sourceXMLAttribute:@"loadId"
                                        attributeDict:attributeDict
                                              context:self.managedObjectContext];
            
            // STEP 5: Create relationships
            [ticket setValue:[attributeDict objectForKey:@"destinationId"] forKey:@"destinationId"];
            [ticket setValue:[attributeDict objectForKey:@"tractId"] forKey:@"tractId"];
            [ticket setValue:[attributeDict objectForKey:@"destinationRemark"] forKey:@"destinationRemark"];
            [ticket setValue:[attributeDict objectForKey:@"loadDate"] forKey:@"loadDate"];
            [ticket setValue:[attributeDict objectForKey:@"locationLatitude"] forKey:@"locationLatitude"];
            [ticket setValue:[attributeDict objectForKey:@"locationLongitude"] forKey:@"locationLongitude"];
            [ticket setValue:[attributeDict objectForKey:@"mobileDeciveId"] forKey:@"mobileDeciveId"];
            [ticket setValue:[attributeDict objectForKey:@"netWeight"] forKey:@"netWeight"];
            [ticket setValue:[attributeDict objectForKey:@"productRemark"] forKey:@"productRemark"];
            [ticket setValue:[attributeDict objectForKey:@"productId"] forKey:@"productId"];
            [ticket setValue:[attributeDict objectForKey:@"remarks"] forKey:@"remarks"];
            [ticket setValue:[attributeDict objectForKey:@"tareWeight"] forKey:@"tareWeight"];
            [ticket setValue:[attributeDict objectForKey:@"dockWeight"] forKey:@"dockWeight"];
            [ticket setValue:[attributeDict objectForKey:@"grossWeight"] forKey:@"grossWeight"];
            [ticket setValue:[attributeDict objectForKey:@"lmsControlCode"] forKey:@"lmsControlCode"];
            [ticket setValue:[attributeDict objectForKey:@"voidOkFlag"] forKey:@"voidOkFlag"];
            [ticket setValue:[attributeDict objectForKey:@"weightTicketNumber"] forKey:@"weightTicketNumber"];
            
            
            
            // STEP 6: Save new objects to the persistent store.
            [CoreDataImporter saveContext:self.managedObjectContext];
            
            // STEP 7: Turn objects into faults to save memory
            [self.managedObjectContext refreshObject:ticket mergeChanges:NO];
            NSLog(@"Ticket Saved ===== %@",ticket.description);
        }else if ([elementName isEqualToString:@"Destination"]) {
            
            // STEP 2: Prepare the Core Data Importer
            CoreDataImporter *importer =
            [[CoreDataImporter alloc] initWithUniqueAttributes:
             [self selectedUniqueAttributes]];
            
            // STEP 3a: Insert a unique 'Item' object
            NSManagedObject *destination =
            [importer insertBasicObjectInTargetEntity:@"Destination"
                                targetEntityAttribute:@"destinationId"
                                   sourceXMLAttribute:@"destinationId"
                                        attributeDict:attributeDict
                                              context:self.managedObjectContext];
            
            // STEP 5: Create relationships
            [destination setValue:[attributeDict objectForKey:@"destinationName"] forKey:@"destinationName"];
            [destination setValue:[attributeDict objectForKey:@"destinationShortName"] forKey:@"destinationShortName"];
            
            
            
            
            // STEP 6: Save new objects to the persistent store.
            [CoreDataImporter saveContext:self.managedObjectContext];
            
            // STEP 7: Turn objects into faults to save memory
            [self.managedObjectContext refreshObject:destination mergeChanges:NO];
            NSLog(@"Destination Saved ===== %@",destination.description);
        }else if ([elementName isEqualToString:@"Product"]) {
            
            // STEP 2: Prepare the Core Data Importer
            CoreDataImporter *importer =
            [[CoreDataImporter alloc] initWithUniqueAttributes:
             [self selectedUniqueAttributes]];
            
            // STEP 3a: Insert a unique 'Item' object
            NSManagedObject *product =
            [importer insertBasicObjectInTargetEntity:@"Product"
                                targetEntityAttribute:@"productId"
                                   sourceXMLAttribute:@"productId"
                                        attributeDict:attributeDict
                                              context:self.managedObjectContext];
            
            // STEP 5: Create relationships
            [product setValue:[attributeDict objectForKey:@"productName"] forKey:@"productName"];
            [product setValue:[attributeDict objectForKey:@"productName"] forKey:@"productName"];
            
            
            
            
            // STEP 6: Save new objects to the persistent store.
            [CoreDataImporter saveContext:self.managedObjectContext];
            
            // STEP 7: Turn objects into faults to save memory
            [self.managedObjectContext refreshObject:product mergeChanges:NO];
            NSLog(@"Product Saved ===== %@",product.description);
        }
    }];
   
}*/
@end
