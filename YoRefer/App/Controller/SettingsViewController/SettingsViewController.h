//
//  SettingsViewController.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 05/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "BaseViewController.h"
#import "SettingsTableViewCell.h"

@interface SettingsViewController : BaseViewController<settings>

- (void)pushSettingType:(settingsType)settingsType;

@end
