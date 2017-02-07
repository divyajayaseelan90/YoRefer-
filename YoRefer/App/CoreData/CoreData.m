//
//  CoreData.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 12/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "CoreData.h"
#import "CarouselData.h"
#import "FeaturedData.h"
#import "MeData.h"
#import "HomeData.h"
#import "CategoryData.h"
#import "ContactData.h"
#import "OfflineRefer.h"
#import "OfflineAsk.h"

@implementation CoreData

#pragma mark -
+ (CoreData *)shareData
{
    
    static CoreData *_shareData = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        _shareData = [[CoreData alloc]init];
        
    });
    
    return _shareData;
    
}


#pragma mark - init
-(instancetype)init
{
    
    self = [super init];
    
    if(self) {
        
        
    }
    
    return self;
    
}

#pragma mark - managedObjectContext

- (NSManagedObjectContext *)managedObjectContext
{
    
    NSManagedObjectContext *context=nil;
    id delegate=[[UIApplication sharedApplication] delegate];
    if([delegate performSelector:@selector(managedObjectContext)]){
        context=[delegate managedObjectContext];
    }
    return context;
    
}

#pragma mark - Carousel

- (void)setCarouselWithLoginId:(NSString *)loginId response:(NSDictionary *)response
{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    
    CarouselData *Carousel = (CarouselData *)[NSEntityDescription insertNewObjectForEntityForName:@"CarouselData" inManagedObjectContext:context];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setValue:[response valueForKey:@"response"] forKey:loginId];
    
    [Carousel setCarousel:dictionary];
    
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    
    
}

- (NSArray *)getCarouselWithLoginId:(NSString *)loginId
{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *req=[[NSFetchRequest alloc] initWithEntityName:@"CarouselData"];
    NSArray *contextarray  =[context executeFetchRequest:req error:nil];
    
    for (CarouselData *obj in contextarray) {
        
        NSArray *array = [obj.carousel valueForKey:loginId];
        
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            return array;
            
        }
        
    }
    
    return nil;
}


- (void)deleteCarouselWithLoginId:(NSString *)loginId
{
    NSManagedObjectContext *context=[self managedObjectContext];
    //Contacts
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"CarouselData"];
    NSArray *contextArray   = [context executeFetchRequest:request error:nil];
    int i =0;
    for (NSManagedObject *object in contextArray) {
        
        CarouselData *homeData = (CarouselData *)[contextArray objectAtIndex:i];
        
        NSArray *array = [homeData.carousel objectForKey:[NSString stringWithFormat:@"%@",loginId]];
        
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            [context deleteObject:object];
            
        }
        i++;
    }
    
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    
}


#pragma mark - Featured

- (void)setFeaturedWithLoginId:(NSString *)loginId response:(NSDictionary *)response
{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    
    FeaturedData *Carousel = (FeaturedData *)[NSEntityDescription insertNewObjectForEntityForName:@"FeaturedData" inManagedObjectContext:context];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setValue:[response valueForKey:@"response"] forKey:loginId];
    
    [Carousel setFeatured:dictionary];
    
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    
    
}


- (NSArray *)getFeaturedWithLoginId:(NSString *)loginId
{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *req=[[NSFetchRequest alloc] initWithEntityName:@"FeaturedData"];
    NSArray *contextarray  =[context executeFetchRequest:req error:nil];
    
    for (FeaturedData *obj in contextarray) {
        
        NSArray *array = [obj.featured valueForKey:loginId];
        
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            return array;
            
        }
        
    }
    
    return nil;
    
}

- (void)deleteFeaturedWithLoginId:(NSString *)loginId
{
    NSManagedObjectContext *context=[self managedObjectContext];
    //Contacts
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"FeaturedData"];
    NSArray *contextArray   = [context executeFetchRequest:request error:nil];
    int i =0;
    for (NSManagedObject *object in contextArray) {
        
        FeaturedData *homeData = (FeaturedData *)[contextArray objectAtIndex:i];
        
        NSArray *array = [homeData.featured objectForKey:[NSString stringWithFormat:@"%@",loginId]];
        
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            [context deleteObject:object];
            
        }
        i++;
    }
    
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    
}


