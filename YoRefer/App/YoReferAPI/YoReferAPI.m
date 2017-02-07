
//
//  YoReferAPI.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 08/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "YoReferAPI.h"
#import "Configuration.h"
#import "UserManager.h"

NSString *const requestTypePost = @"POST";
NSString *const requestTypeGet  = @"GET";
NSString *const ContentType     = @"Content-Type";
NSString *const ContentLenght   = @"Content-Length";
NSString * const boundary = @"unique-consistent-string";

@implementation YoReferAPI


+ (YoReferAPI *)sharedAPI
{
    
    static YoReferAPI *_sharedAPI = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedAPI = [[YoReferAPI alloc]init];
        
    });
    
    return _sharedAPI;
    
}

#pragma mark - Login 

- (void)loginWithParams:(NSDictionary *)params
                        completionHandler:(APICompletionHandler)apiCompletionHandler
{
    [self postUrlRequestWithParams:params withCompletionHandler:apiCompletionHandler url:@"user/login/"];
}


- (void)signUpWithParams:(NSDictionary *)params
      completionHandler:(APICompletionHandler)apiCompletionHandler
{
    
    [self postUrlRequestWithParams:params withCompletionHandler:apiCompletionHandler url:@"/user/"];
    
    
}

- (void)forgotPasswordWithParam:(NSDictionary *)params
              completionHandler:(APICompletionHandler)apiCompletionHandler
{
    [self postUrlRequestWithParams:params withCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"user/reset"]];
    
}

- (void)facebookLoginWithParams:(NSDictionary *)params
              completionHandler:(APICompletionHandler)apiCompletionHandler
{
    
    [self postUrlRequestWithParams:params withCompletionHandler:apiCompletionHandler url:@"user/fblogin"];
    
    
}


#pragma mark - Device Token

- (void)tokenWithParams:(NSDictionary *)params completionHandler:(APICompletionHandler)apiCompletionHandler
{
        
    [self postUrlRequestWithParams:params withCompletionHandler:apiCompletionHandler url:@"user/subscribe"];
}



#pragma mark - Me (Profile)
//Places
- (void)getPlaceReferWithParam:(NSDictionary *)param completionHandler:(APICompletionHandler)apiCompletionHandler
{
    if ([[param objectForKey:@"number"] isEqualToString:@"(null)"] || [[param objectForKey:@"number"] isEqualToString:@""]) {
        [self getUrlRequestWithCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"user/userEntityFeed/%@/%@",[param objectForKey:@"email"],[param valueForKey:@"referType"]]];
    }
    else
    {
        [self getUrlRequestWithCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"user/userEntityFeed/%@/%@",[param objectForKey:@"number"],[param valueForKey:@"referType"]]];
    }
}

//Product
- (void)getProductReferWithParam:(NSDictionary *)param completionHandler:(APICompletionHandler)apiCompletionHandler
{
    if ([[param objectForKey:@"number"] isEqualToString:@"(null)"] || [[param objectForKey:@"number"] isEqualToString:@""]) {

        [self getUrlRequestWithCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"user/userEntityFeed/%@/%@",[param objectForKey:@"email"],[param valueForKey:@"referType"]]];
    }
    else
    {
        [self getUrlRequestWithCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"user/userEntityFeed/%@/%@",[param objectForKey:@"number"],[param valueForKey:@"referType"]]];
    }
}

//Service
- (void)getServiceReferWithParam:(NSDictionary *)param completionHandler:(APICompletionHandler)apiCompletionHandler
{
    if ([[param objectForKey:@"number"] isEqualToString:@"(null)"] || [[param objectForKey:@"number"] isEqualToString:@""]) {
        [self getUrlRequestWithCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"user/userEntityFeed/%@/%@",[param objectForKey:@"email"],[param valueForKey:@"referType"]]];
    }
    else{
        [self getUrlRequestWithCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"user/userEntityFeed/%@/%@",[param objectForKey:@"number"],[param valueForKey:@"referType"]]];
    }
    
}

