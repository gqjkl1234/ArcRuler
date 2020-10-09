//
//  WWRulerView.m
//  WW
//
//  Created by ww on 2020/8/20.
//  Copyright © 2020 ww. All rights reserved.
//

#import "WWRulerView.h"

@interface WWRulerView()<UIScrollViewDelegate> {

    //弧形刻度尺所需
    CGFloat angelPerLine;
    
    CGPoint circleCenter;
    
    CGFloat outShowAngle;
    CGFloat outStartAngel;
    CGFloat outRadius;
    
    CGFloat innerShowAngle;
    CGFloat innerStartAngel;
    CGFloat innerRadius;

    //公共参数
    int totalCount;
    CGFloat rulerInterSpace;
    CGFloat normalHeight;
    CGFloat tenHeight;
    CGFloat fiveHeight;
}

@property (nonatomic, strong) UIScrollView *innerScrollView;

@property (nonatomic, strong) NSMutableArray<CALayer *> *sublayers;
@property (nonatomic, strong) NSMutableArray<UIView *> *subViews;

@property (nonatomic, assign) BOOL isArc;

@end

@implementation WWRulerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        self.clipsToBounds = YES;
        
        self.minRulerValue = 0.0;
        self.maxRulerValue = 100.0f;
        self.minimumAccuracy = 1.0f;
        
        self.rulerSpace = 14.0f;
        
        totalCount = round((_maxRulerValue - _minRulerValue) / _minimumAccuracy) + 1;
        normalHeight = 10.0f;
        tenHeight = 20.0f;
        fiveHeight = 15.0f;
        
        rulerInterSpace = 100.0f;

        self.sublayers = [NSMutableArray array];
        self.subViews = [NSMutableArray array];
    }
    return self;
}

- (void)setUp {
    
    self.backgroundColor = UIColor.clearColor;

    if (_innerScrollView.superview) {
        [_innerScrollView removeFromSuperview];
        _innerScrollView = nil;
    }

    _innerScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _innerScrollView.delegate = self;
    _innerScrollView.bounces = NO;
    _innerScrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_innerScrollView];
    
    _innerScrollView.contentSize = CGSizeMake(self.bounds.size.width + self.rulerSpace * (totalCount - 1), self.bounds.size.height);
    
    [self setNeedsDisplay];
    
    if (_currentValue < self.minRulerValue) {
        _currentValue = self.minRulerValue;
    }
    if (_currentValue > self.maxRulerValue) {
        _currentValue = self.maxRulerValue;
    }
    
    CGFloat offsetX = roundf((_currentValue - self.minRulerValue) / self.minimumAccuracy) * self.rulerSpace;
    [_innerScrollView setContentOffset:CGPointMake(offsetX, 0.0)];
}

- (void)showStraightRuler {
    
    CGRect rect = self.frame;
    rect.size.height = rulerInterSpace;
    self.frame = rect;
    
    totalCount = round((_maxRulerValue - _minRulerValue) / _minimumAccuracy) + 1;

    self.isArc = NO;
    [self setUp];
}

- (void)showArcRuler {
    
    totalCount = round((_maxRulerValue - _minRulerValue) / _minimumAccuracy) + 1;

    angelPerLine = 2.0f / 180.0f * M_PI;
    
    outShowAngle = self.bounds.size.width / self.rulerSpace * angelPerLine;
    outStartAngel = (2 * M_PI - outShowAngle - M_PI) / 2.0f + M_PI;
    outRadius = self.bounds.size.width / 2.0 / sin(outShowAngle / 2.0);
    
    circleCenter = CGPointMake(self.bounds.size.width / 2.0, outRadius);
    
    innerRadius = outRadius - rulerInterSpace;
    innerShowAngle = 2 * asin(self.bounds.size.width / 2.0 / innerRadius);
    innerStartAngel = (2 * M_PI - innerShowAngle - M_PI) / 2.0f + M_PI;
    CGRect rect = self.frame;
    rect.size.height = outRadius - cos(innerShowAngle * 0.5) * innerRadius;
    self.frame = rect;

    outRadius -= 0.5;
    
    self.isArc = YES;
    [self setUp];
}

- (void)drawRect:(CGRect)rect {
    
    [self.sublayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperlayer];
    }];
    [self.sublayers removeAllObjects];
    [self.subViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.subViews removeAllObjects];
    if (_isArc) {
        [self drawArcScale];
    } else {
        [self drawScale];
    }
}