#pragma mark  - me

- (void)setReferWithLoginId:(NSString *)loginId response:(NSDictionary *)response
{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    
    MeData *me = (MeData *)[NSEntityDescription insertNewObjectForEntityForName:@"MeData" inManagedObjectContext:context];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setValue:[response valueForKey:@"response"] forKey:[NSString stringWithFormat:@"%@%@",@"refer",loginId]];
    
    [me setRefers:dictionary];
    
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    
    
}


- (NSArray *)getReferWithLoginId:(NSString *)loginId
{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *req=[[NSFetchRequest alloc] initWithEntityName:@"MeData"];
    NSArray *contextarray  =[context executeFetchRequest:req error:nil];
    
    for (MeData *obj in contextarray) {
        
        NSArray *array = [obj.refers valueForKey:[NSString stringWithFormat:@"%@%@",@"refer",loginId]];
        
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            return array;
            
        }
        
    }
    
    return nil;
    
}


- (void)setQueriesWithLoginId:(NSString *)loginId response:(NSDictionary *)response
{
    [self deleteQueriesWithLoginId:loginId];
    
    NSManagedObjectContext *context=[self managedObjectContext];
    
    MeData *me = (MeData *)[NSEntityDescription insertNewObjectForEntityForName:@"MeData" inManagedObjectContext:context];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setValue:[response valueForKey:@"response"] forKey:[NSString stringWithFormat:@"%@%@",@"queries",loginId]];
    
    [me setQueries:dictionary];
    
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    
    
}


- (NSArray *)getQueriesWithLoginId:(NSString *)loginId
{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *req=[[NSFetchRequest alloc] initWithEntityName:@"MeData"];
    NSArray *contextarray  =[context executeFetchRequest:req error:nil];
    
    for (MeData *obj in contextarray) {
        
        NSArray *array = [obj.queries valueForKey:[NSString stringWithFormat:@"%@%@",@"queries",loginId]];
        
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            return array;
            
        }
        
    }
    
    return nil;
    
}

- (void)deleteQueriesWithLoginId:(NSString *)loginId
{
    NSManagedObjectContext *context=[self managedObjectContext];
    //Contacts
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MeData"];
    NSArray *contextArray   = [context executeFetchRequest:request error:nil];
    int i =0;
    for (NSManagedObject *object in contextArray) {
        
        MeData *homeData = (MeData *)[contextArray objectAtIndex:i];
        
        NSArray *array = [homeData.queries objectForKey:[NSString stringWithFormat:@"%@%@",@"queries",loginId]];
        
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            [context deleteObject:object];
            
        }
        i++;
    }
    
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    
}

- (void)setFeedsWithLoginId:(NSString *)loginId response:(NSDictionary *)response
{
    
}

- (void)setFeedsWithLoginId:(NSString *)loginId response:(NSDictionary *)response feedsType:(NSString *)feedsType
{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    
    MeData *me = (MeData *)[NSEntityDescription insertNewObjectForEntityForName:@"MeData" inManagedObjectContext:context];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setValue:[response valueForKey:@"response"] forKey:[NSString stringWithFormat:@"%@%@%@",@"feeds",feedsType,loginId]];
    
    [me setFeeds:dictionary];
    
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    
    
}


- (NSArray *)getFeedsWithLoginId:(NSString *)loginId feedsType:(NSString *)feedsType
{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *req=[[NSFetchRequest alloc] initWithEntityName:@"MeData"];
    NSArray *contextarray  =[context executeFetchRequest:req error:nil];
    
    
    for (MeData *obj in contextarray) {
        
        NSArray *array = [obj.feeds valueForKey:[NSString stringWithFormat:@"%@%@%@",@"feeds",feedsType,loginId]];
        
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            return array;
            
        }
        
    }
    
    return nil;
    
}

