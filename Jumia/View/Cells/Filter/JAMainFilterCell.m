//
//  JAMainFilterCell.m
//  Jumia
//
//  Created by Telmo Pinto on 21/08/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAMainFilterCell.h"
#import "RIFilter.h"

@interface JAMainFilterCell()

@property (nonatomic, strong)UIImageView* customAccessoryImageView;
@property (nonatomic, strong)UIView* separator;

@end

@implementation JAMainFilterCell

- (void)setupWithFilter:(RIFilter*)filter options:(NSString*)options width:(CGFloat)width
{
    //remove the clickable view
    for (UIView* view in self.subviews) {
        if ([view isKindOfClass:[JAClickableView class]]) { //remove the clickable view
            [view removeFromSuperview];
        } else {
            for (UIView* subview in view.subviews) {
                if ([subview isKindOfClass:[JAClickableView class]]) { //remove the clickable view
                    [subview removeFromSuperview];
                }
            }
        }
    }
    //add the new clickable view
    self.clickView = [[JAClickableView alloc] initWithFrame:CGRectMake(0.0f,
                                                                       0.0f,
                                                                       width,
                                                                       44.0f)];
    [self addSubview:self.clickView];
    
    UILabel* mainLabel = [UILabel new];
    mainLabel.font = [UIFont fontWithName:kFontRegularName size:14.0f];
    mainLabel.textColor = UIColorFromRGB(0x4e4e4e);
    [self.clickView addSubview:mainLabel];
    
    UILabel* subLabel = [UILabel new];
    subLabel.font = [UIFont fontWithName:kFontLightName size:14.0f];
    subLabel.textColor = UIColorFromRGB(0x4e4e4e);
    [self.clickView addSubview:subLabel];
    
    UIImage* accessoryImage = [UIImage imageNamed:@"arrow_gotoarea"];
    self.customAccessoryImageView = [[UIImageView alloc] initWithImage:accessoryImage];
    [self.clickView addSubview:self.customAccessoryImageView];
    
    CGFloat margin = 13.0f;
    self.customAccessoryImageView.frame = CGRectMake(self.clickView.frame.size.width - margin - accessoryImage.size.width,
                                                     (self.clickView.frame.size.height - accessoryImage.size.height)/2,
                                                     accessoryImage.size.width,
                                                     accessoryImage.size.height);
    
    CGFloat remainingWidth = self.clickView.frame.size.width - margin*3 - accessoryImage.size.width;
    
    CGFloat verticalMargin = 2.0f;
    mainLabel.frame = CGRectMake(margin,
                                 verticalMargin,
                                 remainingWidth,
                                 (self.clickView.frame.size.height / 2) - verticalMargin);
    subLabel.frame = CGRectMake(margin,
                                CGRectGetMaxY(mainLabel.frame),
                                remainingWidth,
                                (self.clickView.frame.size.height / 2) - verticalMargin);
    
    self.separator = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                              self.clickView.frame.size.height - 1,
                                                              self.clickView.frame.size.width,
                                                              1.0f)];
    self.separator.backgroundColor = UIColorFromRGB(0xcccccc);
    [self.clickView addSubview:self.separator];
    
    
    mainLabel.text = filter.name;
    subLabel.text = options;
    
    
    if (RI_IS_RTL) {
        [self.clickView flipSubviewAlignments];
        [self.clickView flipSubviewImages];
        [self.clickView flipSubviewPositions];
    }
}

- (void)willTransitionToState:(UITableViewCellStateMask)state
{
    [super willTransitionToState:state];
    
    if(NO == RI_IS_RTL){
        if (state == UITableViewCellStateShowingEditControlMask ) {
            [UIView animateWithDuration:0.3f animations:^{
                [self.clickView setFrame:CGRectMake(40.0f,
                                                    self.clickView.frame.origin.y,
                                                    self.frame.size.width - 40.0f,
                                                    self.clickView.frame.size.height)];
                [self.customAccessoryImageView setFrame:CGRectMake(self.clickView.frame.size.width - 13.0f - self.customAccessoryImageView.frame.size.width,
                                                                   self.customAccessoryImageView.frame.origin.y,
                                                                   self.customAccessoryImageView.frame.size.width,
                                                                   self.customAccessoryImageView.frame.size.height)];
                [self.separator setFrame:CGRectMake(self.separator.frame.origin.x,
                                                    self.separator.frame.origin.y,
                                                    self.clickView.frame.size.width,
                                                    self.separator.frame.size.height)];
            }];
        }
        
        else if (state == UITableViewCellStateDefaultMask) {
            [UIView animateWithDuration:0.3f animations:^{
                [self.clickView setFrame:CGRectMake(0.0f,
                                                    self.clickView.frame.origin.y,
                                                    self.frame.size.width,
                                                    self.clickView.frame.size.height)];
                [self.customAccessoryImageView setFrame:CGRectMake(self.clickView.frame.size.width - 13.0f - self.customAccessoryImageView.frame.size.width,
                                                                   self.customAccessoryImageView.frame.origin.y,
                                                                   self.customAccessoryImageView.frame.size.width,
                                                                   self.customAccessoryImageView.frame.size.height)];
                [self.separator setFrame:CGRectMake(self.separator.frame.origin.x,
                                                    self.separator.frame.origin.y,
                                                    self.clickView.frame.size.width,
                                                    self.separator.frame.size.height)];
            }];
        }
    }
}


@end
