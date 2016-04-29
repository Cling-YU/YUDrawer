//
//  HMViewController.m
//  KommectTest
//
//  Created by yhq on 16/4/19.
//  Copyright © 2016年 YU. All rights reserved.
//

#import "HMViewController.h"
#import "HMLeftView.h"
#import "HMMainView.h"


#define MinPanDistance 50.0f //移动多少后自动打开或者缩回
#define DefaultDistance 150 //动画最后上层view左侧距离屏幕右侧距离
#define AnimationTime .5f //动画时间
#define DownScale 0.7f //默认的缩小尺寸
#define Spacef 0.7f      //默认阻尼系数
#define MaskViewAlph 0.8f //遮挡的透明度
#define KWidth [UIScreen mainScreen].bounds.size.width
#define KHeight [UIScreen mainScreen].bounds.size.height

@interface HMViewController ()<UIGestureRecognizerDelegate>

@property(nonatomic,strong)HMMainView *hmMainView;
@property(nonatomic,strong)HMLeftView *hmLeftView;
@property(nonatomic,strong)UIView *maskView;
@property(nonatomic,assign)CGFloat moveX;
@property(nonatomic,assign)CGFloat lastMoveX;
@property(nonatomic,assign)BOOL isOpen;

@end

@implementation HMViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self createVC];
    [self createPanGesture];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)createVC
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.hmMainView = [[HMMainView alloc] initWithFrame:self.view.bounds];
    self.hmLeftView = [[HMLeftView alloc] initWithFrame:self.view.bounds];
    self.maskView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.maskView.backgroundColor = [UIColor blackColor];
    self.maskView.alpha = MaskViewAlph;
    [self.view addSubview:self.hmLeftView];
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.hmMainView];
    
}

-(void)createPanGesture
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    pan.delegate = self;
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedView:)];
    [self.view addGestureRecognizer:tap];
}

//点击手势
-(void)clickedView:(UITapGestureRecognizer *)tap
{
    if (self.isOpen) {
        [self moveToLeft];
    }
}

//移动手势
-(void)panAction:(UIPanGestureRecognizer *)pan
{
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.lastMoveX = 0;
            CGPoint start = [pan locationInView:self.view];
            NSLog(@"start x = %f start y = %f",start.x,start.y);
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint move = [pan translationInView:self.view];
            self.moveX = move.x;
            if (move.x > 0 && self.hmMainView.center.x <= KWidth) {
                [self moveWithDistance:move.x];
            }
            else if (move.x < 0 && self.hmMainView.center.x >= KWidth / 2)
            {
                [self moveWithDistance:move.x];
            }
            
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            CGPoint stop = [pan locationInView:self.view];
            NSLog(@"stop x = %f stop y = %f mainViewX = %f",stop.x,stop.y,self.hmMainView.center.x);
            if (self.hmMainView.center.x < (KWidth / 4 * 3)) {
                [self moveToLeft];
            }else{
                [self moveToRight];
            }
        }
            break;
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStatePossible:
        default:
            break;
    }
}

#pragma mark -根据移动距离移动位置
-(void)moveWithDistance:(CGFloat)dis
{
    //位移
    CGPoint location = self.hmMainView.center;
    CGFloat lastMove = dis - self.lastMoveX;
    location.x += lastMove * Spacef;
    //控制边界
    if (location.x <= KWidth / 2) {
        location.x = KWidth / 2;
    }
    if (location.x >= KWidth) {
        location.x = KWidth;
    }
    self.lastMoveX = dis;
    self.hmMainView.center = location;
    
    //缩小
    CGFloat par = (DownScale - 1) * 2 / KWidth;
    CGFloat scale = par * location.x + 2 - DownScale;
    self.hmMainView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
    
    //maskView透明度
    CGFloat clarity = MaskViewAlph / (KWidth / 2);
    CGFloat opcity = 2 * MaskViewAlph - clarity * location.x;
    self.maskView.alpha = opcity;
}

#pragma mark -移动到左侧右侧
-(void)moveToLeft
{
    NSLog(@"移动到左侧");
    [UIView animateWithDuration:AnimationTime delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.hmMainView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        self.hmMainView.center = CGPointMake(KWidth/2, KHeight/2);
        self.maskView.alpha = MaskViewAlph;
    } completion:^(BOOL finished) {
        self.isOpen = NO;
    }];

}

-(void)moveToRight
{
    NSLog(@"移动到右侧");

    [UIView animateWithDuration:AnimationTime delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.hmMainView.transform = CGAffineTransformScale(CGAffineTransformIdentity, DownScale, DownScale);
        self.hmMainView.center = CGPointMake(KWidth, KHeight/2);
        self.maskView.alpha = 0;
    } completion:^(BOOL finished) {
        self.isOpen = YES;
    }];
}


@end