- (void)deleteFeedsWithLoginId:(NSString *)loginId  feedsType:(NSString *)feed
{
    NSManagedObjectContext *context=[self managedObjectContext];
    //Contacts
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MeData"];
    NSArray *contextArray   = [context executeFetchRequest:request error:nil];
    int i =0;
    for (NSManagedObject *object in contextArray) {
        
        MeData *homeData = (MeData *)[contextArray objectAtIndex:i];
        
        NSArray *array = [homeData.feeds objectForKey:[NSString stringWithFormat:@"%@%@%@",@"feeds",feed,loginId]];
        
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            [context deleteObject:object];
            
        }
        i++;
    }
    
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    
}




- (void)setFriendsWithLoginId:(NSString *)loginId response:(NSDictionary *)response
{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    
    MeData *me = (MeData *)[NSEntityDescription insertNewObjectForEntityForName:@"MeData" inManagedObjectContext:context];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setValue:[response valueForKey:@"response"] forKey:[NSString stringWithFormat:@"%@%@",@"friends",loginId]];
    
    [me setFriends:dictionary];
    
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    
    
}


- (NSArray *)getFriendsWithLoginId:(NSString *)loginId
{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *req=[[NSFetchRequest alloc] initWithEntityName:@"MeData"];
    NSArray *contextarray  =[context executeFetchRequest:req error:nil];
    
    for (MeData *obj in contextarray) {
        
        NSArray *array = [obj.friends valueForKey:[NSString stringWithFormat:@"%@%@",@"friends",loginId]];
        
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            return array;
            
        }
        
    }
    
    return nil;
    
}

- (void)deleteFriendsWithLoginId:(NSString *)loginId
{
    NSManagedObjectContext *context=[self managedObjectContext];
    //Contacts
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MeData"];
    NSArray *contextArray   = [context executeFetchRequest:request error:nil];
    int i =0;
    for (NSManagedObject *object in contextArray)
    {
        MeData *homeData = (MeData *)[contextArray objectAtIndex:i];
        
        NSArray *array = [homeData.friends valueForKey:[NSString stringWithFormat:@"%@%@",@"friends",loginId]];
        if(array !=nil && [array isKindOfClass:[array class]])
        {
            [context deleteObject:object];
            
        }
        i++;
    }
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
}

#pragma mark - Refers

- (void)setHomeReferWithLoginId:(NSString *)loginId response:(NSDictionary *)response
{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    
     HomeData *home = (HomeData *)[NSEntityDescription insertNewObjectForEntityForName:@"HomeData" inManagedObjectContext:context];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setValue:[response valueForKey:@"response"] forKey:[NSString stringWithFormat:@"%@%@",@"refer",loginId]];
    
    [home setHome:dictionary];
    
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    
    
}

- (NSArray *)getHomeReferWithLoginId:(NSString *)loginId
{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *req=[[NSFetchRequest alloc] initWithEntityName:@"HomeData"];
    NSArray *contextarray  =[context executeFetchRequest:req error:nil];
    
    for (HomeData *obj in contextarray) {
        
        NSArray *array = [obj.home valueForKey:[NSString stringWithFormat:@"%@%@",@"refer",loginId]];
        
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            return array;
            
        }
        
    }
    
    return nil;
    
}

- (void)deleteReferWithLoginId:(NSString *)loginId
{
    NSManagedObjectContext *context=[self managedObjectContext];
    //Contacts
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"HomeData"];
    NSArray *contextArray   = [context executeFetchRequest:request error:nil];
    int i =0;
    for (NSManagedObject *object in contextArray) {
        
        HomeData *homeData = (HomeData *)[contextArray objectAtIndex:i];
        
        NSArray *array = [homeData.home objectForKey:[NSString stringWithFormat:@"%@%@",@"refer",loginId]];
        
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            [context deleteObject:object];
            
        }
        i++;
    }
    
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    
}