//Web
- (void)getWebReferWithParam:(NSDictionary *)param completionHandler:(APICompletionHandler)apiCompletionHandler
{
    if ([[param objectForKey:@"number"] isEqualToString:@"(null)"] || [[param objectForKey:@"number"] isEqualToString:@""]) {
        [self getUrlRequestWithCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"user/userEntityFeed/%@/%@",[param objectForKey:@"email"],[param valueForKey:@"referType"]]];
    }
    else{
         [self getUrlRequestWithCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"user/userEntityFeed/%@/%@",[param objectForKey:@"number"],[param valueForKey:@"referType"]]];
    }
}


- (void)getReferWithParam:(NSDictionary *)param
        completionHandler:(APICompletionHandler)apiCompletionHandler
{
    
    [self getUrlRequestWithCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"user/userEntityFeed/%@",[param objectForKey:@"number"]]];
    
}

- (void)getFriendwithParam:(NSMutableDictionary *)param
         completionHandler:(APICompletionHandler)apiCompletionHandler
{
    if ([[param objectForKey:@"number"] isEqualToString:@"(null)"] || [[param objectForKey:@"number"] isEqualToString:@""]) {
        [self getUrlRequestWithCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"user/connections/%@",[param valueForKey:@"email"]]];
    }
    else{
        [self getUrlRequestWithCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"user/connections/%@",[param valueForKey:@"number"]]];
    }
}

- (void)getAskWithParam:(NSMutableDictionary *)params
      completionHandler:(APICompletionHandler)apiCompletionHandler
{
    if ([[params objectForKey:@"number"] isEqualToString:@"(null)"] || [[params objectForKey:@"number"] isEqualToString:@""]){
        [self getUrlRequestWithCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"ask/find/%@?limit=%@&before=%@",[params valueForKey:@"email"],[params valueForKey:@"limit"],[params valueForKey:@"before"]]];
    }
    else{
        [self getUrlRequestWithCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"ask/find/%@?limit=%@&before=%@",[params valueForKey:@"number"],[params valueForKey:@"limit"],[params valueForKey:@"before"]]];
    }
}

- (void)getShortenUrlWithParam:(NSMutableDictionary *)params
      completionHandler:(APICompletionHandler)apiCompletionHandler
{
    
//    [self getUrlRequestWithCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"https://www.googleapis.com/urlshortener/v1/url?key=AIzaSyBz60It9CNkb-c5OiulMpYqMPe2qWTyR5A"]];
    
    [self postShortenUrlRequestWithParams:params withCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"https://www.googleapis.com/urlshortener/v1/url?key=AIzaSyBz60It9CNkb-c5OiulMpYqMPe2qWTyR5A"]];
}




- (void)getFeedsWithParams:(NSMutableDictionary *)params
         completionHandler:(APICompletionHandler)apiCompletionHandler
{
    NSString *number = [params objectForKey:@"number"];
    NSString *limit = [params objectForKey:@"limit"];
    NSString *before = [params objectForKey:@"before"];
    NSString *email = [params objectForKey:@"email"];
    
    [params removeObjectForKey:@"number"];
    [params removeObjectForKey:@"limit"];
    [params removeObjectForKey:@"before"];
    [params removeObjectForKey:@"email"];
    
    if ([[params valueForKey:@"feed"] isEqualToString:@"300"])
    {
        [params removeObjectForKey:@"feed"];
        
        if ([number isEqualToString:@"(null)"] || [number isEqualToString:@""]){
            [self postUrlRequestWithParams:nil withCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"refer/search/fromto/%@?limit=%@&before=%@",email,limit,before]];
        }
        else{
            [self postUrlRequestWithParams:nil withCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"refer/search/fromto/%@?limit=%@&before=%@",number,limit,before]];
        }
        
        
    }else if ([[params valueForKey:@"feed"] isEqualToString:@"301"])
    {
        [params removeObjectForKey:@"feed"];
        
        if ([number isEqualToString:@"(null)"] || [number isEqualToString:@""]){
            [self postUrlRequestWithParams:params withCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"refer/search/from/%@?limit=%@&before=%@",email,limit,before]];
        }
        else{
            [self postUrlRequestWithParams:params withCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"refer/search/from/%@?limit=%@&before=%@",number,limit,before]];
        }
        
    }else{
        
        [params removeObjectForKey:@"feed"];
        
        if ([number isEqualToString:@"(null)"] || [number isEqualToString:@""]){
            [self postUrlRequestWithParams:params withCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"refer/search/to/%@?limit=%@&before=%@",email,limit,before]];
        }
        else
        {
            [self postUrlRequestWithParams:params withCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"refer/search/to/%@?limit=%@&before=%@",number,limit,before]];
        }
        
    }
    
}

