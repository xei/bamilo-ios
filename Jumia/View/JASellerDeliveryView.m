//
//  JASellerDeliveryView.m
//  Jumia
//
//  Created by miguelseabra on 14/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JASellerDeliveryView.h"
#import "RICartItem.h"

@interface JASellerDeliveryView ()

@property (strong, nonatomic) UIView* contentView;
@property (strong, nonatomic) UIView* separator;
@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) NSMutableArray *quantity;
@property (strong, nonatomic) NSMutableArray *prodName;
@property (strong, nonatomic) UILabel *name;
@property (strong, nonatomic) UILabel *delivery;
@property (strong, nonatomic) UILabel *shipping;

@end

@implementation JASellerDeliveryView

-(void) setupWithSellerDelivery:(RISellerDelivery*)sellerDelivery index:(NSInteger)index ofMax:(NSInteger)max width:(CGFloat)width{
    
    width -= 12.0f;
    
    self.contentView = [[UIView alloc]initWithFrame:CGRectMake(6.0f, 3.0f, width, 26.0f)];
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    self.contentView.layer.cornerRadius = 5.0f;
    
    NSInteger currenty = 26;
    
    self.title = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, width, 26.0f)];
    [self.title setText:[NSString stringWithFormat:STRING_SHIPMENT_OF,(long)index,(long)max]];
    [self.title setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.0f]];
    [self.title setTextColor:UIColorFromRGB(0x808080)];
    [self.contentView addSubview:self.title];
    
    //seperator
    self.separator = [[UIView alloc]initWithFrame:CGRectMake(0, currenty, width ,1.0f)];
    [self.separator setBackgroundColor:UIColorFromRGB(0xcccccc)];
    [self.contentView addSubview:self.separator];
    currenty += 1.0f;
    
    
    for (RICartItem *prod in sellerDelivery.products) {
        //name
        currenty += 24.0f;
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, currenty, width-24.f, 12.0f)];
        [name setText:[NSString stringWithFormat:@"%@ ",prod.name]];
        [name setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
        [name setNumberOfLines:0];
        [name setLineBreakMode:NSLineBreakByWordWrapping];
        [name setTextColor:UIColorFromRGB(0x666666)];
        [name sizeToFit];
        [name setWidth:width-name.frame.origin.x*2];
        [self.contentView addSubview:name];
        [self.prodName addObject:name];
        
        //qty
        currenty += name.frame.size.height;
        UILabel *qty = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, currenty, width, 12.0f)];
        [qty setText:[NSString stringWithFormat:@"%@ %@ ",STRING_ORDER_QUANTITY,prod.quantity]];
        [qty setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
        [qty setTextColor:UIColorFromRGB(0x666666)];
        [qty sizeToFit];
        [self.contentView addSubview:qty];
        [self.quantity addObject:qty];
        
        currenty += qty.frame.size.height;
    }
    
    currenty += 24.0f;
    
    //name
    self.name = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, currenty, width, 12.0f)];
    [self.name setText:[NSString stringWithFormat:@"%@ %@ ",STRING_FULFILLED,sellerDelivery.name]];
    [self.name setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.0f]];
    [self.name setTextColor:UIColorFromRGB(0x666666)];
    [self.name sizeToFit];
    [self.contentView addSubview:self.name];
    currenty += self.name.frame.size.height;
    
    //shipping local
    self.delivery = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, currenty, width, 12.0f)];
    [self.delivery setText:[NSString stringWithFormat:@"%@ ",sellerDelivery.deliveryTime]];
    [self.delivery setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
    [self.delivery setTextColor:UIColorFromRGB(0x666666)];
    [self.delivery sizeToFit];
    [self.contentView addSubview:self.delivery];
    currenty += self.delivery.frame.size.height;
    
    if ( sellerDelivery.shippingGlobal != nil) {
        currenty += 24.0f;
        [self.delivery setFrame:CGRectMake(12.0f, currenty - self.delivery.frame.size.height, width, 12.0f)];
        [self.delivery setTextColor:UIColorFromRGB(0xf68b1e)];

        //shipping global
        self.shipping = [[UILabel alloc] initWithFrame:CGRectMake(24.0f, currenty, width, 42.0f)];
        [self.shipping setText:[NSString stringWithFormat:@"%@ ",sellerDelivery.shippingGlobal]];
        [self.shipping setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
        [self.shipping setTextColor:UIColorFromRGB(0xf68b1e)];
        [self.shipping setLineBreakMode:NSLineBreakByWordWrapping];
        [self.shipping setNumberOfLines:0];
        [self.shipping sizeToFit];
        
        [self.contentView addSubview:self.shipping];
        currenty += self.shipping.frame.size.height;
    }
    
    
    [self.contentView setFrame:CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width, currenty+24.0f)];
    [self addSubview:self.contentView];
    [self setFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height + 12.0f)];
}

-(void)updateWidth:(CGFloat)width {
    
    NSInteger widthDiff = width - 12.0f;
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, widthDiff, self.frame.size.height)];
    
    [self.contentView setFrame:CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, widthDiff, self.contentView.frame.size.height)];
    [self.separator setFrame:CGRectMake(self.separator.frame.origin.x, self.separator.frame.origin.y, widthDiff, self.separator.frame.size.height)];
    [self.title setFrame:CGRectMake(self.title.frame.origin.x, self.title.frame.origin.y, widthDiff, self.title.frame.size.height)];
    
    for (UILabel* qty in self.quantity) {
        [qty setFrame:CGRectMake(qty.frame.origin.x, qty.frame.origin.y, widthDiff, qty.frame.size.height)];
    }
    
    for (UILabel* prod in self.prodName) {
        [prod setFrame:CGRectMake(prod.frame.origin.x, prod.frame.origin.y, widthDiff, prod.frame.size.height)];
    }
    
    [self.name setFrame:CGRectMake(self.name.frame.origin.x, self.name.frame.origin.y, widthDiff, self.name.frame.size.height)];
    [self.delivery setFrame:CGRectMake(self.delivery.frame.origin.x, self.delivery.frame.origin.y, widthDiff, self.delivery.frame.size.height)];
    [self.shipping setFrame:CGRectMake(self.shipping.frame.origin.x, self.shipping.frame.origin.y, widthDiff, self.shipping.frame.size.height)];
    
    
}

@end
