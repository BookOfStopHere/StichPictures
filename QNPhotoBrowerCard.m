//
//  QNPhotoBrowerCard.m
//  QYVerticalNews
//
//  Created by yang on 16/9/18.
//  Copyright © 2016年 iQiYi. All rights reserved.
//

#import "QNPhotoBrowerCard.h"

#define ZOOMSTEP 1.0
#define MXZOOM 1.5
@implementation QNPhotoBrowerCardEvent @end
@interface QNPhotoBrowerCard ()<UIScrollViewDelegate>
{
    CGFloat picWidth;
    CGFloat picHeight;
}

@end
@implementation QNPhotoBrowerCard
#pragma mark -configuration
- (instancetype)init
{
    self = [super init];
    if(self)
    {
        [self configuration];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self configuration];
    }
    return self;
}

- (void)configuration
{
    self.backgroundColor = [UIColor clearColor];
    self.scrollEnabled = YES;
    self.delegate = self;
    self.zoomStep = ZOOMSTEP;
    [self createSubviews];
}
- (void)createSubviews
{
    _photoView = UIImageView.new;
    _photoView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [_photoView addGestureRecognizer:singleTap];
    
     UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [_photoView addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    [self addSubview:_photoView];
}
#pragma mark -loadData

- (void)setImage:(UIImage *)image
{
    picWidth = image.size.width;
    picHeight = image.size.height;
    self.isPhotoCanDownload = NO;
    
    _photoView.contentMode = UIViewContentModeScaleToFill;
    
      self.isZoomEnable = YES;
        [self initParameters];
        self.zoomScale = self.minimumZoomScale;
        self.contentOffset = CGPointZero;
}


- (void)initParameters
{
    CGRect frame = _photoView.frame;
    frame.size = CGSizeMake(picWidth,picHeight);;
    _photoView.frame = frame;
    
//    CGFloat minScale = [UIImage resizableScaleWithImageSize:CGSizeMake(picWidth,picHeight) limitedToContentSize:CGSizeMake(self.frame.size.width, self.frame.size.height)];
//    if(minScale * picWidth > (QNMainW + FLT_EPSILON))
//    {
  CGFloat  minScale = 1;//self.frame.size.width/ceil(picWidth) - FLT_EPSILON;
//    }

    
    _photoView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    self.minimumZoomScale = minScale;
    self.maximumZoomScale = MAX(minScale,MXZOOM);
}

#pragma mark -settings
- (void)setScale:(CGFloat)scale
{
    if(_isZoomEnable)
    {
        self.zoomScale = MIN(MAX(scale, self.minimumZoomScale),self.maximumZoomScale);
    }
    _scale = scale;
}
- (UIImage *)image
{
    return _photoView.image;
}

- (void)reset
{
    self.zoomScale = self.minimumZoomScale;
    self.contentOffset = CGPointZero;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
}
#pragma mark -UIScrollViewDelegate
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _isZoomEnable ? _photoView : nil;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [scrollView setZoomScale:scale+0.01 animated:NO];
    [scrollView setZoomScale:scale animated:NO];
    if(_eventDelegate &&[ _eventDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)])
    {
        [_eventDelegate photoBrowerCardDidEndZooming:self withView:view atScale:scale];
    }
}
-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    //前期Only支持Center
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    _photoView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                               scrollView.contentSize.height * 0.5 + offsetY);
    if(_eventDelegate &&[ _eventDelegate respondsToSelector:@selector(photoBrowerCardDidZoom:)])
    {
        [_eventDelegate photoBrowerCardDidZoom:self];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    CGSize size = scrollView.contentSize;
    scrollView.contentSize = CGSizeMake(floor(size.width), floor(size.height));
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    scale = MIN(self.maximumZoomScale, MAX(self.minimumZoomScale, scale));
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [self frame].size.height / scale;
    zoomRect.size.width  = [self frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

#pragma mark Gestures Action
- (void)singleTap:(UITapGestureRecognizer *)tap
{
    if(_eventDelegate &&[ _eventDelegate respondsToSelector:@selector(photoBrowerCard:didRecieveEvents:)])
    {
        QNPhotoBrowerCardEvent *event = QNPhotoBrowerCardEvent.new;
        event.type = 1;
        [_eventDelegate photoBrowerCard:self didRecieveEvents:event];
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)tap
{
    CGPoint tapPoint = [tap locationInView:tap.view];
    CGFloat scale = self.zoomScale;
    if(scale > self.minimumZoomScale + FLT_EPSILON)
    {
        scale = self.minimumZoomScale;
        CGRect zoomRect = [self zoomRectForScale:scale withCenter:tapPoint];
        [self zoomToRect:zoomRect animated:YES];
    }
    else
    {
        scale = self.maximumZoomScale;
        CGRect zoomRect = [self zoomRectForScale:scale/self.zoomStep withCenter:tapPoint];
        [self zoomToRect:zoomRect animated:YES];
    }
    
    if(_eventDelegate &&[ _eventDelegate respondsToSelector:@selector(photoBrowerCard:didRecieveEvents:)])
    {
        QNPhotoBrowerCardEvent *event = QNPhotoBrowerCardEvent.new;
        event.type = 2;
        [_eventDelegate photoBrowerCard:self didRecieveEvents:event];
    }
}
@end