#pragma mark - Local refer
- (void)localReferWithLoginId:(NSString *)loginId response:(NSMutableArray *)response
{
    [self deleteLocalReferWithLoginId:loginId];
    
    NSManagedObjectContext *context=[self managedObjectContext];
    
    HomeData *home = (HomeData *)[NSEntityDescription insertNewObjectForEntityForName:@"HomeData" inManagedObjectContext:context];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setValue:response forKey:[NSString stringWithFormat:@"local%@%@",@"refer",loginId]];
    
    [home setHome:dictionary];
    
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
}

- (NSArray *)getLocalReferWithLoginId:(NSString *)loginId
{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *req=[[NSFetchRequest alloc] initWithEntityName:@"HomeData"];
    NSArray *contextarray  =[context executeFetchRequest:req error:nil];
    
    for (HomeData *obj in contextarray) {
        
        NSArray *array = [obj.home valueForKey:[NSString stringWithFormat:@"local%@%@",@"refer",loginId]];
        
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            return array;
            
        }
        
    }
    
    return nil;
    
}

- (void)deleteLocalReferWithLoginId:(NSString *)loginId
{
    NSManagedObjectContext *context=[self managedObjectContext];
    //Contacts
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"HomeData"];
    NSArray *contextArray   = [context executeFetchRequest:request error:nil];
    int i =0;
    for (NSManagedObject *object in contextArray) {
        
        HomeData *homeData = (HomeData *)[contextArray objectAtIndex:i];
        
        NSArray *array = [homeData.home objectForKey:[NSString stringWithFormat:@"local%@%@",@"refer",loginId]];
        
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            [context deleteObject:object];
            
        }
        i++;
    }
    
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    
}


#pragma mark - Local Ask
- (void)localAskWithLoginId:(NSString *)loginId response:(NSMutableArray *)response
{
    [self deleteLocalAskWithLoginId:loginId];
    
    NSManagedObjectContext *context=[self managedObjectContext];
    
    HomeData *home = (HomeData *)[NSEntityDescription insertNewObjectForEntityForName:@"HomeData" inManagedObjectContext:context];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setValue:response forKey:[NSString stringWithFormat:@"local%@%@",@"ask",loginId]];
    
    [home setHome:dictionary];
    
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
}

- (NSArray *)getLocalAskWithLoginId:(NSString *)loginId
{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *req=[[NSFetchRequest alloc] initWithEntityName:@"HomeData"];
    NSArray *contextarray  =[context executeFetchRequest:req error:nil];
    
    for (HomeData *obj in contextarray) {
        
        NSArray *array = [obj.home valueForKey:[NSString stringWithFormat:@"local%@%@",@"ask",loginId]];
        
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            return array;
            
        }
        
    }
    
    return nil;
    
}

- (void)deleteLocalAskWithLoginId:(NSString *)loginId
{
    NSManagedObjectContext *context=[self managedObjectContext];
    //Contacts
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"HomeData"];
    NSArray *contextArray   = [context executeFetchRequest:request error:nil];
    int i =0;
    for (NSManagedObject *object in contextArray) {
        
        HomeData *homeData = (HomeData *)[contextArray objectAtIndex:i];
        
        NSArray *array = [homeData.home objectForKey:[NSString stringWithFormat:@"local%@%@",@"ask",loginId]];
        
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            [context deleteObject:object];
            
        }
        i++;
    }
    
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    
}



#pragma mark - Ask

- (void)setHomeAskWithLoginId:(NSString *)loginId response:(NSDictionary *)response
{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    
    HomeData *home = (HomeData *)[NSEntityDescription insertNewObjectForEntityForName:@"HomeData" inManagedObjectContext:context];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setValue:[response valueForKey:@"response"] forKey:[NSString stringWithFormat:@"%@%@",@"ask",loginId]];
    
    [home setHome:dictionary];
    
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    
    
}


