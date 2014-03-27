//
//  RJFirstLabelContainView.m
//  TableViewCellWithAutoLayout
//
//  Created by Triệu Khang on 27/3/14.
//  Copyright (c) 2014 RobotJackalope. All rights reserved.
//

#import "RJFirstLabelContainView.h"

@implementation RJFirstLabelContainView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib {
    //Note that you must change @”BNYSharedView’ with whatever your nib is named
    [[NSBundle mainBundle] loadNibNamed:@"RJFirstLabelContainView" owner:self options:nil];
    [self addSubview: self.contentView];
}

@end
