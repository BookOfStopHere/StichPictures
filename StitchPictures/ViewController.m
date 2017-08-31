//
//  ViewController.m
//  StitchPictures
//
//  Created by yang on 2017/8/23.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "ViewController.h"

#import "ShowViewController.h"
#import "SampleViewController.h"

#define MX 20
#define MY 20

#define NUM 5

@interface ViewController ()
@property (nonatomic, strong) UIScrollView *scroll;

@property (nonatomic, strong) UIImage *marker;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.scroll = [[UIScrollView alloc] initWithFrame:self.view.bounds];
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
        UIColor *offColor = [UIColor whiteColor];
        
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
    [self.scroll addSubview:im];
    
    
    ShowViewController *vc = ShowViewController.new;
    vc.image = [self captureScrollView:self.scroll];

    [im removeFromSuperview];
    
    [self presentViewController:vc animated:YES completion:nil];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