- (NSArray *)getHomeAskWithLoginId:(NSString *)loginId
{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *req=[[NSFetchRequest alloc] initWithEntityName:@"HomeData"];
    NSArray *contextarray  =[context executeFetchRequest:req error:nil];
    
    for (HomeData *obj in contextarray) {
        
        NSArray *array = [obj.home valueForKey:[NSString stringWithFormat:@"%@%@",@"ask",loginId]];
        
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            return array;
        
    }
    
  }

    return nil;
    
}


- (void)setHomeEntityWithLoginId:(NSString *)loginId response:(NSDictionary *)response
{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    
    HomeData *home = (HomeData *)[NSEntityDescription insertNewObjectForEntityForName:@"HomeData" inManagedObjectContext:context];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setValue:[response valueForKey:@"response"] forKey:[NSString stringWithFormat:@"%@%@",@"entity",loginId]];
    
    [home setHome:dictionary];
    
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    
    
}


- (NSArray *)getHomeEntityWithLoginId:(NSString *)loginId
{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *req=[[NSFetchRequest alloc] initWithEntityName:@"HomeData"];
    NSArray *contextarray  =[context executeFetchRequest:req error:nil];
    
    for (HomeData *obj in contextarray) {
        
        NSArray *array = [obj.home valueForKey:[NSString stringWithFormat:@"%@%@",@"entity",loginId]];
        
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            return array;
            
        }
        
    }
    
    return nil;
    
}


- (void)deleteAskWithLoginId:(NSString *)loginId
{
    NSManagedObjectContext *context=[self managedObjectContext];
    //Contacts
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"HomeData"];
    NSArray *contextArray   = [context executeFetchRequest:request error:nil];
    int i =0;
    for (NSManagedObject *object in contextArray) {
        
        HomeData *homeData = (HomeData *)[contextArray objectAtIndex:i];
        
        NSArray *array = [homeData.home objectForKey:[NSString stringWithFormat:@"%@%@",@"ask",loginId]];
        
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            [context deleteObject:object];
            
        }
        i++;
    }
    
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    
}

#pragma mark - Category

- (void)setCategoryWithLoginId:(NSString *)loginId response:(NSDictionary *)response
{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    
    CategoryData *category = (CategoryData *)[NSEntityDescription insertNewObjectForEntityForName:@"CategoryData" inManagedObjectContext:context];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setValue:[response valueForKey:@"response"] forKey:[NSString stringWithFormat:@"%@",loginId]];
    
    [category setCategory:dictionary];
    
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    
    
}


- (NSArray *)getCategoryAskWithLoginId:(NSString *)loginId
{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *req=[[NSFetchRequest alloc] initWithEntityName:@"CategoryData"];
    NSArray *contextarray  =[context executeFetchRequest:req error:nil];
    
    for (CategoryData *obj in contextarray) {
        
        NSArray *array = [obj.category valueForKey:[NSString stringWithFormat:@"%@",loginId]];
        
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            return array;
            
        }
        
    }
    
    return nil;
    
}


- (void)deleteCategoryWithLoginId:(NSString *)loginId
{
    NSManagedObjectContext *context=[self managedObjectContext];
    //Contacts
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"CategoryData"];
    NSArray *contextArray   = [context executeFetchRequest:request error:nil];
    int i =0;
    for (NSManagedObject *object in contextArray) {
        
        CategoryData *homeData = (CategoryData *)[contextArray objectAtIndex:i];
        
        NSArray *array = [homeData.category valueForKey:[NSString stringWithFormat:@"%@",loginId]];
        
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            [context deleteObject:object];
            
        }
        i++;
    }
    
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
}


#pragma mark - Save contact

- (void)setContactWithLoginId:(NSString *)loginId response:(NSMutableArray *)response type:(NSString *)type
{
 
    
    [self deleteContactWithLoginId:loginId type:type];
    
    
    NSManagedObjectContext *context=[self managedObjectContext];
    
    ContactData *category = (ContactData *)[NSEntityDescription insertNewObjectForEntityForName:@"ContactData" inManagedObjectContext:context];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setValue:response forKey:[NSString stringWithFormat:@"%@%@",type,loginId]];
    
    [category setContact:dictionary];
    
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    
    
}


