//
//  JASellerDeliveryView.m
//  Jumia
//
//  Created by miguelseabra on 14/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JASellerDeliveryView.h"
#import "RICartItem.h"
#import "JAProductInfoHeaderLine.h"

@interface JASellerDeliveryView ()

@property (nonatomic, strong) UIView* contentBackgroundView;
@property (nonatomic, strong) JAProductInfoBaseLine* headerLine;
@property (strong, nonatomic) NSMutableArray *quantity;
@property (strong, nonatomic) NSMutableArray *prodName;
@property (strong, nonatomic) NSMutableArray *separators;
@property (strong, nonatomic) UILabel *name;
@property (strong, nonatomic) UILabel *delivery;
@property (strong, nonatomic) UILabel *shipping;

@end

@implementation JASellerDeliveryView

-(void) setupWithSellerDelivery:(RISellerDelivery*)sellerDelivery index:(NSInteger)index ofMax:(NSInteger)max width:(CGFloat)width
{
    if (!self.contentBackgroundView) {
        self.contentBackgroundView = [UIView new];
        [self addSubview:self.contentBackgroundView];
    }
    
    self.backgroundColor = JAWhiteColor;
    
    self.quantity = [NSMutableArray new];
    self.prodName = [NSMutableArray new];
    self.separators = [NSMutableArray new];
    
    CGFloat startingX = 16.0f;
    CGFloat currentY = 0.0f;
    
    self.headerLine = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0.0f, currentY, self.frame.size.width, kProductInfoHeaderLineHeight)];
    [self.headerLine setTitle:[NSString stringWithFormat:STRING_SHIPMENT_OF,(long)index,(long)max]];
    [self.contentBackgroundView addSubview:self.headerLine];
    
    currentY += self.headerLine.frame.size.height;
    
    for (RICartItem *prod in sellerDelivery.products) {
        //name
        currentY += 12.0f;
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(startingX, currentY, width-startingX*2, 16.0f)];
        [name setTextAlignment:NSTextAlignmentLeft];
        [name setText:[NSString stringWithFormat:@"%@ ",prod.name]];
        [name setFont:JABodyFont];
        [name setNumberOfLines:0];
        [name setLineBreakMode:NSLineBreakByWordWrapping];
        [name setTextColor:JABlackColor];
        [name sizeToFit];
        [name setWidth:width-name.frame.origin.x*2];
        [self.contentBackgroundView addSubview:name];
        [self.prodName addObject:name];
        
        //qty
        currentY += name.frame.size.height + 3.0f;
        UILabel *qty = [[UILabel alloc] initWithFrame:CGRectMake(startingX, currentY, width-startingX*2, 16.0f)];
        [qty setTextAlignment:NSTextAlignmentLeft];
        [qty setText:[NSString stringWithFormat:@"%@ %@ ",STRING_ORDER_QUANTITY,prod.quantity]];
        [qty setFont:JACaptionFont];
        [qty setTextColor:JABlack800Color];
        [qty sizeToFit];
        [self.contentBackgroundView addSubview:qty];
        [self.quantity addObject:qty];
        
        //separator
        currentY += qty.frame.size.height + 12.0f;
        UIView* separator = [[UIView alloc] init];
        separator.backgroundColor = JABlack400Color;
        [self.contentBackgroundView addSubview:separator];
        [self.separators addObject:separator];
        separator.frame = CGRectMake(startingX,
                                     currentY,
                                     width-startingX,
                                     1.0f);
        currentY += 1.0f;
    }
    
    currentY += 6.0f;
    
    //name
    self.name = [[UILabel alloc] initWithFrame:CGRectMake(startingX, currentY, width, 16.0f)];
    self.name.textAlignment = NSTextAlignmentLeft;
    [self.name setText:[NSString stringWithFormat:@"%@ %@ ",STRING_FULFILLED,sellerDelivery.name]];
    [self.name setFont:JABodyFont];
    [self.name setTextColor:JABlackColor];
    [self.name sizeToFit];
    [self.contentBackgroundView addSubview:self.name];
    currentY += self.name.frame.size.height;
    
    //shipping local
    self.delivery = [[UILabel alloc] initWithFrame:CGRectMake(startingX, currentY, width, 16.0f)];
    self.delivery.textAlignment = NSTextAlignmentLeft;
    [self.delivery setText:[NSString stringWithFormat:@"%@ ",sellerDelivery.deliveryTime]];
    [self.delivery setFont:JABodyFont];
    [self.delivery setTextColor:JABlackColor];
    [self.delivery sizeToFit];
    [self.contentBackgroundView addSubview:self.delivery];
    
    currentY += self.delivery.frame.size.height;
    
    if ( sellerDelivery.shippingGlobal != nil) {
        [self.delivery setFrame:CGRectMake(startingX, currentY - self.delivery.frame.size.height, width, 16.0f)];
        [self.delivery setTextColor:JAOrange1Color];

        //shipping global
        self.shipping = [[UILabel alloc] initWithFrame:CGRectMake(24.0f, currentY, width, 42.0f)];
        self.shipping.textAlignment = NSTextAlignmentLeft;
        [self.shipping setText:[NSString stringWithFormat:@"%@ ",sellerDelivery.shippingGlobal]];
        [self.shipping setFont:JABodyFont];
        [self.shipping setTextColor:JAOrange1Color];
        [self.shipping setLineBreakMode:NSLineBreakByWordWrapping];
        [self.shipping setNumberOfLines:0];
        [self.shipping sizeToFit];
        
        [self.contentBackgroundView addSubview:self.shipping];
        currentY += self.shipping.frame.size.height;
    }

    self.contentBackgroundView.frame = self.bounds;
    self.contentBackgroundView.width = width;
    self.contentBackgroundView.height = currentY+12.0f;
    self.width = self.contentBackgroundView.width;
    self.height = self.contentBackgroundView.height;
    
    if (RI_IS_RTL) {
        [self.contentBackgroundView flipAllSubviews];
    }
}