// Dev...
#pragma Search For Me(Profile)

- (void)searchRefersByCategory:(NSMutableDictionary *)params
             completionHandler:(APICompletionHandler)apiCompletionHandler
{
//  http://54.165.84.198:8080/irefer/api/user/userEntityFeed/query/%2B918817569622?query=HDFC%20Bank

    if ([[params objectForKey:@"number"] isEqualToString:@"(null)"] || [[params objectForKey:@"number"] isEqualToString:@""]){
        
        NSString* encodedUrl = [[NSString stringWithFormat:@"user/userEntityFeed/query/%@?query=%@",[params valueForKey:@"email"],[params valueForKey:@"query"]] stringByAddingPercentEscapesUsingEncoding:
                                NSUTF8StringEncoding];
        
        [self getUrlRequestWithCompletionHandler:apiCompletionHandler url:encodedUrl];
    }
    else{
        NSString* encodedUrl = [[NSString stringWithFormat:@"user/userEntityFeed/query/%@?query=%@",[params valueForKey:@"number"],[params valueForKey:@"query"]] stringByAddingPercentEscapesUsingEncoding:
                                NSUTF8StringEncoding];
        
        [self getUrlRequestWithCompletionHandler:apiCompletionHandler url:encodedUrl];
    }
}

- (void)searchAsksByCategory:(NSMutableDictionary *)params
           completionHandler:(APICompletionHandler)apiCompletionHandler
{
    // http://54.165.84.198:8080/irefer/api/ask/find/%2B9188175669622?query=AC%20repair

    if ([[params objectForKey:@"number"] isEqualToString:@"(null)"] || [[params objectForKey:@"number"] isEqualToString:@""]){

        NSString* encodedUrl = [[NSString stringWithFormat:@"ask/find/%@?query=%@",[params valueForKey:@"email"], [params valueForKey:@"query"]] stringByAddingPercentEscapesUsingEncoding:
                                NSUTF8StringEncoding];
        [self getUrlRequestWithCompletionHandler:apiCompletionHandler url:encodedUrl];
    }
    else{
        NSString* encodedUrl = [[NSString stringWithFormat:@"ask/find/%@?query=%@",[params valueForKey:@"number"], [params valueForKey:@"query"]] stringByAddingPercentEscapesUsingEncoding:
                                NSUTF8StringEncoding];
        [self getUrlRequestWithCompletionHandler:apiCompletionHandler url:encodedUrl];
    }

}

- (void)searchFeedsByCategory:(NSMutableDictionary *)params
            completionHandler:(APICompletionHandler)apiCompletionHandler
{
    //  http://54.165.84.198:8080/irefer/api/refer/search/fromto/%2B918817569622?query=Place
    //  http://54.165.84.198:8080/irefer/api/refer/search/fromto/%2B919972299559?query=Biscuits

    /*
    NSString* encodedUrl = [[NSString stringWithFormat:@"refer/search/fromto/%@?query=%@",[params valueForKey:@"number"], [params valueForKey:@"query"]] stringByAddingPercentEscapesUsingEncoding:
                            NSUTF8StringEncoding];
    
    [self getUrlRequestWithCompletionHandler:apiCompletionHandler url:encodedUrl];
    */
    NSString* encodedUrl;
    
    if ([[params valueForKey:@"query"] isEqualToString:@""]) {
        
        if ([[params objectForKey:@"number"] isEqualToString:@"(null)"] || [[params objectForKey:@"number"] isEqualToString:@""]){

            encodedUrl = [[NSString stringWithFormat:@"refer/search/fromto/%@?",[params valueForKey:@"email"]] stringByAddingPercentEscapesUsingEncoding:
                          NSUTF8StringEncoding];
        }
        else{
            encodedUrl = [[NSString stringWithFormat:@"refer/search/fromto/%@?",[params valueForKey:@"number"]] stringByAddingPercentEscapesUsingEncoding:
                          NSUTF8StringEncoding];
        }
        
    }
    else
    {
        if ([[params objectForKey:@"number"] isEqualToString:@"(null)"] || [[params objectForKey:@"number"] isEqualToString:@""]){

            encodedUrl = [[NSString stringWithFormat:@"refer/search/fromto/%@?query=%@",[params valueForKey:@"email"], [params valueForKey:@"query"]] stringByAddingPercentEscapesUsingEncoding:
                          NSUTF8StringEncoding];
        }
        else{
        
            encodedUrl = [[NSString stringWithFormat:@"refer/search/fromto/%@?query=%@",[params valueForKey:@"number"], [params valueForKey:@"query"]] stringByAddingPercentEscapesUsingEncoding:
                          NSUTF8StringEncoding];
        }
        

    }
    [self postUrlRequestWithParams:params withCompletionHandler:apiCompletionHandler url:encodedUrl];

}