- (NSArray *)getContactAskWithLoginId:(NSString *)loginId type:(NSString *)type
{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *req=[[NSFetchRequest alloc] initWithEntityName:@"ContactData"];
    NSArray *contextarray  =[context executeFetchRequest:req error:nil];
    
    for (ContactData *obj in contextarray) {
        
        NSArray *array = [obj.contact valueForKey:[NSString stringWithFormat:@"%@%@",type,loginId]];
        
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            return array;
            
        }
        
    }
    
    return nil;
    
}


- (void)deleteContactWithLoginId:(NSString *)loginId type:(NSString *)type
{
    NSManagedObjectContext *context=[self managedObjectContext];
    //Contacts
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ContactData"];
    NSArray *contextArray   = [context executeFetchRequest:request error:nil];
    int i =0;
    for (NSManagedObject *object in contextArray) {
        
        ContactData *homeData = (ContactData *)[contextArray objectAtIndex:i];
        
        NSArray *array = [homeData.contact objectForKey:[NSString stringWithFormat:@"%@%@",type,loginId]];
        
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            [context deleteObject:object];
            
        }
        i++;
    }
    
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    
}


#pragma mark - Offline
- (void)setOfflineReferDetailsWithLoginId:(NSString *)loginId response:(NSMutableArray *)response
{
    
    NSMutableArray *array = [[NSMutableArray alloc]initWithArray:[self getOfflineReferWithLoginId:loginId]];
    
    if ([array count] > 0) {
        
        [array addObject:response];
        
        [self deleteOfflineReferWithLoginId:loginId];
        
    }else{
        
        array = response;
        
    }
    
    NSManagedObjectContext *context=[self managedObjectContext];
    
    OfflineRefer *offlineRefer = (OfflineRefer *)[NSEntityDescription insertNewObjectForEntityForName:@"OfflineRefer" inManagedObjectContext:context];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setValue:array forKey:loginId];
    
    [offlineRefer setRefer:dictionary];
    
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    
}


- (NSArray *)getOfflineReferWithLoginId:(NSString *)loginId
{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *req=[[NSFetchRequest alloc] initWithEntityName:@"OfflineRefer"];
    NSArray *contextarray  =[context executeFetchRequest:req error:nil];
    
    for (OfflineRefer *obj in contextarray) {
        
        NSArray *array = [obj.refer valueForKey:[NSString stringWithFormat:@"%@",loginId]];
        
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            return array;
            
        }
        
    }
    
    return nil;
    
}

- (void)deleteOfflineReferWithLoginId:(NSString *)loginId
{
    NSManagedObjectContext *context=[self managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"OfflineRefer"];
    NSArray *contextArray   = [context executeFetchRequest:request error:nil];
    int i =0;
    for (NSManagedObject *object in contextArray) {
        
        OfflineRefer *offlineRefer = (OfflineRefer *)[contextArray objectAtIndex:i];
        
        NSArray *array = [offlineRefer.refer objectForKey:[NSString stringWithFormat:@"%@",loginId]];
        
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            [context deleteObject:object];
            
        }
        i++;
    }
    
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    
}

- (void)setOfflineAskDetailsWithLoginId:(NSString *)loginId response:(NSMutableArray *)response
{
    NSManagedObjectContext *context=[self managedObjectContext];
    
    OfflineAsk *offlineAsk = (OfflineAsk *)[NSEntityDescription insertNewObjectForEntityForName:@"OfflineAsk" inManagedObjectContext:context];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setValue:response forKey:loginId];
    
    [offlineAsk setAsk:dictionary];
    
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
}


