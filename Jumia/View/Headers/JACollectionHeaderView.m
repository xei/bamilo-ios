//
//  JACollectionHeaderView.m
//  Jumia
//
//  Created by miguelseabra on 10/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#define kTitlePaddingLeft 16.f
#define kTitlePaddingbottom 16.f

#import "JACollectionHeaderView.h"


@implementation JACollectionHeaderView

-(UILabel *)title {
    if (!VALID_NOTEMPTY(_title, UILabel)) {
        _title = [UILabel new];
        [_title setFont:JAList1Font];
        [_title setTextColor:JABlackColor];

        [self addSubview:_title];
    }
    return _title;
}

- (void) loadHeaderWithText:(NSString*)text width:(CGFloat)width height:(CGFloat)height {

    [self setFrame:CGRectMake(0.f, 0.f, width, height)];
    [self setBackgroundColor:JABlack300Color];

    [self.title setText:text];
    [self.title sizeToFit];
    [self.title setFrame:CGRectMake(kTitlePaddingLeft,
                                   self.height - self.title.height - kTitlePaddingbottom,
                                    self.title.width, self.title.height)];
    
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }
}

@end
