//
//  BRBubbleView+Video.m
//  LinC
//
//  Created by Yingwei Fan on 8/10/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRBubbleView+Video.h"

@implementation BRBubbleView (Video)

#pragma mark - private

- (void)_setupVideoBubbleMarginConstraints
{
    NSLayoutConstraint *marginTopConstraint = [NSLayoutConstraint constraintWithItem:self.videoImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.margin.top];
    NSLayoutConstraint *marginBottomConstraint = [NSLayoutConstraint constraintWithItem:self.videoImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-self.margin.bottom];
    NSLayoutConstraint *marginLeftConstraint = [NSLayoutConstraint constraintWithItem:self.videoImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.margin.right];
    NSLayoutConstraint *marginRightConstraint = [NSLayoutConstraint constraintWithItem:self.videoImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.margin.left];
    
    [self.marginConstraints removeAllObjects];
    [self.marginConstraints addObject:marginTopConstraint];
    [self.marginConstraints addObject:marginBottomConstraint];
    [self.marginConstraints addObject:marginLeftConstraint];
    [self.marginConstraints addObject:marginRightConstraint];
    
    [self addConstraints:self.marginConstraints];
}

- (void)_setupVideoBubbleConstraints
{
    [self _setupVideoBubbleMarginConstraints];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.videoTagView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.videoImageView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.videoTagView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.videoImageView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.videoTagView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.videoTagView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40.0]];
}

#pragma mark - public

- (void)setupVideoBubbleView
{
    self.videoImageView = [[UIImageView alloc] init];
    self.videoImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.videoImageView.backgroundColor = [UIColor clearColor];
    self.videoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.backgroundImageView addSubview:self.videoImageView];
    
    self.videoTagView = [[UIImageView alloc] init];
    self.videoTagView.translatesAutoresizingMaskIntoConstraints = NO;
    self.videoTagView.backgroundColor = [UIColor clearColor];
    [self.videoImageView addSubview:self.videoTagView];
    
    [self _setupVideoBubbleConstraints];
}

- (void)updateVideoMargin:(UIEdgeInsets)margin
{
    if (_margin.top == margin.top && _margin.bottom == margin.bottom && _margin.left == margin.left && _margin.right == margin.right) {
        return;
    }
    _margin = margin;
    
    [self removeConstraints:self.marginConstraints];
    [self _setupVideoBubbleMarginConstraints];
}

@end
