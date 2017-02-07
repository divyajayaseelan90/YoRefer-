//
//  DocumentDirectory.m
//  eMyPA
//
//  Created by Sunilkumar Basappa on 02/09/15.
//  Copyright (c) 2015 iNube Software Solutions. All rights reserved.
//

#import "DocumentDirectory.h"
#import "Utility.h"
#import "SDWebImageManager.h"

static NSString *errorMessage = @"Unable to create directory";

#pragma mark -
@implementation DocumentDirectory

+ (DocumentDirectory *)shareDirectory
{
    static DocumentDirectory *_shareDirectory = nil;
    static dispatch_once_t  onceToken;
    dispatch_once(&onceToken, ^{
        _shareDirectory = [[DocumentDirectory alloc]init];
    });
     return _shareDirectory;
}

- (NSString *)directoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

- (NSArray *)getCountOfDirectoryFileWithPath:(NSString *)path

{
    NSString *directoryPath = [[self directoryPath] stringByAppendingPathComponent:path];
    NSMutableArray *files = [[NSMutableArray alloc] init];
    NSArray *itemsInFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:NULL];
    NSString *itemPath;
    BOOL isDirectory;
    for (NSString *item in itemsInFolder){
        
        itemPath = [NSString stringWithFormat:@"%@/%@", directoryPath, item];
        [[NSFileManager defaultManager] fileExistsAtPath:item isDirectory:&isDirectory];
        if (!isDirectory) {
            [files addObject:item];
        }
    }
    return files;
}
- (BOOL)addAuthDirectoryWithAuthToken:(NSString *)authToken
{
    NSString *stringPath = [[self directoryPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",authToken]];
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:stringPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:stringPath withIntermediateDirectories:NO attributes:nil error:&error];
        return YES;
    }
    else{
        
         return NO;
        
    }
    return NO;
}
#pragma mark - Image operations
- (void)setImageFromDirectoryWithPath:(NSString *)path image:(UIImageView *)imageView
{
    NSString *stringPath = [[self directoryPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",path]];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.alpha = 1.0;
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = CGPointMake(round(imageView.frame.size.width /2), round(imageView.frame.size.height/2));
    [imageView addSubview:activityIndicator];
    [activityIndicator startAnimating];
    dispatch_async(dispatch_get_main_queue(),^
                   {
                       if ([NSData dataWithContentsOfFile:stringPath] )
                       {
                           UIImage *urlImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:stringPath]];
                           imageView.image = urlImage;
                           [activityIndicator stopAnimating];
                           activityIndicator.hidesWhenStopped = YES;
                       }
                   });
    
}

- (void)getImageFromDirectoryWithImage:(UIImageView *)imageView path:(NSString *)path
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.alpha = 1.0;
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = CGPointMake(round(imageView.frame.size.width /2), round(imageView.frame.size.height/2));
    [imageView addSubview:activityIndicator];
    [activityIndicator startAnimating];
    if (imageView.tag == 340000)
    {
        [activityIndicator stopAnimating];
        activityIndicator.hidesWhenStopped = YES;
    }
    NSString *stringPath = [[self directoryPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",path]];
    NSURL *url = [NSURL fileURLWithPath:stringPath];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:url
                          options:0
                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                             // progression tracking code
                         }
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            if (image) {
                                imageView.image = image;
                                [activityIndicator stopAnimating];
                                activityIndicator.hidesWhenStopped = YES;
                                
                            }
                        }];
}

- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContextWithOptions(newSize,NO,0.0);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)getImageFromDirectoryWithPath:(NSString *)path
{
    NSString *stringPath = [[self directoryPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",path]];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:stringPath]];
    return image;
}

- (void)deleteDirectoryWithSpecficTimeUserId:(NSString *)userId
{
     NSString* path = [[self directoryPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",userId]];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSDictionary* attrs = [fileManager attributesOfItemAtPath:path error:nil];
    
    if (attrs != nil) {
        NSDate *startDate = (NSDate*)[attrs objectForKey: NSFileCreationDate];
        NSDate *endDate = [NSDate date];
        //NSLog(@"Date Created: %@", [startDate description]);
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                            fromDate:startDate
                                                              toDate:endDate
                                                             options:NSCalendarWrapComponents];
       if (components.day >= 4)
        
       {
           NSError *error;
           BOOL success = [fileManager removeItemAtPath:path error:&error];
           if (success) {
               NSLog(@"Successfully removed");
           }
           else
           {
               NSLog(@"Could not delete file");
           }
       }
    }
    else {
        NSLog(@"Not found");
    }
}

- (NSString *)addDirectoryWithPath:(NSString *)path image:(UIImage *)image imageName:(NSString *)imageName
{
    NSString *stringPath = [[self directoryPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",path]];
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:stringPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:stringPath withIntermediateDirectories:NO attributes:nil error:&error];
    if(error)
    {
    }
    [self getImageName:imageName];
    NSString *imagePath = [stringPath stringByAppendingFormat:@"/%@",[self getImageName:imageName]];
    NSData *image_Png = UIImagePNGRepresentation(image);
    [image_Png writeToFile:imagePath atomically:YES];
    return [NSString stringWithFormat:@"%@/%@",path,imageName];
}

- (NSString *)getImageName:(NSString *)imageName
{
    NSArray *array = [imageName componentsSeparatedByString:@"/"];
    NSString *name;
    name = [array objectAtIndex:[array count] -1];
    return name;
}
- (BOOL)removeImageFromDirectoryWithPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [[self directoryPath] stringByAppendingPathComponent:path];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    return success;
}

- (BOOL)fileExistsWithPath:(NSString *)path
{
    NSString* foofile = [[self directoryPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",path]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:foofile];
    return fileExists;
}

- (BOOL)deleteImageWithPath:(NSString *)path
{
     NSFileManager *fileManager = [NSFileManager defaultManager];
     NSString *stringPath = [[self directoryPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",path]];
     NSError *error;
     BOOL success = [fileManager removeItemAtPath:stringPath error:&error];
    if (success)
    {
        return YES;
    }else
    {
        return NO;
    }
    return YES;
}

@end
