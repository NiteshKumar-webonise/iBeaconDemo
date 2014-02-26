//
//  ModelContext.m
//  Assignment_3
//
//  Created by Webonise on 19/07/13.
//  Copyright (c) 2013 Webonise. All rights reserved.
//

#import "ModelContext.h"

@implementation ModelContext
@synthesize managedObjectModel;
@synthesize managedObjectContext;
@synthesize persistentStoreCoordinator;
@synthesize resourceURL;
@synthesize inTransaction;


static ModelContext  *modolContextInstance=nil;

+(id)sharedSingletonObject{
    @synchronized(self) {
        if(modolContextInstance==nil)
            modolContextInstance = [[ModelContext alloc]init];
        
        return modolContextInstance;
    }
    return nil;
}

+(id)alloc
{
	@synchronized([ModelContext class])
	{
		modolContextInstance = [super alloc];
		return modolContextInstance;
	}
    
	return modolContextInstance;
}

-(id)init {
    if(modolContextInstance==nil){
        modolContextInstance=[super init];
    }
	
    return modolContextInstance;
}

// Core data

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{   
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:resourceURL withExtension:@"momd"];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    NSString *urlAppend=[self.resourceURL stringByAppendingFormat:@"%@",@".sqlite"];
    NSURL *storeURL =[[self applicationDocumentsDirectory] URLByAppendingPathComponent:urlAppend];
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        abort();
    }
    
    return persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark- Core Data methods

//convert object into dictionary //no matter it has composition
+(NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj
{
    
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([obj class], &count);
    
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        
        NSString *key = [NSString stringWithUTF8String:property_getName(property)];
        NSLog(@"present key:-%@",key);
        //for composite objects
        if([[obj valueForKey:key] isKindOfClass:[NSObject class]]){
            id testObj=[obj valueForKey:key];
            NSMutableDictionary *testDict=[NSMutableDictionary dictionary];
            unsigned testCount;
            objc_property_t *testProperties __attribute__((unused))=class_copyPropertyList([testObj class], &testCount);
            if(testCount>1){
                testDict=[[self dictionaryWithPropertiesOfObject:testObj] mutableCopy];
                NSLog(@"%@",testDict);
                [dict setObject:testDict forKey:key];
                continue;
            }
            
        }
        
        [dict setObject:[obj valueForKey:key] forKey:key];
    }
    
    return [NSDictionary dictionaryWithDictionary:dict];
}


//insert into table
-(void)insertIntoEntity:(NSString *)entityName entityObject:(id)object{
   
    NSLog(@"%@",entityName);
    NSManagedObject *data  = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
    NSLog(@"insertNewObjectForEntityForName");

    NSDictionary *dict;
    
    if([object isKindOfClass:dict.class]){
        dict=object;
    }else{
    
    dict=[ModelContext dictionaryWithPropertiesOfObject:object];
    }
    for (id key in dict) {
        [data setValue:[dict objectForKey:key] forKey:key];
    }
    @try {
        [self save];
    }
    @catch (NSException *exception) {
        NSLog(@"some error");
    }
    
    
    
}


//set entity name first and fetch the result from this entity
-(NSArray *)fetchAllRecordsFromEntity :(NSString *)entityName{
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:entityName];
    
    NSError *error = nil;
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    return results;
}

//check whether the record is present the entity or not if present then return count of records which matches the condition
-(int)isRecordPresentFromEntity:(NSString *)entityName ColumnName:(NSString *)column signToCompare:(NSString*)sign forValue:(NSString*)value{
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:entityName];
    NSPredicate *predicate;
    predicate =[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ %@ '%@'",column,sign,value]];
    //NSLog(@"%@",predicate);
    [request setPredicate:predicate];
    NSError *error = nil;
    int count=[self.managedObjectContext countForFetchRequest:request error:&error];
    return count;
}

//Delete all records from the given entity
-(void)deleteAllRecordsFromEntity:(NSString *)entityName{
   NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:entityName];
    NSError *error = nil;
    NSArray *records=[self.managedObjectContext executeFetchRequest:request error:&error];
    for(NSManagedObject *record in records){
        [self.managedObjectContext deleteObject:record];
    }
}

//fetch from entity with given condition
-(NSArray *)fetchFromEntity:(NSString *)entityName whereColumnName:(NSString *)column signToCompare:(NSString*)sign forValue:(NSString*)value{
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:entityName];
    NSPredicate *predicate;
    predicate =[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ %@ '%@'",column,sign,value]];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *records = [managedObjectContext executeFetchRequest:request error:&error];
    return records;
    
}

//delete from entity with given condition
-(void)deleteFromEntity:(NSString *)entityName whereColumnName:(NSString *)column signToCompare:(NSString*)sign forValue:(NSString*)value{
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:entityName];
    NSPredicate *predicate;
    predicate =[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ %@ '%@'",column,sign,value]];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *records=[self.managedObjectContext executeFetchRequest:request error:&error];
    
    for(NSManagedObject *managedObject in records){
        [self.managedObjectContext deleteObject:managedObject];
    }
    
    [self save];
}

//update from table with given condition
-(void)updateFromEntity:(NSString *)entityName whereColumnName:(NSString *)column signToCompare:(NSString*)sign forValue:(NSString*)value setKey:(NSString *)key setValue:(id)valueForKey{
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:entityName];
    NSPredicate *predicate;
    predicate =[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ %@ '%@'",column,sign,value]];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *records=[self.managedObjectContext executeFetchRequest:request error:&error];
    
    if([valueForKey isKindOfClass:[NSString class]]){
        for(NSManagedObject *managedObject in records){
            [managedObject setValue:valueForKey forKey:key];
        }
    }else if ([valueForKey isKindOfClass:[NSNumber class]]){
        NSNumberFormatter * myNumFormatter = [[NSNumberFormatter alloc] init];
        NSNumber *tempNum = [myNumFormatter numberFromString:[valueForKey stringValue]];
        for(NSManagedObject *managedObject in records){
            [managedObject setValue:tempNum forKey:key];
        }
    }
    
    for(NSManagedObject *managedObject in records){
        [managedObject setValue:valueForKey forKey:key];
    }
    
    
}

-(BOOL)save {
    if ( !inTransaction ) {
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            return NO;
        } else {
            return YES;
        }
    } else {
        return YES;
    }
}

@end
