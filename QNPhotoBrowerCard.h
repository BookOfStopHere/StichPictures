//
//  QNPhotoBrowerCard.h
//  QYVerticalNews
//
//  Created by yang on 16/9/18.
//  Copyright © 2016年 iQiYi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QNPhotoBrowerCardEvent : NSObject
@property (nonatomic, strong) id data;
//1:SINGLE 2:DOUBLE 3PINCH
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) CGPoint touchPoint;
@property (nonatomic, assign) CGFloat scale;
@end
@protocol QNPhotoBrowerCardDelegate;
/*<-!
 *  @author Yang, 16-09-18 10:09:22
 *
 *  @brief 支持图片双击放缩
 *  @支持pinch 放缩
 *  @支持图片下载至相册（会检测存储空间）
 *  @支持滑动浏览 
 *  @支持放缩步长设置
 *  @TODO 支持放大分块加载（比如地图）
 */
@interface QNPhotoBrowerCard : UIScrollView

@property (nonatomic, strong,readonly)UIImageView *photoView;
@property (nonatomic) CGFloat scale;//
@property (nonatomic) CGFloat zoomStep;//默认为1.5
@property (nonatomic) BOOL isZoomEnable;
@property (nonatomic) BOOL isSupportCache;

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, assign) BOOL isStored;//默认为NO
@property (nonatomic, assign) BOOL isPhotoCanDownload;

@property (weak, nonatomic) id<QNPhotoBrowerCardDelegate> eventDelegate;

@property (strong ,readonly, nonatomic) UIImage *image;
@property (nonatomic, assign) CGRect imageRect;


- (void)setImage:(UIImage *)image;
/*<-!
 *  @author Yang, 16-09-18 10:09:52
 *
 *  @brief 复原
 */
- (void)reset;

@end

//TODO 暂时不传UIScrollViewDelegate回调事件
@protocol QNPhotoBrowerCardDelegate <NSObject>

@optional
- (void)photoBrowerCardDidZoom:(QNPhotoBrowerCard *)browerCard;
- (void)photoBrowerCardDidEndZooming:(QNPhotoBrowerCard *)scrollView withView:(UIView *)view atScale:(float)scale;
- (void)photoBrowerCard:(QNPhotoBrowerCard *)browerCard didRecieveEvents:(QNPhotoBrowerCardEvent *)event;
//用于截图做搞死模糊
- (void)photoBrowerCard:(QNPhotoBrowerCard *)browerCard didZoomImage:(UIImage *)image toRect:(CGRect)imageframe;

@end
