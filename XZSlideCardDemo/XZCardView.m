//
//  XZCardView.m
//  XZSlideCardDemo
//
//  Created by codeLocker on 2016/12/22.
//  Copyright © 2016年 codeLocker. All rights reserved.
//

#import "XZCardView.h"

@interface XZCardView(){


    CGFloat _xFromCenter;
    CGFloat _yFromCenter;
}

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@end

@implementation XZCardView

- (id)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5.0f;
        self.layer.masksToBounds = YES;
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:self.panGesture];
    }
    return self;
}

#pragma mark - Gesture_Methods
- (void)handlePan:(UIPanGestureRecognizer *)pan{

    if (!self.canPan) {
        return;
    }
    
    _xFromCenter = [pan translationInView:self].x;
    _yFromCenter = [pan translationInView:self].y;
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGFloat rotationStrength = MIN(_xFromCenter/400.0f, 1);
            CGFloat rotation = (CGFloat)(M_PI/8 * rotationStrength);
            CGFloat scale = MAX(1- fabs(rotationStrength)/4, .93);
            self.center = CGPointMake(self.originalCenter.x+_xFromCenter, self.originalCenter.y+_yFromCenter);
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotation);
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            self.transform = scaleTransform;
            
            [self.delegate moveCard:_xFromCenter];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self followUpActionWithDistance:_xFromCenter andVelocity:[pan velocityInView:self.superview]];
        }
            break;
            
        default:
            break;
    }
    
}

- (void)followUpActionWithDistance:(CGFloat)distance andVelocity:(CGPoint)velocity{

    //右滑
    if (distance > 0 && (distance > 150 || velocity.x > 400)) {
        
        [self rightAction:velocity];
    }else if (distance < 0 && (distance > -150 || velocity.x < -400)){
        //左滑
        [self leftAction:velocity];
    }else{
    
        //回到原点
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.center = self.originalCenter;
                             self.transform = CGAffineTransformMakeRotation(0);
                             
                         }];
        [self.delegate moveBackCard];
        
    }
}

- (void)rightAction:(CGPoint)velocity{

    CGFloat distanceX = [UIScreen mainScreen].bounds.size.width+300+self.originalCenter.x;
    CGFloat distanceY = distanceX * (_yFromCenter/_xFromCenter);
    
    CGPoint finishPoint = CGPointMake(self.originalCenter.x+distanceX, self.originalCenter.y+distanceY);
    
    CGFloat vel = sqrt(pow(velocity.x, 2) + pow(velocity.y, 2));
    
    CGFloat displace = sqrt(pow(distanceX - _xFromCenter, 2)+pow(distanceY - _yFromCenter, 2));
    
    CGFloat duration = fabs(displace/vel);
    
    if (duration>0.6) {
        duration = 0.6;
    }else if (duration < 0.3){
    
        duration = 0.3;
    }
    
    [UIView animateWithDuration:duration animations:^{
       
        self.center = finishPoint;
        self.transform = CGAffineTransformMakeRotation(M_PI/8);
    }completion:^(BOOL finished) {
        
        [self.delegate swipeCard:self direction:YES];
    }];
    [self.delegate adjustOtherCards];
}

- (void)leftAction:(CGPoint)velocity{

    //横向移动距离
    CGFloat distanceX = -300 - self.originalCenter.x;
    //纵向移动距离
    CGFloat distanceY = distanceX*_yFromCenter/_xFromCenter;
    //目标center点
    CGPoint finishPoint = CGPointMake(self.originalCenter.x+distanceX, self.originalCenter.y+distanceY);
    
    CGFloat vel = sqrtf(pow(velocity.x, 2) + pow(velocity.y, 2));
    CGFloat displace = sqrtf(pow(distanceX - _xFromCenter, 2) + pow(distanceY - _yFromCenter, 2));
    
    CGFloat duration = fabs(displace/vel);
    if (duration>0.6) {
        duration = 0.6;
    }else if(duration < 0.3) {
        duration = 0.3;
    }
    [UIView animateWithDuration:duration
                     animations:^{

                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(-M_PI/8);
                     } completion:^(BOOL finished) {
                         [self.delegate swipeCard:self direction:NO];
                     }];
    [self.delegate adjustOtherCards];
}
@end
