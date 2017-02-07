//
//  MediaViewController.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 08/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol Media <NSObject>

- (void)getProfilePicture:(NSMutableDictionary *)dict;

@end

@interface YoReferMedia : NSObject

@property (nonatomic, weak) id<Media>delegate;

+ (YoReferMedia *)shareMedia;

- (void)setMediaWithDelegate:(id<Media>)delegate title:(NSString *)mediaTitle;

@end
