//
//  Configuration.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 05/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "Configuration.h"

@interface Configuration ()

@property (nonatomic, strong) NSDictionary *infoDictionary;

@end

@implementation Configuration

+ (Configuration *)shareConfiguration
{
    
    static Configuration *_shareConfiguration = nil;
    static dispatch_once_t onceToke ;
    dispatch_once(&onceToke, ^{
        
        _shareConfiguration = [[Configuration alloc]init];
        
    });
    
    return _shareConfiguration;
    
}



- (instancetype)init
{
    
    self = [super init];
    if(self)
    {
        self.infoDictionary = [[NSBundle mainBundle] infoDictionary];
    }
    
    return self;
}


- (UIFont *)yoReferFontWithSize:(CGFloat)size
{
    
    return [UIFont systemFontOfSize:size];
    
    
}

- (UIFont *)yoReferBoldFontWithSize:(CGFloat)size
{
    
    return [UIFont boldSystemFontOfSize:size];
    
    
}

+ (NSString *)appGroupName
{
    
    return @"com.UDIV.in";
    
}

- (NSString *)appName
{
    
    return NSLocalizedString([self.infoDictionary objectForKey:@"AppTitle"], @"");
    
}

- (NSString *)errorMessage
{
    
    return NSLocalizedString([self.infoDictionary objectForKey:@"ErrorMessage"], @"");
    
}

-(NSString *)baseURL
{
    
    return [self.infoDictionary objectForKeyedSubscript:@"BaseURL"];
    
}

- (NSString *)timeInterval
{
    
    return [self.infoDictionary objectForKey:@"TimeInterval"];
}

- (NSString *)connectionStatus
{
    
    return [self.infoDictionary objectForKey:@"connectionStatus"];
}

- (NSString *)getTermsAndConditions
{
    
    return [self.infoDictionary valueForKey:@"TermsAndConditions"];
    
}

- (NSString *)getPrivacyPolicy
{
    
    return [self.infoDictionary valueForKey:@"PrivacyPolicy"];
    
}

- (NSString *)getAboutUs
{
    
    return [self.infoDictionary valueForKey:@"AboutUs"];
    
}

- (NSString *)getFeedBackRecipient
{
    
    return [self.infoDictionary valueForKey:@"FeedBackRecipient"];
    
}
- (NSString *)appVersion
{
    
    return [self.infoDictionary valueForKey:@"CFBundleShortVersionString"];
    
}

- (NSString *)buildVersion
{
    
    return [self.infoDictionary valueForKey:@"CFBundleVersion"];
    
}

@end
