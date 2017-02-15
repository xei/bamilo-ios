//
//  FormViewControl.h
//  Bamilo
//
//  Created by Ali saiedifar on 2/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormItemModel.h"
#import "BaseViewController.h"
#import "ButtonTableViewCell.h"
#import "FormTableViewCell.h"

@protocol FormViewControlDelegate<NSObject>
- (void)submitBtnTapped;
- (void)viewNeedsToEndEditing;
@end

@interface FormViewControl :NSObject <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ButtonTableViewCellDelegate, InputTextFieldControlDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, copy) NSString *formMessage;
@property (nonatomic, copy) NSString *submitTitle;
@property (nonatomic, strong) NSDictionary<NSString *,FormItemModel *> *formItemListModel;
@property (nonatomic, weak) id<FormViewControlDelegate> delegate;

- (void)registerDelegationsAndDataSourceForTableview;
- (void)registerForKeyboardNotifications;
- (void)unregisterForKeyboardNotifications;

- (Boolean)isFormValid;
- (void)showErrorMessgaeForField:(NSString *)fieldName errorMsg:(NSString *)string;
@end
