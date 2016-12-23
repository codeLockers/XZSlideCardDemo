//
//  XZCardView.h
//  XZSlideCardDemo
//
//  Created by codeLocker on 2016/12/22.
//  Copyright © 2016年 codeLocker. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XZCardView;
@protocol XZCardViewDelegate <NSObject>

- (void)moveCard:(CGFloat)xOffset;
- (void)moveBackCard;
- (void)adjustOtherCards;
- (void)swipeCard:(XZCardView *)cardView direction:(BOOL)isRight;

@end

@interface XZCardView : UIView

@property (nonatomic, weak) id<XZCardViewDelegate> delegate;
@property (nonatomic, assign) BOOL canPan;
@property (nonatomic, assign) CGPoint originalCenter;
@property (nonatomic, assign) CGAffineTransform originalTransform;
@end
