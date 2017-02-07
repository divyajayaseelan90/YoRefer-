//
//  MeData.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 15/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MeData : NSObject

@property (nonatomic, strong) NSMutableDictionary *refers;
@property (nonatomic, strong) NSMutableDictionary *feeds;
@property (nonatomic, strong) NSMutableDictionary *friends;
@property (nonatomic, strong) NSMutableDictionary *queries;

@end
