//
//  CVPixelBufferConvert.m
//  animoji-chat
//
//  Created by xiang on 19/12/2017.
//  Copyright © 2017 dotEngine. All rights reserved.
//

#import "CVPixelBufferConvert.h"


@interface CVPixelBufferConvert()
{
    CIContext *ciContext;
    CIFilter*  filter;
}

@end


@implementation CVPixelBufferConvert

-(instancetype)init
{
    self = [super init];
    ciContext = [CIContext contextWithOptions:@{kCIContextWorkingColorSpace:[NSNull null]}];
    filter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
    [filter setValue:[NSNumber numberWithFloat:1.0f] forKey:@"inputAspectRatio"];
    [filter setValue:[NSNumber numberWithFloat:0.5f] forKey:@"inputScale"];
    return self;
}

-(CVPixelBufferRef)processCVPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    
    @autoreleasepool  {
        CIImage *image = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer];
        
        [filter setValue:image forKey:kCIInputImageKey];
        
        CIImage *outimage = [filter outputImage];
        
        CVPixelBufferRef outPixelBuffer = NULL;
        
        CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                              (int)outimage.extent.size.width,
                                              (int)outimage.extent.size.height,
                                              kCVPixelFormatType_420YpCbCr8BiPlanarFullRange ,
                                              (__bridge CFDictionaryRef) @{(__bridge NSString *) kCVPixelBufferIOSurfacePropertiesKey: @{}},
                                              &outPixelBuffer);
        
        if (status != 0)
        {
            NSLog(@"CVPixelBufferCreate error %d", (int)status);
        }
        
        [ciContext render:outimage toCVPixelBuffer:outPixelBuffer bounds:outimage.extent colorSpace:nil];
        
        return outPixelBuffer;
    }
}


-(CVPixelBufferRef)processCIImage:(CIImage*)image
{
    
    @autoreleasepool  {
        
        [filter setValue:image forKey:kCIInputImageKey];
        
        CIImage *outimage = [filter outputImage];
        
        NSLog(@"outimage widthxheight %dx%d", (int)outimage.extent.size.width,(int)outimage.extent.size.height);
        CVPixelBufferRef outPixelBuffer = NULL;
        
        CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                              (int)outimage.extent.size.width,
                                              (int)outimage.extent.size.height,
                                              kCVPixelFormatType_420YpCbCr8BiPlanarFullRange ,
                                              (__bridge CFDictionaryRef) @{(__bridge NSString *) kCVPixelBufferIOSurfacePropertiesKey: @{}},
                                              &outPixelBuffer);
        
        if (status != 0)
        {
            NSLog(@"CVPixelBufferCreate error %d", (int)status);
            CFRelease(outPixelBuffer);
            return nil;
        }
        
        [ciContext render:outimage toCVPixelBuffer:outPixelBuffer bounds:outimage.extent colorSpace:nil];
        
        return outPixelBuffer;
    }
}



@end
