//
//  JAAccountServicesView.h
//  Jumia
//
//  Created by Jose Mota on 05/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kAccountServicesLineHeight 18.f

@protocol JAAccountServicesProtocol <NSObject>

- (void)accountServicesViewChange;

@end

@interface JAAccountServicesView : UIView

@property (nonatomic, strong) NSArray *accountServicesArray;
@property (nonatomic, assign) id<JAAccountServicesProtocol> delegate;

@end
