//
//  ProductListAsyncImage.m
//  TrendyBuy
//
//  Created by O Clock on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AsyncImage.h"
#import "DocumentDirectory.h"
#import "UserManager.h"

@implementation AsyncImage
@synthesize activityIndicator;
- (void)dealloc {
	[connection cancel]; //in case the URL is still downloading
    //[activityIndicator release];
}

-(void) setLoadingImage {
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.frame = CGRectMake((self.frame.size.width - 20.0)/2, (self.frame.size.height-20.0)/2, 20.0, 20.0);
    activityIndicator.hidesWhenStopped = YES;
    [self addSubview:activityIndicator];
    [activityIndicator startAnimating];
    [activityIndicator setNeedsLayout];
    [self setNeedsLayout];
}

- (void)loadImageFromURL:(NSString *)url frameSize:(CGSize)_frameSize viewType:(NSString *)_viewType defaultImage:(UIImage *)defaultImg{
    
    defaultImage = defaultImg;
    imageNameUrl = url;
    framewidth = _frameSize.width;
    frameheigth = _frameSize.height;
    viewType = _viewType;

    imageFile = [[[NSString stringWithFormat:@"%@",url] componentsSeparatedByString:@"/"] lastObject];
    
    
//    if ([imageFile rangeOfString:@".png"].location==NSNotFound && [imageFile rangeOfString:@".jpg"].location==NSNotFound && [imageFile rangeOfString:@".JPG"].location==NSNotFound && [imageFile rangeOfString:@".PNG"].location==NSNotFound ) {
//        [self defaultNoImage];
//    }else{
    
    NSArray *array = [url componentsSeparatedByString:@"/"];
    
    NSString *imageName = [array objectAtIndex:[array count]-1];
    
    [[DocumentDirectory shareDirectory] getImageFromDirectoryWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
    
    if ([[DocumentDirectory shareDirectory] getImageFromDirectoryWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]])
    {

        
         [self setImage:[[DocumentDirectory shareDirectory] getImageFromDirectoryWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]]];
        
    }else
    {
        
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
    }
    
    //    }
    
}
-(void)defaultNoImage
{
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    [imageView setBackgroundColor:[UIColor clearColor]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight );
    [self addSubview:imageView];
}
//the URL connection calls this repeatedly as data arrives
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
	if (data==nil)
    {
        data = [[NSMutableData alloc] initWithCapacity:2048]; }
	[data appendData:incrementalData];
}

//the URL connection calls this once all the data has downloaded
- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	//so self data now has the complete image 
	connection=nil;
	if ([[self subviews] count]>0) {
		//then this must be another image, the old one is still in subviews
		[[[self subviews] objectAtIndex:0] removeFromSuperview]; //so remove it (releases it also)
	}
    UIImage *thisImage = [UIImage imageWithData:data];
    
    
    
     [[DocumentDirectory shareDirectory] addDirectoryWithPath:[[UserManager shareUserManager] number] image:imageView.image imageName:[NSString stringWithFormat:@"%@",imageNameUrl]];
   
    [self setImage:thisImage];
}