- (void)drawArcScale {
        
    CGFloat offsetX = _innerScrollView.contentOffset.x;
    CGFloat offsetAngel = offsetX / self.rulerSpace * angelPerLine;

    UIBezierPath *bezier = [UIBezierPath bezierPath];
    CGPoint startPoint = CGPointMake(circleCenter.x + cos(outStartAngel) * outRadius, circleCenter.y + sin(outStartAngel) * outRadius);
    [bezier moveToPoint:startPoint];
    [bezier appendPath:[UIBezierPath bezierPathWithArcCenter:circleCenter radius:outRadius startAngle:outStartAngel endAngle:outStartAngel + outShowAngle clockwise:YES]];
    [bezier addLineToPoint:CGPointMake(circleCenter.x + cos(innerStartAngel + innerShowAngle) * innerRadius, circleCenter.y + sin(innerStartAngel + innerShowAngle) * innerRadius)];
    [bezier appendPath:[UIBezierPath bezierPathWithArcCenter:circleCenter radius:innerRadius startAngle:innerStartAngel + innerShowAngle endAngle:innerStartAngel clockwise:NO]];
    [bezier addLineToPoint:startPoint];
    CAShapeLayer *layer = [self shapeLayerWithPath:bezier lineWidth:1.0 stroke:self.lineColor fill:self.bgColor];
    [self.layer insertSublayer:layer atIndex:2];
    [self.sublayers addObject:layer];
    
    UIBezierPath *bezierThin = [UIBezierPath bezierPath];
    UIBezierPath *bezierBold = [UIBezierPath bezierPath];
    
    CAShapeLayer *thinLayer = [self shapeLayerWithPath:bezierThin lineWidth:1.0 stroke:self.lineColor fill:nil];
    [self.layer addSublayer:thinLayer];
    [self.sublayers addObject:thinLayer];
    
    CAShapeLayer *boldLayer = [self shapeLayerWithPath:bezierBold lineWidth:2.0 stroke:self.lineColor fill:nil];
    [self.layer addSublayer:boldLayer];
    [self.sublayers addObject:boldLayer];

    for (int i = 0; i < totalCount; i++) {
        CGFloat angel = outStartAngel + 0.5 * outShowAngle - offsetAngel + i * angelPerLine;
        if (angel < innerStartAngel || angel > innerStartAngel + innerShowAngle) {
            continue;
        }
        
        if (self.delegate) {
            self.currentValue = offsetX / self.rulerSpace * self.minimumAccuracy + (CGFloat)self.minRulerValue;
            [self.delegate rulerView:self didSelectedValueChange:round(offsetX / self.rulerSpace) * self.minimumAccuracy + (CGFloat)self.minRulerValue];
        }
        if (i % 10 == 0) {
            [bezierBold moveToPoint:CGPointMake(circleCenter.x + cos(angel) * outRadius, circleCenter.y + sin(angel) * outRadius)];
            [bezierBold addLineToPoint:CGPointMake(circleCenter.x + cos(angel) * (outRadius - tenHeight), circleCenter.y + sin(angel) * (outRadius - tenHeight))];
            
            [bezierBold moveToPoint:CGPointMake(circleCenter.x + cos(angel) * innerRadius, circleCenter.y + sin(angel) * innerRadius)];
            [bezierBold addLineToPoint:CGPointMake(circleCenter.x + cos(angel) * (innerRadius + tenHeight), circleCenter.y + sin(angel) * (innerRadius + tenHeight))];
            
            UILabel *label = [[UILabel alloc] init];
            label.text = [NSString stringWithFormat:@"%d", (int)(self.minRulerValue + i * self.minimumAccuracy)];;
            if (round((angel - outStartAngel - 0.5 * outShowAngle) / angelPerLine) == 0.0) {
                label.textColor = self.selectedValueColor;
            } else {
                label.textColor = self.lineColor;
            }
            label.font = [UIFont systemFontOfSize:16.0f];
            [label sizeToFit];
            label.center = CGPointMake(circleCenter.x + cos(angel) * (innerRadius + rulerInterSpace * 0.5), circleCenter.y + sin(angel) * (innerRadius + rulerInterSpace * 0.5));
            [self addSubview:label];
            [self.subViews addObject:label];

        } else {
            CGFloat height = normalHeight;
            if (i % 5 == 0) {
                height = fiveHeight;
            }

            [bezierThin moveToPoint:CGPointMake(circleCenter.x + cos(angel) * outRadius, circleCenter.y + sin(angel) * outRadius)];
            [bezierThin addLineToPoint:CGPointMake(circleCenter.x + cos(angel) * (outRadius - height), circleCenter.y + sin(angel) * (outRadius - height))];
            
            [bezierThin moveToPoint:CGPointMake(circleCenter.x + cos(angel) * innerRadius, circleCenter.y + sin(angel) * innerRadius)];
            [bezierThin addLineToPoint:CGPointMake(circleCenter.x + cos(angel) * (innerRadius + height), circleCenter.y + sin(angel) * (innerRadius + height))];
        }
    }
    
    thinLayer.path = bezierThin.CGPath;
    boldLayer.path = bezierBold.CGPath;
}

