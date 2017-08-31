//
//  SampleViewController.m
//  StitchPictures
//
//  Created by yang on 2017/8/25.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "SampleViewController.h"
#import "OVLFilter.h"
#import "OVLViewController.h"

@interface SampleViewController ()

@property (strong, nonatomic) IBOutlet OVLViewController *ova;
@end

@implementation SampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [OVLFilter setFrontCameraMode:YES];
    self.ova.fHD = true;
    self.ova.fps = 30;
    self.ova.fFrontCamera = YES;
    self.ova.fPhotoRatio = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