-(void)updateWidth:(CGFloat)width
{
    self.contentBackgroundView.frame = self.bounds;
    self.contentBackgroundView.width = width;

    [self.headerLine setFrame:CGRectMake(self.headerLine.frame.origin.x, self.headerLine.frame.origin.y, width, self.headerLine.frame.size.height)];
    
    CGFloat startingX = 16.0f;
    
    for (UILabel* qty in self.quantity) {
        [qty setFrame:CGRectMake(startingX, qty.frame.origin.y, width, qty.frame.size.height)];
        [qty setTextAlignment:NSTextAlignmentLeft];
    }
    
    for (UILabel* prod in self.prodName) {
        [prod setFrame:CGRectMake(startingX, prod.frame.origin.y, width, prod.frame.size.height)];
        [prod setTextAlignment:NSTextAlignmentLeft];
    }
    
    for (UIView* separator in self.separators) {
        [separator setFrame:CGRectMake(startingX, separator.frame.origin.y, width, separator.frame.size.height)];
    }
    
    [self.headerLine setFrame:CGRectMake(0.0f, self.headerLine.frame.origin.y, width, self.headerLine.frame.size.height)];
    [self.name setFrame:CGRectMake(startingX, self.name.frame.origin.y, width, self.name.frame.size.height)];
    [self.name setTextAlignment:NSTextAlignmentLeft];
    [self.delivery setFrame:CGRectMake(startingX, self.delivery.frame.origin.y, width, self.delivery.frame.size.height)];
    [self.delivery setTextAlignment:NSTextAlignmentLeft];
    [self.shipping setFrame:CGRectMake(startingX, self.shipping.frame.origin.y, width, self.shipping.frame.size.height)];
    [self.shipping setTextAlignment:NSTextAlignmentLeft];
    
    if (RI_IS_RTL) {
        [self.contentBackgroundView flipAllSubviews];
    }
}

@end