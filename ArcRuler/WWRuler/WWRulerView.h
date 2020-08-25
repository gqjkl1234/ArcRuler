//
//  WWRulerView.h
//  WW
//
//  Created by ww on 2020/8/20.
//  Copyright © 2020 ww. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class WWRulerView;
@protocol WWRulerViewDelegate <NSObject>

- (void)rulerView:(WWRulerView *)ruler didSelectedValueChange:(CGFloat)value;

@end

@interface WWRulerView : UIView

@property (nonatomic, weak) id<WWRulerViewDelegate> delegate;

@property (nonatomic, assign) CGFloat rulerSpace;
@property (nonatomic, assign) CGFloat currentValue;

@property (nonatomic, assign) NSInteger minRulerValue;
@property (nonatomic, assign) NSInteger maxRulerValue;
@property (nonatomic, assign) CGFloat minimumAccuracy;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) UIColor *selectedValueColor;

- (void)showStraightRuler;

- (void)showArcRuler;

@end

NS_ASSUME_NONNULL_END
