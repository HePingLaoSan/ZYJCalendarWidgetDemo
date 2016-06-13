//
//  widgetDayView.m
//  SlideFrameWork
//
//  Created by 张英杰 on 15/12/21.
//  Copyright © 2015年 张英杰. All rights reserved.
//

#import "widgetDayView.h"

@implementation widgetDayView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _dayLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, self.frame.size.width, self.frame.size.height/2-5)];
        [self addSubview:_dayLabel];
        _classLabel.font = [UIFont systemFontOfSize:15.0f];
        _dayLabel.textColor = [UIColor whiteColor];
        _dayLabel.textAlignment = NSTextAlignmentCenter;


        _classLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_dayLabel.frame), self.frame.size.width, self.frame.size.height/2-10)];
        _classLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_classLabel];
        _classLabel.textColor = [UIColor whiteColor];
        _classLabel.font = [UIFont systemFontOfSize:13.0f];
        
        _tipImage = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(frame)-12, 0, 12, 12)];
        [self addSubview:_tipImage];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    if (_classLabel.text.length<=0) {
        _dayLabel.center = self.center;
    }
}
@end
