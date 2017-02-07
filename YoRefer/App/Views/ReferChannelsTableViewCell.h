//
//  ReferChannelsTableViewCell.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 11/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReferChannel <NSObject>

- (void)selectIndexPath:(NSIndexPath *)indexPath;

@end

@interface ReferChannelsTableViewCell : UITableViewCell


- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath delegate:(id<ReferChannel>)delegate;


@property (nonatomic, weak) id <ReferChannel>delegate;

@end

extern NSString * const kReferChannelIdentifier;