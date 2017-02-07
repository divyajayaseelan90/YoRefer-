//
//  DocumentDirectory.h
//  eMyPA
//
//  Created by Sunilkumar Basappa on 02/09/15.
//  Copyright (c) 2015 iNube Software Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DocumentDirectory : NSObject

- (NSString *)addDirectoryWithPath:(NSString *)path image:(UIImage *)image imageName:(NSString *)imageName;
- (NSArray *)getCountOfDirectoryFileWithPath:(NSString *)path;
- (BOOL)addAuthDirectoryWithAuthToken:(NSString *)authToken;
- (UIImage *)getImageFromDirectoryWithPath:(NSString *)path;
- (BOOL)deleteImageWithPath:(NSString *)path;
- (void)setImageFromDirectoryWithPath:(NSString *)path image:(UIImageView *)imageView;
- (void)getImageFromDirectoryWithImage:(UIImageView *)imageView path:(NSString *)path;
- (BOOL)fileExistsWithPath:(NSString *)path;
- (BOOL)removeImageFromDirectoryWithPath:(NSString *)path;
+ (DocumentDirectory *)shareDirectory;
- (void)deleteDirectoryWithSpecficTimeUserId:(NSString *)userId;

@end