- (void)searchFriendsByCategory:(NSMutableDictionary *)params
            completionHandler:(APICompletionHandler)apiCompletionHandler
{
 
//  http://54.165.84.198:8080/irefer/api/user/connections/%2B918817569622?query=Sree

    if ([[params objectForKey:@"number"] isEqualToString:@"(null)"] || [[params objectForKey:@"number"] isEqualToString:@""]){

        NSString* encodedUrl = [[NSString stringWithFormat:@"user/connections/%@?query=%@",[params valueForKey:@"email"], [params valueForKey:@"query"]] stringByAddingPercentEscapesUsingEncoding:
                                NSUTF8StringEncoding];
        [self getUrlRequestWithCompletionHandler:apiCompletionHandler url:encodedUrl];
    }
    else{
    
        NSString* encodedUrl = [[NSString stringWithFormat:@"user/connections/%@?query=%@",[params valueForKey:@"number"], [params valueForKey:@"query"]] stringByAddingPercentEscapesUsingEncoding:
                                NSUTF8StringEncoding];
        [self getUrlRequestWithCompletionHandler:apiCompletionHandler url:encodedUrl];
    }
}

//...

#pragma mark - Featured

- (void)featuredWithParam:(NSDictionary *)params
        completionHandler:(APICompletionHandler)apiCompletionHandler
{
    [self postUrlRequestWithParams:params withCompletionHandler:apiCompletionHandler url:@"refer/featured"];
}

- (void)searchFeaturedbyCategory:(NSDictionary *)params
               completionHandler:(APICompletionHandler)apiCompletionHandler
{
    //  http://54.165.84.198:8080/irefer/api/refer/featured?query=UB%20City

    NSString* encodedUrl;
    
    if ([[params valueForKey:@"query"] isEqualToString:@""]) {
        encodedUrl = [[NSString stringWithFormat:@"refer/featured?"] stringByAddingPercentEscapesUsingEncoding:
                      NSUTF8StringEncoding];
    }
    else{
        encodedUrl = [[NSString stringWithFormat:@"refer/featured?query=%@",[params valueForKey:@"query"]] stringByAddingPercentEscapesUsingEncoding:
                      NSUTF8StringEncoding];
    }
    
    
    [self postUrlRequestWithParams:params withCompletionHandler:apiCompletionHandler url:encodedUrl];
}


#pragma mark  - Entity

- (void)entityWithParams:(NSDictionary *)params
                  entityId:(NSString *)entityId
                  completionHandler:(APICompletionHandler)apiCompletionHandler
{
    
 
    [self postUrlRequestWithParams:params withCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"refer/entity/%@",entityId]];
    
    
    
}



#pragma mark  - Home

- (void)carouselWithParam:(NSDictionary *)params
        completionHandler:(APICompletionHandler)apiCompletionHandler
{
    [self getUrlRequestWithCompletionHandler:apiCompletionHandler url:@"refer/home/carousel"];
}


- (void)searchByCategory:(NSMutableDictionary *)params
       completionHandler:(APICompletionHandler)apiCompletionHandler
{
    
    NSString *limit = [params objectForKey:@"limit"];
    NSString *before = [params objectForKey:@"before"];
    
    [params removeObjectForKey:@"limit"];
    [params removeObjectForKey:@"before"];
    
    [self postUrlRequestWithParams:params withCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"refer/lookup?limit=%@&before=%@",limit,before]];
    
}

