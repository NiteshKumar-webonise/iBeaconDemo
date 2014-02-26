//
//  ModelContext.h
//  Assignment_3
//
//  Created by Webonise on 19/07/13.
//  Copyright (c) 2013 Webonise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#include <objc/runtime.h>

@interface ModelContext : NSObject
// Core data
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic,retain) NSString *resourceURL;//database name
//for database tramsaction
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property BOOL inTransaction;
+(id)sharedSingletonObject;
- (NSManagedObjectContext *)managedObjectContext;
- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;


+(NSDictionary *) dictionaryWithPropertiesOfObject:(id) obj;
-(int)isRecordPresentFromEntity:(NSString *)entityName ColumnName:(NSString *)column signToCompare:(NSString*)sign forValue:(NSString*)value;
-(void)insertIntoEntity:(NSString *)entityName entityObject:(id)object;
-(NSArray *)fetchAllRecordsFromEntity :(NSString *)entityName;
-(NSArray *)fetchFromEntity:(NSString *)entityName whereColumnName:(NSString *)column signToCompare:(NSString*)sign forValue:(NSString*)value;
-(void)deleteFromEntity:(NSString *)entityName whereColumnName:(NSString *)column signToCompare:(NSString*)sign forValue:(NSString*)value;
-(void)deleteAllRecordsFromEntity:(NSString *)entityName;
-(void)updateFromEntity:(NSString *)entityName whereColumnName:(NSString *)column signToCompare:(NSString*)sign forValue:(NSString*)value setKey:(NSString *)key setValue:(id)valueForKey;
@end
