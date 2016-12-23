//
//  ViewController.m
//  XZSlideCardDemo
//
//  Created by codeLocker on 2016/12/22.
//  Copyright © 2016年 codeLocker. All rights reserved.
//

#import "ViewController.h"
#import "XZCardView.h"
/** 屏幕上显示5张Card 最后一张不让用户看见*/
#define CARD_NUM 5
#define CARD_SCALE 0.95
#define ROTATION_ANGLE M_PI/8

@interface ViewController ()<XZCardViewDelegate>
@property (nonatomic, strong) NSMutableArray *allCards;
@property (nonatomic, strong) NSMutableArray *sourceArray;
@property (nonatomic, assign) CGAffineTransform lastCardViewTransform;
@property (nonatomic, assign) CGPoint lastCardViewCenter;
/** 页数*/
@property (nonatomic, assign) NSInteger page;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.allCards = [NSMutableArray array];
    self.sourceArray = [NSMutableArray array];
    self.page = 0;
    
    [self addCards];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self requestSourceData:YES];
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private_Methods
- (void)loadAllCards{

    for (NSInteger i=0; i<self.allCards.count; i++) {
        
        XZCardView *cardView = self.allCards[i];
        
        if ([self.sourceArray firstObject]) {
            
            cardView.backgroundColor = self.sourceArray[0][@"color"];
            [self.sourceArray removeObjectAtIndex:0];
            
        }else{
            cardView.hidden = YES;
        }
    }
    
    for (NSInteger i=0; i<self.allCards.count; i++) {
        
        XZCardView *cardView = self.allCards[i];
        
        [UIView animateKeyframesWithDuration:0.5 delay:0.06*i options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
            
            cardView.center = CGPointMake(self.view.center.x, 40+200);
            cardView.transform = CGAffineTransformMakeRotation(0);
            
            if (i>0 && i<CARD_NUM -1) {
                XZCardView *preCardView = self.allCards[i -1];
                cardView.transform=CGAffineTransformScale(cardView.transform, pow(CARD_SCALE, i), pow(CARD_SCALE, i));
                CGRect frame = cardView.frame;
                
                
                frame.origin.y = preCardView.frame.origin.y + (preCardView.frame.size.height-frame.size.height)+10*pow(0.7, i);
                cardView.frame = frame;
            }else if (i == CARD_NUM -1){
            
                XZCardView *preCardView=[_allCards objectAtIndex:i-1];
                cardView.transform=preCardView.transform;
                cardView.frame=preCardView.frame;
            }
            
            
        } completion:^(BOOL finished) {
            
        }];
        
        cardView.originalCenter = cardView.center;
        cardView.originalTransform = cardView.transform;
        if (i==CARD_NUM-1) {
            self.lastCardViewCenter = cardView.center;
            self.lastCardViewTransform = cardView.transform;
        }
    }
    
}

- (void)requestSourceData:(BOOL)needLoad{

    NSMutableArray *array = [NSMutableArray array];
    
    for (NSInteger i=0; i<10; i++) {
    
        [array addObject:@{@"number":[NSNumber numberWithInteger:(self.page*10+i)],@"color":[self randomColor]}];
    }
    
    [self.sourceArray addObjectsFromArray:array];
    self.page++;
    if (needLoad) {
        [self loadAllCards];
    }
}

/**
 预先创建5张cardView在屏幕的右侧之外，在从右侧飘回到屏幕中心位置
 */
- (void)addCards{

    for (NSInteger i=0; i<CARD_NUM; i++) {
        
        XZCardView *cardView = [[XZCardView alloc] initWithFrame:CGRectMake([[UIScreen mainScreen]bounds].size.width+300, self.view.center.y-400/2, 300, 400)];
        cardView.delegate = self;
//        if (i>0 && i<CARD_NUM-1) {
//            
//            cardView.transform = CGAffineTransformScale(cardView.transform, pow(CARD_SCALE, i), pow(CARD_SCALE, i));
//            
//        }else if (i == CARD_NUM-1){
//            //最后一个cardView与倒数第二个一样大小，不让用户看见
//            cardView.transform = CGAffineTransformScale(cardView.transform, pow(CARD_SCALE, i-1), pow(CARD_SCALE, i-1));
//        }
        
        cardView.canPan = (i == 0);
        
        cardView.transform = CGAffineTransformRotate(cardView.transform, ROTATION_ANGLE);
        
        [self.allCards addObject:cardView];
    }
    
    for (NSInteger i = CARD_NUM-1; i>= 0; i--) {
        
        [self.view addSubview:self.allCards[i]];
    }
}



- (UIColor *)randomColor{
    
    int R = (arc4random() % 256) ;
    int G = (arc4random() % 256) ;
    int B = (arc4random() % 256) ;
    return [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1];
}

#pragma mark - XZCardViewDelegate
- (void)moveCard:(CGFloat)xOffset{

    if (fabs(xOffset) <= 120) {
    
        for (NSInteger i = 1; i<CARD_NUM-1; i++) {
            
            XZCardView *cardView = self.allCards[i];
            XZCardView *preCardView = self.allCards[i-1];
            
            cardView.transform = CGAffineTransformScale(cardView.originalTransform, 1+(1/CARD_SCALE-1)*fabs(xOffset/120)*0.6, 1+(1/CARD_SCALE-1)*fabs(xOffset/120)*0.6);
            
            CGPoint center = cardView.center;
            center.y = cardView.originalCenter.y-(cardView.originalCenter.y-preCardView.originalCenter.y)*fabs(xOffset/120)*0.6;
            cardView.center = center;
            
        }
    }
    
}

- (void)moveBackCard{

    for (NSInteger i = 1; i<CARD_NUM-1; i++) {
        
        XZCardView *cardView = self.allCards[i];
        [UIView animateWithDuration:0.3 animations:^{
           
            cardView.transform = cardView.originalTransform;
            cardView.center = cardView.originalCenter;
        }];
    }
}

- (void)adjustOtherCards{

    [UIView animateWithDuration:0.2
                     animations:^{
                         for (int i = 1; i<CARD_NUM-1; i++) {
                             XZCardView *cardView=_allCards[i];
                             XZCardView *preCardView=[_allCards objectAtIndex:i-1];
                             cardView.transform=preCardView.originalTransform;
                             cardView.center=preCardView.originalCenter;
                         }
                     }completion:^(BOOL complete){

                     }];
}

- (void)swipeCard:(XZCardView *)cardView direction:(BOOL)isRight{

    [self.allCards removeObject:cardView];
    cardView.transform = self.lastCardViewTransform;
    cardView.center = self.lastCardViewCenter;
    cardView.canPan = NO;
    [self.view insertSubview:cardView belowSubview:[self.allCards lastObject]];
    [self.allCards addObject:cardView];
    
    //更新数据
    
    if (self.sourceArray.firstObject) {
        NSDictionary *dic = self.sourceArray[0];
        NSLog(@"%@",dic[@"number"]);
        cardView.backgroundColor =dic[@"color"];
        [self.sourceArray removeObjectAtIndex:0];
    }
    
    
    if (self.sourceArray.count < 10) {
        [self requestSourceData:NO];
    }
    
    for (NSInteger i=0; i<CARD_NUM; i++) {
        
        XZCardView *cardView = self.allCards[i];
        cardView.originalCenter = cardView.center;
        cardView.originalTransform = cardView.transform;
        if (i==0) {
            
            cardView.canPan = YES;
        }
    }
}
@end