- (NSArray *)getOfflineAskWithLoginId:(NSString *)loginId
{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *req=[[NSFetchRequest alloc] initWithEntityName:@"OfflineAsk"];
    NSArray *contextarray  =[context executeFetchRequest:req error:nil];
    
    for (OfflineAsk *obj in contextarray) {
        
        NSArray *array = [obj.ask valueForKey:[NSString stringWithFormat:@"%@",loginId]];
        
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            return array;
            
        }
        
    }
    
    return nil;
}

- (void)deleteOfflineAskWithLoginId:(NSString *)loginId
{
    NSManagedObjectContext *context=[self managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"OfflineAsk"];
    NSArray *contextArray   = [context executeFetchRequest:request error:nil];
    int i =0;
    for (NSManagedObject *object in contextArray) {
        
        OfflineAsk *offlineAsk = (OfflineAsk *)[contextArray objectAtIndex:i];
        
        NSArray *array = [offlineAsk.ask objectForKey:[NSString stringWithFormat:@"%@",loginId]];
        
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            [context deleteObject:object];
            
        }
        i++;
    }
    
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    
}

#pragma mark - Me refers
#pragma mark - Place
- (void)setPlaceReferWithLoginId:(NSString *)loginId response:(NSDictionary *)response
{
    [self deletePlaceReferWithLoginId:loginId];
    NSManagedObjectContext *context=[self managedObjectContext];
    MeData *me = (MeData *)[NSEntityDescription insertNewObjectForEntityForName:@"MeData" inManagedObjectContext:context];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:[response valueForKey:@"response"] forKey:[NSString stringWithFormat:@"%@%@",@"placerefer",loginId]];
    [me setRefers:dictionary];
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
}

- (NSArray *)getPlaceReferWithLoginId:(NSString *)loginId
{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *req=[[NSFetchRequest alloc] initWithEntityName:@"MeData"];
    NSArray *contextarray  =[context executeFetchRequest:req error:nil];
    for (MeData *obj in contextarray)
    {
        NSArray *array = [obj.refers valueForKey:[NSString stringWithFormat:@"%@%@",@"placerefer",loginId]];
        if(array !=nil && [array isKindOfClass:[array class]])
        {
            return array;
            
        }
    }
    return nil;
}

- (void)deletePlaceReferWithLoginId:(NSString *)loginId
{
    NSManagedObjectContext *context=[self managedObjectContext];
    //Contacts
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MeData"];
    NSArray *contextArray   = [context executeFetchRequest:request error:nil];
    int i =0;
    for (NSManagedObject *object in contextArray)
    {
        MeData *meData = (MeData *)[contextArray objectAtIndex:i];
        NSArray *array = [meData.refers valueForKey:[NSString stringWithFormat:@"%@%@",@"placerefer",loginId]];
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            [context deleteObject:object];
            
        }
        i++;
    }
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
}

#pragma mark - Product
- (void)setProdcutReferWithLoginId:(NSString *)loginId response:(NSDictionary *)response
{
    [self deletePlaceReferWithLoginId:loginId];
    NSManagedObjectContext *context=[self managedObjectContext];
    MeData *me = (MeData *)[NSEntityDescription insertNewObjectForEntityForName:@"MeData" inManagedObjectContext:context];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:[response valueForKey:@"response"] forKey:[NSString stringWithFormat:@"%@%@",@"productRefer",loginId]];
    [me setRefers:dictionary];
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
}

- (NSArray *)getProducteReferWithLoginId:(NSString *)loginId
{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *req=[[NSFetchRequest alloc] initWithEntityName:@"MeData"];
    NSArray *contextarray  =[context executeFetchRequest:req error:nil];
    for (MeData *obj in contextarray)
    {
        NSArray *array = [obj.refers valueForKey:[NSString stringWithFormat:@"%@%@",@"productRefer",loginId]];
        if(array !=nil && [array isKindOfClass:[array class]])
        {
            return array;
            
        }
    }
    return nil;
}

