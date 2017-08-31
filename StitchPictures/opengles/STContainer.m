//
//  STContainer.m
//  StitchPictures
//
//  Created by yang on 2017/8/31.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "STContainer.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES2/gl.h>


@implementation STContainer

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
//https://gist.github.com/rainerkohlberger/1606382

//- (UIImage*)snapshot:(UIView*)eaglview
//
//{
//    
//    GLint backingWidth, backingHeight;
//    
//    
//    
//    // Bind the color renderbuffer used to render the OpenGL ES view
//    
//    // If your application only creates a single color renderbuffer which is already bound at this point,
//    
//    // this call is redundant, but it is needed if you're dealing with multiple renderbuffers.
//    
//    // Note, replace "_colorRenderbuffer" with the actual name of the renderbuffer object defined in your class.
//    
//    glBindRenderbufferOES(GL_RENDERBUFFER_OES, _colorRenderbuffer);
//    
//    
//    
//    // Get the size of the backing CAEAGLLayer
//    
//    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
//    
//    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
//    
//    
//    
//    NSInteger x = 0, y = 0, width = backingWidth, height = backingHeight;
//    
//    NSInteger dataLength = width * height * 4;
//    
//    GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
//    
//    
//    
//    // Read pixel data from the framebuffer
//    
//    glPixelStorei(GL_PACK_ALIGNMENT, 4);
//    
//    glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
//    
//    
//    
//    // Create a CGImage with the pixel data
//    
//    // If your OpenGL ES content is opaque, use kCGImageAlphaNoneSkipLast to ignore the alpha channel
//    
//    // otherwise, use kCGImageAlphaPremultipliedLast
//    
//    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
//    
//    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
//    
//    CGImageRef iref = CGImageCreate(width, height, 8, 32, width * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast,
//                                    
//                                    ref, NULL, true, kCGRenderingIntentDefault);
//    
//    
//    
//    // OpenGL ES measures data in PIXELS
//    
//    // Create a graphics context with the target size measured in POINTS
//    
//    NSInteger widthInPoints, heightInPoints;
//    
//    if (NULL != UIGraphicsBeginImageContextWithOptions) {
//        
//        // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
//        
//        // Set the scale parameter to your OpenGL ES view's contentScaleFactor
//        
//        // so that you get a high-resolution snapshot when its value is greater than 1.0
//        
//        CGFloat scale = eaglview.contentScaleFactor;
//        
//        widthInPoints = width / scale;
//        
//        heightInPoints = height / scale;
//        
//        UIGraphicsBeginImageContextWithOptions(CGSizeMake(widthInPoints, heightInPoints), NO, scale);
//        
//    }
//    
//    else {
//        
//        // On ios prior to 4, fall back to use UIGraphicsBeginImageContext
//        
//        widthInPoints = width;
//        
//        heightInPoints = height;
//        
//        UIGraphicsBeginImageContext(CGSizeMake(widthInPoints, heightInPoints));
//        
//    }
//    
//    
//    
//    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
//    
//    
//    
//    // UIKit coordinate system is upside down to GL/Quartz coordinate system
//    
//    // Flip the CGImage by rendering it to the flipped bitmap context
//    
//    // The size of the destination area is measured in POINTS
//    
//    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
//    
//    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, widthInPoints, heightInPoints), iref);
//    
//    
//    
//    // Retrieve the UIImage from the current context
//    
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    
//    
//    
//    UIGraphicsEndImageContext();
//    
//    
//    
//    // Clean up
//    
//    free(data);
//    
//    CFRelease(ref);
//    
//    CFRelease(colorspace);
//    
//    CGImageRelease(iref);
//    
//    
//    
//    return image;
//    
//}

//https://stackoverflow.com/questions/1352864/how-to-get-uiimage-from-eaglview/1945733
-(void)snapUIImage
{
    int s = 1;
    UIScreen* screen = [ UIScreen mainScreen ];
    if ( [ screen respondsToSelector:@selector(scale) ] )
        s = (int) [ screen scale ];
    
    const int w = self.frame.size.width;
    const int h = self.frame.size.height;
    const NSInteger myDataLength = w * h * 4 * s * s;
    // allocate array and read pixels into it.
    GLubyte *buffer = (GLubyte *) malloc(myDataLength);
    glReadPixels(0, 0, w*s, h*s, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    // gl renders "upside down" so swap top to bottom into new array.
    // there's gotta be a better way, but this works.
    GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);
    for(int y = 0; y < h*s; y++)
    {
        memcpy( buffer2 + (h*s - 1 - y) * w * 4 * s, buffer + (y * 4 * w * s), w * 4 * s );
    }
    free(buffer); // work with the flipped buffer, so get rid of the original one.
    
    // make data provider with data.
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer2, myDataLength, NULL);
    // prep the ingredients
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * w * s;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    // make the cgimage
    CGImageRef imageRef = CGImageCreate(w*s, h*s, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    // then make the uiimage from that
    UIImage *myImage = [ UIImage imageWithCGImage:imageRef scale:s orientation:UIImageOrientationUp ];
    UIImageWriteToSavedPhotosAlbum( myImage, nil, nil, nil );
    CGImageRelease( imageRef );
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpaceRef);
    free(buffer2);
}


@end
