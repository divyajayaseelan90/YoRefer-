//
//  LocalReferAsk.h
//  YoRefer
//
//  Created by Bhaskar C M on 2/17/16.
//  Copyright © 2016 UDVI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalReferAsk : NSObject
+ (LocalReferAsk *)shareInstanceLocalAsk;
- (void)refer;
@end
