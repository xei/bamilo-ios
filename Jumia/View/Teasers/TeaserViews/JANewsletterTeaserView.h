//
//  JANewsletterTeaserView.h
//  Jumia
//
//  Created by Jose Mota on 02/02/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JATeaserView.h"
#import "RIForm.h"

@interface JANewsletterTeaserView : JATeaserView

@property (nonatomic, strong) id genderPickerDelegate;
@property (nonatomic, strong) RIForm *form;

@end
