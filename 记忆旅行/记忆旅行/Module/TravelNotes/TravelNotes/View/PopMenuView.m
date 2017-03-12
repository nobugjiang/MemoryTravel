//
//  PopMenuView.m
//  记忆旅行
//
//  Created by DreamItPossible on 2017/2/22.
//  Copyright © 2017年 Jiang. All rights reserved.
//

#import "PopMenuView.h"
static NSInteger const buttonTag = 1000;
@interface PopMenuView()
{
    NSArray *_imageArray;
    NSMutableArray *_btnArray;
}
@property (nonatomic,strong) UIVisualEffectView *backView;
@property (nonatomic,copy) ClickShareButtonBlock shareBlock;
@end
@implementation PopMenuView
- (instancetype)initWithFrame:(CGRect)frame ImageArray:(NSArray *)imageArray didShareButtonBlock:(ClickShareButtonBlock)saveBlock
{
    if (self = [super initWithFrame:frame]) {
        _imageArray = [NSArray arrayWithArray:imageArray];
        self.shareBlock = saveBlock;
        [self setUpUI];
    }
    return self;
}
- (void)setUpUI
{
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.backView = [[UIVisualEffectView alloc]initWithEffect:blur];
    self.backView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    //    self.backView.alpha = 0;
    [self addSubview:self.backView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [_backView addGestureRecognizer:tap];
    
    UIView *cicrleBackView = [[UIView alloc]init]; //遮挡按钮间的缝隙,避免被点击
    cicrleBackView.bounds = CGRectMake(0, 0, 220, 220);
    cicrleBackView.center = self.center;
    cicrleBackView.layer.cornerRadius = cicrleBackView.frame.size.width / 2;
    cicrleBackView.clipsToBounds = YES;
    [self addSubview:cicrleBackView];
    
    _btnArray = [NSMutableArray array];
    for (NSInteger i = 0; i < _imageArray.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        switch (i) {
            case 0:
                btn.backgroundColor = JYXColor(64, 224, 208, 1);

                break;
            case 1:
                btn.backgroundColor = JYXColor(0, 220, 255, 1);

                break;
            case 2:
                btn.backgroundColor = [UIColor orangeColor];
                break;
            case 3:
                btn.backgroundColor = [UIColor magentaColor];
                break;
            default:
                btn.backgroundColor = [UIColor yellowColor];
                break;
        }
        [btn setBackgroundImage:[UIImage imageNamed:_imageArray[i]] forState:UIControlStateNormal];
        btn.tag = buttonTag + i;
        btn.bounds = CGRectMake(0, 0, 48, 48);
        btn.layer.cornerRadius = btn.frame.size.width / 2;
        btn.clipsToBounds = YES;
        btn.alpha = 0;
        [btn addTarget:self action:@selector(ShareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_btnArray addObject:btn];
        [self addSubview:btn];
        btn.center = self.center;
    }
}
- (void)show
{
    UIWindow *win = [UIApplication sharedApplication].keyWindow;
    [win bringSubviewToFront:self];
    [win addSubview:self];
    
    CGPoint center = self.center;
    CGFloat centerX = center.x;
    CGFloat centerY = center.y;
    NSInteger padding = 70; //半径长度
    CGFloat degrees = 360 / (_btnArray.count);//角度间隔
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity,1.5,1.5);
    self.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        for (NSInteger i = 0; i < _btnArray.count; i ++) {
            
            CGFloat x = sinf((degrees * i  * M_PI)/ 180) * padding;
            CGFloat y = cosf((degrees * i * M_PI)/ 180 ) * padding;
            CGPoint btnCenter = CGPointMake(x + centerX,  centerY - y);
            UIButton * btn = _btnArray[i];
            btn.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.2,0.2);
            btn.alpha = 0;
            /**
             *  usingSpringWithDamping：0-1 数值越小，弹簧振动效果越明显
             *  initialSpringVelocity ：数值越大，一开始移动速度越快
             */
            [UIView animateWithDuration:0.3 delay:0.1 * i  usingSpringWithDamping:0.5 initialSpringVelocity:10 options:UIViewAnimationOptionCurveLinear animations:^{
                btn.center = btnCenter;
                btn.transform = transform;
                btn.alpha = 1;
            } completion:^(BOOL finished) {
                
            }];
        }
    }];
}
- (void)hide    //点击空白区域隐藏
{
    [self viewHiddenAnimation:NO with:-1];
}
- (void)ShareButtonClick:(UIButton *)button   //点击按钮隐藏
{
    [self viewHiddenAnimation:YES with:button.tag];
}
- (void)viewHiddenAnimation:(BOOL)isClickBtn with:(NSInteger)btntag
{
    CGPoint center = self.center;
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity,0.2,0.2);
    for (NSInteger i = 0; i < _btnArray.count; i ++) {
        UIButton * btn = _btnArray[i];
        [UIView animateWithDuration:0.3 delay:0.1 * i  usingSpringWithDamping:0.7 initialSpringVelocity:10 options:UIViewAnimationOptionCurveLinear animations:^{
            btn.center = center;
            btn.transform = transform;
            btn.alpha = 0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.6 animations:^{
                self.alpha = 0;
            } completion:^(BOOL finished) {
                if (i == _btnArray.count - 1) {
                    [self removeFromSuperview];
                    if (isClickBtn) {
                        if (self.shareBlock) {
                            self.shareBlock(btntag - buttonTag);
                        }
                    }
                }
            }];
            
        }];
    }
    
}
@end
