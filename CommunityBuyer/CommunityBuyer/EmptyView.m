//
//  EmptyView.m
//  PaoTuiBuyer
//
//  Created by 周大钦 on 15/8/20.
//  Copyright (c) 2015年 zdq. All rights reserved.
//

#import "EmptyView.h"

@implementation EmptyView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (EmptyView *)shareView{

    EmptyView *view = [[[NSBundle mainBundle]loadNibNamed:@"EmptyView" owner:self options:nil]objectAtIndex:0];
    
    return view;
}

@end
