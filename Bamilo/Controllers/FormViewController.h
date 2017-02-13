//
//  FormViewController.h
//  Bamilo
//
//  Created by Ali saiedifar on 2/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormItemModel.h"
#import "BaseViewController.h"
#import "ButtonTableViewCell.h"

@interface FormViewController :BaseViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ButtonTableViewCellDelegate>
@property (nonatomic, strong) NSArray<FormItemModel *> *formItemListModel;
@property (nonatomic, copy) NSString *formMessage;
@property (nonatomic, copy) NSString *submitTitle;

- (Boolean)isFormValid;
@end