- (void)drawScale {
    
    CGFloat offsetX = _innerScrollView.contentOffset.x;

    UIBezierPath *bezier = [UIBezierPath bezierPath];
    [bezier moveToPoint:CGPointMake(0.0, 0.0)];
    [bezier addLineToPoint:CGPointMake(self.frame.size.width, 0.0)];
    [bezier addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
    [bezier addLineToPoint:CGPointMake(0.0, self.frame.size.height)];
    [bezier addLineToPoint:CGPointMake(0.0, 0.0)];
    CAShapeLayer *layer = [self shapeLayerWithPath:bezier lineWidth:1.0 stroke:self.lineColor fill:self.bgColor];
    [self.layer insertSublayer:layer atIndex:2];
    [self.sublayers addObject:layer];

    UIBezierPath *bezierThin = [UIBezierPath bezierPath];
    UIBezierPath *bezierBold = [UIBezierPath bezierPath];
    
    CAShapeLayer *thinLayer = [self shapeLayerWithPath:bezierThin lineWidth:1.0 stroke:self.lineColor fill:nil];
    [self.layer addSublayer:thinLayer];
    [self.sublayers addObject:thinLayer];
    
    CAShapeLayer *boldLayer = [self shapeLayerWithPath:bezierBold lineWidth:2.0 stroke:self.lineColor fill:nil];
    [self.layer addSublayer:boldLayer];
    [self.sublayers addObject:boldLayer];

    for (int i = 0; i < totalCount; i++) {
        CGFloat offset = 0.0 + self.frame.size.width / 2.0 - offsetX + i * self.rulerSpace;
        if (offset < 0.0 || offset > self.frame.size.width) {
            continue;
        }
        if (self.delegate) {
            self.currentValue = offsetX / self.rulerSpace + self.minRulerValue;
            [self.delegate rulerView:self didSelectedValueChange:round(offsetX / self.rulerSpace) * self.minimumAccuracy + (CGFloat)self.minRulerValue];
        }
        if (i % 10 == 0) {
            [bezierBold moveToPoint:CGPointMake(offset, 0.0)];
            [bezierBold addLineToPoint:CGPointMake(offset, tenHeight)];
            
            [bezierBold moveToPoint:CGPointMake(offset, self.frame.size.height)];
            [bezierBold addLineToPoint:CGPointMake(offset, self.frame.size.height - tenHeight)];

            UILabel *label = [[UILabel alloc] init];
            label.text = [NSString stringWithFormat:@"%d", (int)(self.minRulerValue + i * self.minimumAccuracy)];;
            if (round((offset - self.frame.size.width * 0.5) / self.rulerSpace) == 0.0) {
                label.textColor = self.selectedValueColor;
            } else {
                label.textColor = self.lineColor;
            }
            label.font = [UIFont systemFontOfSize:16.0f];
            [label sizeToFit];
            label.center = CGPointMake(offset, self.frame.size.height / 2.0);
            [self addSubview:label];
            [self.subViews addObject:label];
        } else {
            CGFloat height = normalHeight;
            if (i % 5 == 0) {
                height = fiveHeight;
            }

            [bezierThin moveToPoint:CGPointMake(offset, 0.0)];
            [bezierThin addLineToPoint:CGPointMake(offset, height)];
            
            [bezierThin moveToPoint:CGPointMake(offset, self.frame.size.height)];
            [bezierThin addLineToPoint:CGPointMake(offset, self.frame.size.height - height)];
        }
    }
    thinLayer.path = bezierThin.CGPath;
    boldLayer.path = bezierBold.CGPath;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self setNeedsDisplay];
    if (scrollView.isDragging && scrollView.isDecelerating) {
        self.isScrolling = YES;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.isScrolling = YES;

    if (!decelerate) {
        [self finnalAdjust];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.isScrolling = YES;

    [self finnalAdjust];
}

#pragma mark - Private
- (CAShapeLayer *)shapeLayerWithPath:(UIBezierPath *)path lineWidth:(CGFloat)width stroke:(UIColor *)stroke fill:(UIColor *)fill {
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.lineWidth = width;
    layer.lineCap = @"round";
    layer.strokeColor = stroke.CGColor;
    layer.fillColor = fill.CGColor;
    layer.path = path.CGPath;
    return layer;
}

- (void)finnalAdjust {
    CGFloat offsetX = _innerScrollView.contentOffset.x;
    int toInt = round(offsetX / self.rulerSpace);
    offsetX = toInt * self.rulerSpace;
    [_innerScrollView setContentOffset:CGPointMake(offsetX, 0.0) animated:YES];
    
    self.isScrolling = NO;
}

@end