- (void)referWithParams:(NSMutableDictionary *)params
      completionHandler:(APICompletionHandler)apiCompletionHandler
{
    
    NSString *limit = [params objectForKey:@"limit"];
    NSString *before = [params objectForKey:@"before"];
    
    [params removeObjectForKey:@"limit"];
    [params removeObjectForKey:@"before"];
    
    [self postUrlRequestWithParams:params withCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"refer/lookup?limit=%@&before=%@",limit,before]];
    
}

- (void)askWithParams:(NSMutableDictionary *)params
    completionHandler:(APICompletionHandler)apiCompletionHandler
{
    
    NSString *limit = [params objectForKey:@"limit"];
    NSString *before = [params objectForKey:@"before"];
    
    [params removeObjectForKey:@"limit"];
    [params removeObjectForKey:@"before"];
    
    [self postUrlRequestWithParams:params withCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"ask/find?limit=%@&before=%@",limit,before]];
    
}

//Dev...

//View Refers Search
- (void)getViewRefersSearchWithParam:(NSDictionary *)param completionHandler:(APICompletionHandler)apiCompletionHandler
{
    // http://54.165.84.198:8080/irefer/api/refer/lookup
    
     [self postUrlRequestWithParams:param withCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"refer/lookup"]];
    
}

//View Asks Search
- (void)getAsksSearchWithParam:(NSMutableDictionary *)param completionHandler:(APICompletionHandler)apiCompletionHandler
{
    
    // http://54.165.84.198:8080/irefer/api/ask/find?query=dunkin
    
    NSString *encodedUrl = [[NSString stringWithFormat:@"ask/find?query=%@",[param valueForKey:@"query"]] stringByAddingPercentEscapesUsingEncoding:
                            NSUTF8StringEncoding];
    [param removeObjectForKey:@"query"];
    [self postUrlRequestWithParams:param withCompletionHandler:apiCompletionHandler url:encodedUrl];

}

//Entities Search
- (void)getEntitiesSearchWithParam:(NSMutableDictionary *)param completionHandler:(APICompletionHandler)apiCompletionHandler
{
    // http://54.165.84.198:8080/irefer/api/refer/entitylookup?query=dunkin

    NSString *encodedUrl = [[NSString stringWithFormat:@"refer/entitylookup?query=%@",[param valueForKey:@"query"]] stringByAddingPercentEscapesUsingEncoding:
                  NSUTF8StringEncoding];
    [param removeObjectForKey:@"query"];
    [self postUrlRequestWithParams:param withCompletionHandler:apiCompletionHandler url:encodedUrl];
    
}


#pragma mark - Categories

- (void)categoriesWithParam:(NSDictionary *)params
        completionHandler:(APICompletionHandler)apiCompletionHandler
{
     [self getUrlRequestWithCompletionHandler:apiCompletionHandler url:@"refer/home/categories"];
}

- (void)searchCategoryByCategory:(NSDictionary *)params
               completionHandler:(APICompletionHandler)apiCompletionHandler
{
    // http://54.165.84.198:8080/irefer/api/refer/entitylookup?query=dunkin
    
    NSString* encodedUrl;
    
    if ([[params valueForKey:@"query"] isEqualToString:@""]) {
        encodedUrl = [[NSString stringWithFormat:@"refer/entitylookup?"] stringByAddingPercentEscapesUsingEncoding:
                      NSUTF8StringEncoding];
    }
    else{
        encodedUrl = [[NSString stringWithFormat:@"refer/entitylookup?query=%@",[params valueForKey:@"query"]] stringByAddingPercentEscapesUsingEncoding:
                      NSUTF8StringEncoding];
    }
    
    
    [self postUrlRequestWithParams:params withCompletionHandler:apiCompletionHandler url:encodedUrl];
}


#pragma mark - Change Password

- (void)changePasswordWithParams:(NSDictionary *)params
               completionHandler:(APICompletionHandler)apiCompletionHandler
{
    
    [self postUrlRequestWithParams:params withCompletionHandler:apiCompletionHandler url:@"user/change/"];
    
    
}

#pragma mark - Change Profile