- (void)deleteProductReferWithLoginId:(NSString *)loginId
{
    NSManagedObjectContext *context=[self managedObjectContext];
    //Contacts
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MeData"];
    NSArray *contextArray   = [context executeFetchRequest:request error:nil];
    int i =0;
    for (NSManagedObject *object in contextArray)
    {
        MeData *meData = (MeData *)[contextArray objectAtIndex:i];
        NSArray *array = [meData.refers valueForKey:[NSString stringWithFormat:@"%@%@",@"productRefer",loginId]];
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            [context deleteObject:object];
            
        }
        i++;
    }
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
}

#pragma mark - Service
- (void)setServiceReferWithLoginId:(NSString *)loginId response:(NSDictionary *)response
{
    [self deletePlaceReferWithLoginId:loginId];
    NSManagedObjectContext *context=[self managedObjectContext];
    MeData *me = (MeData *)[NSEntityDescription insertNewObjectForEntityForName:@"MeData" inManagedObjectContext:context];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:[response valueForKey:@"response"] forKey:[NSString stringWithFormat:@"%@%@",@"serviceRefer",loginId]];
    [me setRefers:dictionary];
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
}

- (NSArray *)getServiceReferWithLoginId:(NSString *)loginId
{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *req=[[NSFetchRequest alloc] initWithEntityName:@"MeData"];
    NSArray *contextarray  =[context executeFetchRequest:req error:nil];
    for (MeData *obj in contextarray)
    {
        NSArray *array = [obj.refers valueForKey:[NSString stringWithFormat:@"%@%@",@"serviceRefer",loginId]];
        if(array !=nil && [array isKindOfClass:[array class]])
        {
            return array;
            
        }
    }
    return nil;
}

- (void)deleteServiceReferWithLoginId:(NSString *)loginId
{
    NSManagedObjectContext *context=[self managedObjectContext];
    //Contacts
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MeData"];
    NSArray *contextArray   = [context executeFetchRequest:request error:nil];
    int i =0;
    for (NSManagedObject *object in contextArray)
    {
        MeData *meData = (MeData *)[contextArray objectAtIndex:i];
        NSArray *array = [meData.refers valueForKey:[NSString stringWithFormat:@"%@%@",@"serviceRefer",loginId]];
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            [context deleteObject:object];
            
        }
        i++;
    }
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
}

#pragma mark - Web
- (void)setWebReferWithLoginId:(NSString *)loginId response:(NSDictionary *)response
{
    [self deletePlaceReferWithLoginId:loginId];
    NSManagedObjectContext *context=[self managedObjectContext];
    MeData *me = (MeData *)[NSEntityDescription insertNewObjectForEntityForName:@"MeData" inManagedObjectContext:context];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:[response valueForKey:@"response"] forKey:[NSString stringWithFormat:@"%@%@",@"webRefer",loginId]];
    [me setRefers:dictionary];
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
}

- (NSArray *)getWebReferWithLoginId:(NSString *)loginId
{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *req=[[NSFetchRequest alloc] initWithEntityName:@"MeData"];
    NSArray *contextarray  =[context executeFetchRequest:req error:nil];
    for (MeData *obj in contextarray)
    {
        NSArray *array = [obj.refers valueForKey:[NSString stringWithFormat:@"%@%@",@"webRefer",loginId]];
        if(array !=nil && [array isKindOfClass:[array class]])
        {
            return array;
            
        }
    }
    return nil;
}

- (void)deleteWebReferWithLoginId:(NSString *)loginId
{
    NSManagedObjectContext *context=[self managedObjectContext];
    //Contacts
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MeData"];
    NSArray *contextArray   = [context executeFetchRequest:request error:nil];
    int i =0;
    for (NSManagedObject *object in contextArray)
    {
        MeData *meData = (MeData *)[contextArray objectAtIndex:i];
        NSArray *array = [meData.refers valueForKey:[NSString stringWithFormat:@"%@%@",@"webRefer",loginId]];
        if(array !=nil && [array isKindOfClass:[array class]]){
            
            [context deleteObject:object];
            
        }
        i++;
    }
    NSError *error=nil;
    if(![context save:&error])
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
}



@end
