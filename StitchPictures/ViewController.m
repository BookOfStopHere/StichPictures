//
//  ViewController.m
//  StitchPictures
//
//  Created by yang on 2017/8/23.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "ViewController.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES2/gl.h>
#import "ShowViewController.h"
#import "SampleViewController.h"

#define MX 20
#define MY 0

#define NUM 13
@interface MUIScrollView : UIScrollView

@property (nonatomic, strong) UIImage *sImage;

@end

@implementation MUIScrollView

- (void)drawRect:(CGRect)rect
{
    int s = 1;
    UIScreen* screen = [ UIScreen mainScreen ];
    if ( [ screen respondsToSelector:@selector(scale) ] )
        s = (int) [ screen scale ];
    
    const int w = self.frame.size.width;
    const int h = self.frame.size.height;
    const NSInteger myDataLength = w * h * 4 * s * s;
    // allocate array and read pixels into it.
    //    GLubyte *buffer = (GLubyte *) malloc(myDataLength);
    //    glReadPixels(0, 0, w*s, h*s, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    //    // gl renders "upside down" so swap top to bottom into new array.
    //    // there's gotta be a better way, but this works.
    GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);

    glReadPixels(0, 0, w*s, h*s, GL_RGBA, GL_UNSIGNED_BYTE, buffer2);

    // make data provider with data.
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer2, myDataLength, NULL);
    // prep the ingredients
    int bitsPerComponent = 8;
    int bitsPerPixel =  32;
    int bytesPerRow = 4 * w * s;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    // make the cgimage
    CGImageRef imageRef = CGImageCreate(w*s, h*s, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    // then make the uiimage from that
    UIImage *myImage = [ UIImage imageWithCGImage:imageRef scale:s orientation:UIImageOrientationUp ];
    //    UIImageWriteToSavedPhotosAlbum( myImage, nil, nil, nil );
    CGImageRelease( imageRef );
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpaceRef);
    free(buffer2);
    self.sImage = myImage;
    
}


@end

//MAXVIEWS 8320

//5 15*568 = 8520
//6 13*667 = 8670
//7
@interface ViewController ()
@property (nonatomic, strong) MUIScrollView *scroll;

@property (nonatomic, strong) UIImage *marker;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.scroll = [[MUIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.scroll];
    self.scroll.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height * NUM);
    self.scroll.backgroundColor = [UIColor whiteColor];
    CGFloat y = MY;
    for(int ii = 0; ii < NUM; ii++ )
    {
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(MX, y, self.view.bounds.size.width- 2*MX, self.view.bounds.size.height - MY)];
        imageV.contentMode = UIViewContentModeScaleToFill;
        imageV.image = [UIImage imageNamed:@"Screen.png"];
        [self.scroll addSubview:imageV];
        y+= self.view.bounds.size.height;
        
        imageV.layer.borderWidth = 3;
        
        imageV.layer.borderColor = [UIColor colorWithRed:abs(rand())%256/255.0 green:abs(rand())%256/255.0 blue:abs(rand())%256/255.0 alpha:1].CGColor;
        
        
        UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"marker.png"]];
        imgV.alpha = 0.5;
        imgV.frame = CGRectMake(90, 200, 200, 71/258.0*200);
        [imageV addSubview:imgV];
        
        imgV.transform = CGAffineTransformRotate(imgV.transform,- 0.4 *M_PI );
//        imgV.layer.anchorPoint =  CGPointMake(0, 1);
        
    }
    
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 90, 100, 30)];
    [btn setTitle:@"Stich" forState:0];
     btn.backgroundColor = [UIColor redColor];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(shot) forControlEvents:UIControlEventTouchUpInside];
    
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        self.marker =  [self encodeQRImageWithContent:@"https://www.baidu.com" size:CGSizeMake(100, 100)];
    });
    
    NSMutableDictionary *dic  = [NSThread mainThread].threadDictionary;
    
    
    GLuint dims[2];//https://stackoverflow.com/questions/6655943/maximum-opengl-framebuffer-object-size-limit
    glGetIntegerv(GL_MAX_VIEWPORT_DIMS, &dims[0]);
    
    NSLog(@"");
    
    
}


- (UIImage *)captureScrollView:(UIScrollView *)scrollView{
    UIImage* image = nil;
    if(UIGraphicsBeginImageContextWithOptions != NULL)
    {
        UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, NO, 2.0);
    } else {
        UIGraphicsBeginImageContext(scrollView.contentSize);
    }
    {
        CGPoint savedContentOffset = scrollView.contentOffset;
        CGRect savedFrame = scrollView.frame;
        scrollView.contentOffset = CGPointZero;
        scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
        
        [scrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        scrollView.contentOffset = savedContentOffset;
        scrollView.frame = savedFrame;
    }
    UIGraphicsEndImageContext();
    
    if (image != nil) {
        return image;
    }
    return nil;
}