- (void)changeProfileWithParams:(NSDictionary *)params
              completionHandler:(APICompletionHandler)apiCompletionHandler
{
    
    [self postUrlRequestWithParams:params withCompletionHandler:apiCompletionHandler url:@"user/update/"];
    
    
}


#pragma mark - ReferNow

- (void)getMessagesWithCompletionHandler:(APICompletionHandler)apiCompletionHandler
{
    [self getUrlRequestWithCompletionHandler:apiCompletionHandler url:@"refer/messages"];
}

- (void)getCategoryWithCompletionHandler:(APICompletionHandler)apiCompletionHandler
{
    
    [self getUrlRequestWithCompletionHandler:apiCompletionHandler url:@"refer/categories"];
    
    
}

- (void)getReferCodeWithCompletionHandler:(APICompletionHandler)apiCompletionHandler
{
    
    [self getUrlRequestWithCompletionHandler:apiCompletionHandler url:@"refer/getcode"];
    
    
}


- (void)referChannelWithParams:(NSMutableDictionary *)params
                     completionHandler:(APICompletionHandler)apiCompletionHandler
{
    
    [self postUrlRequestWithParams:params withCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"refer/"]];
    
}

- (void)referWebChannelWithParams:(NSMutableDictionary *)params
             completionHandler:(APICompletionHandler)apiCompletionHandler
{
    
    [self postUrlRequestWithParams:params withCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"refer/"]];
    
}

#pragma mark - Ask now

- (void)queryWithParams:(NSMutableDictionary *)params
             completionHandler:(APICompletionHandler)apiCompletionHandler
{
    
    [self postUrlRequestWithParams:params withCompletionHandler:apiCompletionHandler url:@"/ask"];
    
}



#pragma mark - Map

- (void)currentLocationOfferWithParams:(NSMutableDictionary *)params
                 completionHandler:(APICompletionHandler)apiCompletionHandler
{
    NSInteger  page = [[params valueForKey:@"page"] integerValue];
    NSInteger  limit = [[params valueForKey:@"limit"] integerValue];
    [params removeObjectForKey:@"page"];
    [params removeObjectForKey:@"limit"];
    [self postUrlRequestWithParams:params withCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"refer/entitylookup?limit=%ld&page=%ld",limit,page]];
}

- (void)mapSearchWithParams:(NSMutableDictionary *)params
                     completionHandler:(APICompletionHandler)apiCompletionHandler
{
    [params removeObjectForKey:@"page"];
    [params removeObjectForKey:@"limit"];
    [self postUrlRequestWithParams:params withCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"refer/entitylookup?query=%@",[params objectForKey:@"query"]]];
}




#pragma mark - Lat and Long

- (void)getLocationDetailWithParma:(NSString *)param CompletionHandler:(APICompletionHandler)apiCompletionHandler
{
    
    [self getUrlRequestWithCompletionHandler:apiCompletionHandler url:[NSString stringWithFormat:@"refer/geocode?latlng=%@",param]];
    
}

#pragma mark - URL get request

- (void)getUrlRequestWithCompletionHandler:(APICompletionHandler)apiCompletionHandler url:(NSString *)url
{
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",[[Configuration shareConfiguration] baseURL],url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:strUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:[[[Configuration shareConfiguration] timeInterval] integerValue]];
    [request setHTTPMethod:requestTypeGet];
    if ([[UserManager shareUserManager] sessionToken] != nil && [[[UserManager shareUserManager] sessionToken] length] > 0)
    {
        [request setValue:[[UserManager shareUserManager] sessionToken] forHTTPHeaderField:@"sessionToken"];
    }
    
    NSOperationQueue *quue = [NSOperationQueue currentQueue];
    [quue cancelAllOperations];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]options:0 error:NULL];
        
        if (error == nil && [dictionary count] > 0)
        {
            apiCompletionHandler(dictionary,nil);
            
        }else {
            
            apiCompletionHandler(nil,error);
            
        }
        
    }];

}

#pragma mark - URL post request

