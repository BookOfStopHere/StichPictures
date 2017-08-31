//
//  ShowViewController.m
//  StitchPictures
//
//  Created by yang on 2017/8/24.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "ShowViewController.h"

@interface ShowViewController ()
@property (nonatomic, strong) UIScrollView *scroll;
@end

@implementation ShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.scroll = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.scroll];
    self.scroll.backgroundColor = [UIColor orangeColor];
    self.scroll.contentSize = CGSizeMake(self.view.bounds.size.width, self.image.size.height);
    
    UIImageView *imageV = [[UIImageView alloc] initWithImage:self.image];
//    imageV.backgroundColor = [UIColor redColor];
    imageV.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.image.size.height);
    [self.scroll addSubview:imageV];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 90, 100, 30)];
    [btn setTitle:@"Close" forState:0];
    btn.backgroundColor = [UIColor redColor];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
}

- (void)close
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
