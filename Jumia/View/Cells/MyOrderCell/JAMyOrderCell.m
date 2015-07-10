//
//  JAMyOrderCell.m
//  Jumia
//
//  Created by plopes on 22/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#define kJAMyOrderCellHeight 44.0f

#import "JAMyOrderCell.h"

@interface JAMyOrderCell ()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *landscapeArrowImageView;
@property (weak, nonatomic) IBOutlet UIView *separator;

@end

@implementation JAMyOrderCell

- (void)awakeFromNib
{
    // Initialization code
    self.portraitArrowImageView.translatesAutoresizingMaskIntoConstraints=YES;
    self.clickableView.translatesAutoresizingMaskIntoConstraints = YES;
    self.dateLabel.translatesAutoresizingMaskIntoConstraints=YES;
    self.orderNumberLabel.translatesAutoresizingMaskIntoConstraints=YES;
    self.priceLabel.translatesAutoresizingMaskIntoConstraints=YES;
    self.landscapeArrowImageView.translatesAutoresizingMaskIntoConstraints=YES;
    self.separator.translatesAutoresizingMaskIntoConstraints=YES;
    
    [self.dateLabel setTextColor:UIColorFromRGB(0x666666)];
    [self.orderNumberLabel setTextColor:UIColorFromRGB(0x666666)];
    [self.priceLabel setTextColor:UIColorFromRGB(0x666666)];
    
    [self.separator setBackgroundColor:UIColorFromRGB(0xcccccc)];
}

- (void)setupWithOrder:(RITrackOrder*)order isInLandscape:(BOOL)isInLandscape
{
    [self.clickableView setFrame:CGRectMake(0.0f,
                                            0.0f,
                                            self.frame.size.width,
                                            kJAMyOrderCellHeight)];
    
    self.separator.frame = CGRectMake(0.0f,
                                      self.clickableView.frame.size.height - 1.0f,
                                      self.clickableView.frame.size.width,
                                      1.0f);
    
    self.portraitArrowImageView.frame = CGRectMake(self.clickableView.frame.size.width - self.portraitArrowImageView.frame.size.width - 17.0f,
                                                   18.0f,
                                                   self.portraitArrowImageView.frame.size.width,
                                                   self.portraitArrowImageView.frame.size.height);
    
    [self.landscapeArrowImageView setImage:[UIImage imageNamed:@"arrow_gotoarea"]];
    self.landscapeArrowImageView.frame = CGRectMake(self.clickableView.frame.size.width - self.landscapeArrowImageView.frame.size.width - 17.0f,
                                                    15.0f,
                                                    self.landscapeArrowImageView.frame.size.width,
                                                    self.landscapeArrowImageView.frame.size.height);
    
    if(isInLandscape)
    {
        [self.portraitArrowImageView setHidden:YES];
        [self.landscapeArrowImageView setHidden:NO];
    }
    else
    {
        [self.landscapeArrowImageView setHidden:YES];
        [self.portraitArrowImageView setHidden:NO];
    }
    
    self.priceLabel.textAlignment = NSTextAlignmentRight;
    [self.priceLabel setText:order.totalFormatted];
    self.priceLabel.frame = CGRectMake(self.clickableView.frame.size.width - self.priceLabel.frame.size.width - 51.0f,
                                       14.0f,
                                       self.priceLabel.frame.size.width,
                                       self.priceLabel.frame.size.height);
    
    NSDictionary* baseAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont fontWithName:kFontLightName size:13], NSFontAttributeName,
                                         UIColorFromRGB(0x666666), NSForegroundColorAttributeName, nil];    NSString* orderNumberString = [NSString stringWithFormat:@"%@ %@", STRING_ORDER_NUMBER, order.orderId];
    NSRange orderNumberLabelRange = [orderNumberString rangeOfString:STRING_ORDER_NUMBER];
    NSDictionary* highlightAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont fontWithName:kFontRegularName size:13], NSFontAttributeName,
                                         UIColorFromRGB(0x666666), NSForegroundColorAttributeName, nil];
    
    NSMutableAttributedString* finalString = [[NSMutableAttributedString alloc] initWithString:orderNumberString attributes:baseAttributes];
    [finalString setAttributes:highlightAttributes range:orderNumberLabelRange];
    
    self.orderNumberLabel.textAlignment = NSTextAlignmentLeft;
    [self.orderNumberLabel setAttributedText:finalString];
    [self.orderNumberLabel sizeToFit];
    self.orderNumberLabel.frame = CGRectMake(25.0f,
                                             21.0f,
                                             self.orderNumberLabel.frame.size.width,
                                             self.orderNumberLabel.frame.size.height);
    
    self.dateLabel.textAlignment = NSTextAlignmentLeft;
    [self.dateLabel setText:order.creationDate];
    self.dateLabel.frame = CGRectMake(25.0f,
                                      8.0f,
                                      self.dateLabel.frame.size.width,
                                      self.dateLabel.frame.size.height);
    
    if (RI_IS_RTL) {
        [self.clickableView flipAllSubviews];
        [self.landscapeArrowImageView flipViewImage];
    }
}

+ (CGFloat)getCellHeight
{
    return kJAMyOrderCellHeight;
}

@end
