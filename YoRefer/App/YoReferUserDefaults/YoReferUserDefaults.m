//
//  YoReferUserDefaults.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 06/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "YoReferUserDefaults.h"
#import "Configuration.h"





@implementation YoReferUserDefaults



+ (NSUserDefaults *)shareUserDefaluts
{
    
   // NSLog(@"%@",[Configuration appGroupName]);
    
    static NSUserDefaults *_shareUserDefaluts = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       
        _shareUserDefaluts = [[NSUserDefaults alloc]initWithSuiteName:[Configuration appGroupName]];
        
    });
    
    return _shareUserDefaluts;

}


@end