- (UIImage *)encodeQRImageWithContent:(NSString *)content size:(CGSize)size {
    UIImage *codeImage = nil;
    if (1) {
        NSData *stringData = [content dataUsingEncoding: NSUTF8StringEncoding];
        
        //生成
        CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        [qrFilter setValue:stringData forKey:@"inputMessage"];
        [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
        
        UIColor *onColor = [UIColor blackColor];
        UIColor *offColor = [UIColor redColor];
        
        
        
        //上色
        CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"
                                           keysAndValues:
                                 @"inputImage",qrFilter.outputImage,
                                 @"inputColor0",[CIColor colorWithCGColor:onColor.CGColor],
                                 @"inputColor1",[CIColor colorWithCGColor:offColor.CGColor],
                                 nil];
        
        CIImage *qrImage = colorFilter.outputImage;
        CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
        UIGraphicsBeginImageContext(size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetInterpolationQuality(context, kCGInterpolationNone);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
        codeImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGImageRelease(cgImage);
    } else {
//        codeImage = [QRCodeGenerator qrImageForString:content imageSize:size.width];
    }
    return codeImage;
}

- (void)shot
{
    
    
    CGPoint savedContentOffset = self.scroll.contentOffset;
    CGRect savedFrame = self.scroll.frame;
    self.scroll.contentOffset = CGPointZero;
    self.scroll.frame = CGRectMake(0, 0, self.scroll.contentSize.width, self.scroll.contentSize.height);
    [self.scroll setNeedsDisplay];
    UIImage *image = self.scroll.sImage;
    self.scroll.contentOffset = savedContentOffset;
    self.scroll.frame = savedFrame;
    ShowViewController *vc0 = ShowViewController.new;
    vc0.image = image;
    [self presentViewController:vc0 animated:YES completion:nil];
    
    return;
    
//    SampleViewController *vc0 = [[SampleViewController alloc] initWithNibName:
//                 @"SampleViewController" bundle:[NSBundle mainBundle]];
//    [self presentViewController:vc0 animated:YES completion:nil];
////    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"SampleViewController" owner:nil options:nil];
////    SampleViewController *v = [arr lastObject];
//    return;
    
//    if(UIGraphicsBeginImageContextWithOptions != NULL)
//    {
//        UIGraphicsBeginImageContextWithOptions(self.scroll.contentSize, NO, 2.0);
//    } else {
//        UIGraphicsBeginImageContext(self.scroll.contentSize);
//    }
//
//    [self.scroll.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    UIImage *qr = self.marker;
    UIImageView *im = [[UIImageView alloc] initWithImage:qr];
    im.frame = CGRectMake((self.scroll.bounds.size.width - 100)/2, self.scroll.contentSize.height - 100, 100, 100);
//    [self.scroll addSubview:im];
    
    
    ShowViewController *vc = ShowViewController.new;
//    vc.image =   [self captureScrollView:self.scroll];
    vc.image = [self snapUIImage];
//    [im removeFromSuperview];
    
    [self presentViewController:vc animated:YES completion:nil];
    
    
}


-(UIImage *)snapUIImage
{
      EAGLContext *prevContext = [EAGLContext currentContext];

    int s = 1;
    UIScreen* screen = [ UIScreen mainScreen ];
    if ( [ screen respondsToSelector:@selector(scale) ] )
        s = (int) [ screen scale ];
    
    const int w = self.view.frame.size.width;
    const int h = self.view.frame.size.height;
    const NSInteger myDataLength = w * h * 4 * s * s;
    // allocate array and read pixels into it.
//    GLubyte *buffer = (GLubyte *) malloc(myDataLength);
//    glReadPixels(0, 0, w*s, h*s, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
//    // gl renders "upside down" so swap top to bottom into new array.
//    // there's gotta be a better way, but this works.
    GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);
//    for(int y = 0; y < h*s; y++)
//    {
//        memcpy( buffer2 + (h*s - 1 - y) * w * 4 * s, buffer + (y * 4 * w * s), w * 4 * s );
//    }
//    free(buffer); // work with the flipped buffer, so get rid of the original one.
//    glReadBuffer( GL_FRONT );
//    glReadBuffer( GL_BACK );
//    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    
    UIScrollView *  scrollView = self.scroll;
    CGPoint savedContentOffset = scrollView.contentOffset;
    CGRect savedFrame = scrollView.frame;
    scrollView.contentOffset = CGPointZero;
    scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
    
//    [scrollView.layer drawInContext: UIGraphicsGetCurrentContext()];

     [scrollView drawViewHierarchyInRect:scrollView.bounds afterScreenUpdates:YES];
    

    
    
//        [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    glReadPixels(0, 0, w*s, h*s, GL_RGBA, GL_UNSIGNED_BYTE, buffer2);
    
    
    scrollView.contentOffset = savedContentOffset;
    scrollView.frame = savedFrame;
    // make data provider with data.
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer2, myDataLength, NULL);
    // prep the ingredients
    int bitsPerComponent = 8;
    int bitsPerPixel =  32;
    int bytesPerRow = 4 * w * s;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    // make the cgimage
    CGImageRef imageRef = CGImageCreate(w*s, h*s, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    // then make the uiimage from that
    UIImage *myImage = [ UIImage imageWithCGImage:imageRef scale:s orientation:UIImageOrientationUp ];
    //    UIImageWriteToSavedPhotosAlbum( myImage, nil, nil, nil );
    CGImageRelease( imageRef );
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpaceRef);
    free(buffer2);
    
    return myImage;
}


- (UIImage*) takePicture {
    
    
    EAGLContext *prevContext = [EAGLContext currentContext];
    int s = 1;
    UIScreen* screen = [UIScreen mainScreen];
    if ([screen respondsToSelector:@selector(scale)]) {
        s = (int) [screen scale];
    }
    
//    GLint viewport[4];
//    glGetIntegerv(GL_VIEWPORT, viewport);
    const int width = self.view.frame.size.width;
    const int height = self.view.frame.size.height;
    
//    int width = viewport[2];
//    int height = viewport[3];
    
    int myDataLength = width * height * 4;
    GLubyte *buffer = (GLubyte *) malloc(myDataLength);
    GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);
    
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    for(int y1 = 0; y1 < height; y1++) {
        for(int x1 = 0; x1 <width * 4; x1++) {
            buffer2[(height - 1 - y1) * width * 4 + x1] = buffer[y1 * 4 * width + x1];
        }
    }
    free(buffer);
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer2, myDataLength, NULL);
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, YES, renderingIntent);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
    UIImage *image = [ UIImage imageWithCGImage:imageRef scale:s orientation:UIImageOrientationUp ];
    return image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
