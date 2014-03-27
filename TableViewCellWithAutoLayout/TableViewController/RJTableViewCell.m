//
//  RJCell.m
//  TableViewController
//
//  Created by Kevin Muldoon & Tyler Fox on 10/5/13.
//  Copyright (c) 2013 RobotJackalope. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "RJTableViewCell.h"

#define kLabelHorizontalInsets      15.0f
#define kLabelVerticalInsets        10.0f

@interface RJTableViewCell ()

@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation RJTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.1];
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    }

    return self;
}

- (UILabel *)newLabel
{
    UILabel *titleLabel = [UILabel newAutoLayoutView];
    [titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [titleLabel setNumberOfLines:1];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [titleLabel setTextColor:[UIColor blackColor]];
    titleLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.1];

    return titleLabel;
}

- (void)configWithData:(NSString *)data
{
    [self.contentView addSubview:[self newLabel]];
    [self.contentView addSubview:[self newLabel]];
    [self.contentView addSubview:[self newLabel]];
    [self.contentView addSubview:[self newLabel]];
    [self.contentView addSubview:[self newLabel]];

    for (UILabel *label in self.contentView.subviews) {
        if ([label isKindOfClass:[UILabel class]]) {
            label.text = data;
        }
    }

    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints
{
    [super updateConstraints];

    if (self.didSetupConstraints) {
        return;
    }

    for (int index = 0 ; index < [self.contentView.subviews count]; index++) {

        UILabel *label = self.contentView.subviews[index];
        UILabel *previourLabel = nil;
        if (index - 1 >= 0) {
            previourLabel = self.contentView.subviews[index-1];
        }

        [self updateConstraintsForLabel:label withPreviousLabel:previourLabel];

        // first label
        if (index == 0) {
            [label autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10];
        }

        // last label
        if (index == [self.contentView.subviews count] - 1) {
            [label autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10];
        }
    }

    self.didSetupConstraints = YES;
}

- (void)updateConstraintsForLabel:(UILabel *)label withPreviousLabel:(UILabel *)prevLabel
{
    if(prevLabel)
        [label autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:prevLabel withOffset:10 relation:NSLayoutRelationEqual];
    
    [label autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kLabelHorizontalInsets];
    [label autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:kLabelHorizontalInsets];
}

- (void)updateConstraintsForLabel:(UILabel *)label
{
    [label autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [label autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kLabelHorizontalInsets];
    [label autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:kLabelHorizontalInsets];
    [label autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelHorizontalInsets];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
}

@end