- (void)postUrlRequestWithParams:(NSDictionary *)params withCompletionHandler:(APICompletionHandler)apiCompletionHandler url:(NSString *)postValue
{
    NSString *url = [NSString stringWithFormat:@"%@%@",[[Configuration shareConfiguration] baseURL],postValue];
    NSData *data;NSString *jsonString;
    NSData *postData;
    NSString *postLength = @"";
    if ([params count] > 0){
        
        data = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
        jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        postData = [jsonString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:[[[Configuration shareConfiguration] timeInterval] integerValue]];
    [request setHTTPMethod:requestTypePost];
    [request setValue:postLength forHTTPHeaderField:ContentLenght];
    [request setValue:@"application/json" forHTTPHeaderField:ContentType];
    [request setHTTPBody:postData];
    
    if ([[UserManager shareUserManager] sessionToken] != nil && [[[UserManager shareUserManager] sessionToken] length] > 0)
    {
        
        [request setValue:[[UserManager shareUserManager] sessionToken] forHTTPHeaderField:@"sessionToken"];
        
    }
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
         NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]options:0 error:NULL];
        
        if (error == nil && [dictionary count] > 0)
        {
            apiCompletionHandler(dictionary,nil);
            
        }else {
            
            apiCompletionHandler(nil,error);
            
        }
        
    }];
    
    
}


#pragma mark - Shorten Url Post Request

- (void)postShortenUrlRequestWithParams:(NSDictionary *)params withCompletionHandler:(APICompletionHandler)apiCompletionHandler url:(NSString *)postValue
{
    NSString *url = [NSString stringWithFormat:@"%@",postValue];
    NSData *data;NSString *jsonString;
    NSData *postData;
    NSString *postLength = @"";
    if ([params count] > 0){
        
        data = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
        jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        postData = [jsonString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:[[[Configuration shareConfiguration] timeInterval] integerValue]];
    [request setHTTPMethod:requestTypePost];
    [request setValue:postLength forHTTPHeaderField:ContentLenght];
    [request setValue:@"application/json" forHTTPHeaderField:ContentType];
    [request setHTTPBody:postData];
    
    if ([[UserManager shareUserManager] sessionToken] != nil && [[[UserManager shareUserManager] sessionToken] length] > 0)
    {
        
        [request setValue:[[UserManager shareUserManager] sessionToken] forHTTPHeaderField:@"sessionToken"];
        
    }
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]options:0 error:NULL];
        
        if (error == nil && [dictionary count] > 0)
        {
            apiCompletionHandler(dictionary,nil);
            
        }else {
            
            apiCompletionHandler(nil,error);
            
        }
        
    }];
    
    
}


#pragma mark - Category

- (void)categoryWithParams:(NSDictionary *)params
         completionHandler:(APICompletionHandler)apiCompletionHandler
{
    
    [self postUrlRequestWithParams:params withCompletionHandler:apiCompletionHandler url:@"refer/entitylookup"];
    
    
}

#pragma mark - Upload image

- (void)uploadImageWithParam:(NSDictionary *)param
           completionHandler:(APICompletionHandler)apiCompletionHandler
{
    
    [self imageUrlRequestWithParam:param withCompletionHandler:apiCompletionHandler url:@"file/"];
    
    
}


- (void)imageUrlRequestWithParam:(NSDictionary *)param withCompletionHandler:(APICompletionHandler)apiCompletionHandler url:(NSString *)postValue
{
    
    
    NSData *imageData =  UIImageJPEGRepresentation((UIImage *)[param objectForKey:@"profileImage"],1.0);
    NSMutableData *body = [NSMutableData data];
    [body appendData:[self appendImageBodyDataWithKey:@"image" data:imageData]];
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *request = [self requestManger];
    [request setHTTPBody:body];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[body length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:requestTypePost];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[[Configuration shareConfiguration] baseURL],postValue]]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]options:0 error:NULL];
        
        if (error == nil && [dictionary count] > 0)
        {
            apiCompletionHandler(dictionary,nil);
            
        }else {
            
            apiCompletionHandler(nil,error);
            
        }
        
    }];

    
    
}

#pragma mark -

- (NSMutableURLRequest *)requestManger
{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:180];
    [request setHTTPMethod:@"POST"];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    return request;
    
}


- (NSMutableData *)appendImageBodyDataWithKey:(NSString *)key data:(NSData *)data
{
    
    NSMutableData *bodyData = [NSMutableData data];
    [bodyData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:data];
    [bodyData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return bodyData;
    
}


@end
