//
//  JANewsletterTeaserView.h
//  Jumia
//
//  Created by Jose Mota on 02/02/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JATeaserView.h"
#import "RIForm.h"

@protocol JANewsletterGenderProtocol <NSObject>


- (void)submitNewsletter:(JADynamicForm *)dynamicForm andEmail:(NSString *)email;

@end

@interface JANewsletterTeaserView : JATeaserView

@property (nonatomic, strong) id<JANewsletterGenderProtocol> genderPickerDelegate;
@property (nonatomic, strong) RIForm *form;

@end