-(void)setImage:(UIImage *)thisImage {
    
    if(!thisImage)
    {
        UIImageView *defaultImg = [[UIImageView alloc] initWithImage:defaultImage];
        [self addSubview:defaultImg];
    }else{
        originalwidth = thisImage.size.width;
        originalheigth = thisImage.size.height;
       
        if ([viewType isEqualToString:@"Feed"]) {
            [self cropFeedImage:thisImage targetSize:CGSizeMake(framewidth*2, frameheigth*2)];
            
        }else {
            [self resizeImage:thisImage resizing:@"crop" targetSize:CGSizeMake(framewidth*2, frameheigth*2)];
            
        }
        data=nil;
    }
}
-(void)cropFeedImage:(UIImage *)imageToCrop targetSize:(CGSize)_targetSize
{
    UIImage *image=[self resizeImage1:imageToCrop targetSize1:CGSizeMake(_targetSize.width, _targetSize.height) yposition1:0];
    
    imageToCrop=image;
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], CGRectMake((imageToCrop.size.width-self.frame.size.width) / 2, (imageToCrop.size.height-self.frame.size.height) / 2 ,self.frame.size.width, self.frame.size.height));
    
    imageView = [[UIImageView alloc] init];
    [imageView setImage:[UIImage imageWithCGImage:imageRef]];
    
    imageView.frame =CGRectMake(2, 0, self.frame.size.width , self.frame.size.height);
    [self addSubview:imageView];
    [imageView setNeedsLayout];
    [self setNeedsLayout];
    
    
}
- (void) resizeImage:(UIImage *)imageToCrop resizing:(NSString *)resizeType targetSize:(CGSize)_targetSize  {
    UIImage *resizedImage;
    //    UIImageView* imageView;
    CGSize size = imageToCrop.size;
    CGFloat ratio = 1;
    CGRect rect;
    if ([resizeType isEqualToString:@"crop"]) {
        
        UIImage *image=[self resizeImage1:imageToCrop targetSize1:CGSizeMake(_targetSize.width, _targetSize.height) yposition1:0];
        
        imageToCrop=image;
        size = imageToCrop.size;
                
        if (size.width > size.height) {
            if (size.width > 0) ratio = self.frame.size.width / size.width;
        }
        else  {
            if (size.height > 0) ratio = self.frame.size.height / size.height;
        }
        
        rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
        
       
        UIGraphicsBeginImageContext(rect.size);
        
        [imageToCrop drawInRect:rect];
        
        imageView = [[UIImageView alloc] initWithImage:imageToCrop];
        [imageView setBackgroundColor:[UIColor clearColor]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight );
        [self addSubview:imageView];
        
        imageView.frame = CGRectMake(((self.frame.size.height - (ratio *size.width))/2),
                                     ((self.frame.size.width-(ratio*size.height))/2) ,
                                     ratio * size.width, ratio * size.height);
        [self addSubview:imageView];
        imageView.center =self.center;
        [imageView setNeedsLayout];
        [self setNeedsLayout];
    }
    else {
        
        if ([resizeType isEqualToString:@"fit"]) {
            rect= CGRectMake((self.frame.size.width -size.width)/2.0, (self.frame.size.height -size.height)/2.0, size.width,size.height);
            UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
            [imageToCrop drawInRect:rect];
            resizedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [self setBackgroundColor:[UIColor colorWithPatternImage:resizedImage]];    
            
        }
        
        else {
            
            
            if (size.width > size.height) {
                if (size.width > 0) ratio = self.frame.size.width / size.width;
            }
            else  {
                if (size.height > 0) ratio = self.frame.size.height / size.height;
            }
            rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
            UIGraphicsBeginImageContext(rect.size);
            
            [imageToCrop drawInRect:rect];
            //            UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
            
            imageView = [[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()];
            [imageView setBackgroundColor:[UIColor clearColor]];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight );
            [self addSubview:imageView];
            
            imageView.frame = CGRectMake(((self.frame.size.height - (ratio *size.width))/2),
                                         ((self.frame.size.width-(ratio*size.height))/2) ,
                                         ratio * size.width, ratio * size.height);
            [self addSubview:imageView];
            imageView.center =self.center;
            [imageView setNeedsLayout];
            [self setNeedsLayout];
            
        
        }
        
    }


}


