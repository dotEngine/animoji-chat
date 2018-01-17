//
//  CVPixelBufferConvert.h
//  animoji-chat
//
//  Created by xiang on 19/12/2017.
//  Copyright © 2017 dotEngine. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreImage;

@interface CVPixelBufferConvert : NSObject

-(CVPixelBufferRef)processCVPixelBuffer:(CVPixelBufferRef)pixelBuffer;
-(CVPixelBufferRef)processCIImage:(CIImage*)image;

@end
