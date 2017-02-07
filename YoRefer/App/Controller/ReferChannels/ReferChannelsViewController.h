//
//  ReferChannelsViewController.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 11/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "BaseViewController.h"
#import "ReferChannelsTableViewCell.h"

@interface ReferChannelsViewController : BaseViewController<ReferChannel>


- (void)selectIndexPath:(NSIndexPath *)indexPath;


@end