/*
- (UIImage *)blurryImage:(UIImage *)image
           withBlurLevel:(CGFloat)blur {
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"
                                  keysAndValues:kCIInputImageKey, inputImage,
                        @"inputRadius", @(blur),
                        nil];
    
    CIImage *outputImage = filter.outputImage;
    
    CGImageRef outImage = [self.context createCGImage:outputImage
                                             fromRect:[outputImage extent]];
    return [UIImage imageWithCGImage:outImage];
}*/
- (UIImage *)resizeImage1:(UIImage *)imageToCrop  targetSize1:(CGSize)_targetSize yposition1:(int )_yPositions {
    CGSize size = imageToCrop.size;
    CGRect rect;
    
    
    float oldWidth  = imageToCrop.size.width;
    float oldHeight = imageToCrop.size.height;
    
    float scaleFactor;
    
    if (size.width <= size.height)
        scaleFactor = _targetSize.width / oldWidth;
    else
        scaleFactor =_targetSize.height / oldHeight;
    
    float newHeight = oldHeight * scaleFactor;
    float newWidth  = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [imageToCrop drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    rect = CGRectMake(newImage.size.width/2 - _targetSize.width/2,
                      _yPositions,
                      _targetSize.width, _targetSize.height);
    
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([newImage CGImage], rect);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    imgView.center = CGPointMake(_targetSize.width/2, _targetSize.height/2);
    return imgView.image;
}


- (void)originalImage:(UIImage *)thisImage
{
    //make an image view for the image
    if ([[self subviews] count]>0) {
        //then this must be another image, the old one is still in subviews
        [[[self subviews] objectAtIndex:0] removeFromSuperview]; //so remove it (releases it also)
    }
    //        UIImage *thisImage = [UIImage imageWithData:data];
    
    if(!thisImage){
        return;
    }
    CGSize size = thisImage.size;
    CGFloat ratio = 0;
    UIImage *resizedImage;
    resizedImage = [self resizeImage:thisImage targetSize:CGSizeMake(640, 800) yposition:0];
    //make an image view for the image
    UIImageView* imageView1 = [[UIImageView alloc] initWithImage:resizedImage] ;
    [imageView1 setBackgroundColor:[UIColor clearColor]];
    //make sizing choices based on your needs, experiment with these. maybe not all the calls below are needed.
    imageView1.contentMode = UIViewContentModeScaleAspectFit;
    imageView1.frame = CGRectMake(((self.frame.size.width-(ratio*size.width))/2),((self.frame.size.height-(ratio*size.height))/2) , ratio * size.width, ratio * size.height);
    
    (imageView1.autoresizingMask =  UIViewAutoresizingFlexibleBottomMargin) || (imageView1.autoresizingMask = UIViewAutoresizingFlexibleTopMargin)|| (imageView1.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin)|| (imageView1.autoresizingMask =  UIViewAutoresizingFlexibleRightMargin) ;
    [self addSubview:imageView1];
    imageView1.frame = self.bounds;
    [imageView1 setNeedsLayout];
    [self setNeedsLayout];
    //imageView.center=[self.superview center];
    [activityIndicator stopAnimating];
}

- (UIImage *)resizeImage:(UIImage *)imageToCrop  targetSize:(CGSize)_targetSize yposition:(int )_yPositions {
    CGSize size = imageToCrop.size;
    CGRect rect;
    
    float oldWidth  = imageToCrop.size.width;
    float oldHeight = imageToCrop.size.height;
    
    float scaleFactor;
    
    if (size.width <= size.height)
        scaleFactor = _targetSize.width / oldWidth;
    else
        scaleFactor =_targetSize.height / oldHeight;
    
    float newHeight = oldHeight * scaleFactor;
    float newWidth  = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [imageToCrop drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    if(_yPositions==0){
        rect = CGRectMake(newImage.size.width/2 - _targetSize.width/2,
                          newImage.size.height/2 - _targetSize.height/2,
                          _targetSize.width, _targetSize.height);
    }
    else{
        rect = CGRectMake(newImage.size.width/2 - _targetSize.width/2,
                          _yPositions,
                          _targetSize.width, _targetSize.height);
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([newImage CGImage], rect);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return img;
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [activityIndicator stopAnimating];
}

//just in case you want to get the image directly, here it is in subviews
- (UIImage*) image {
	UIImageView* iv = [[self subviews] objectAtIndex:0];
	return [iv image];
}
@end
