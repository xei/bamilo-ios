//
//  FormViewControl.h
//  Bamilo
//
//  Created by Ali saiedifar on 2/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ButtonTableViewCell.h"
#import "FormTableViewCell.h"
#import "FormItemModel.h"
#import "FormHeaderModel.h"
#import "FormElementProtocol.h"

@protocol FormViewControlDelegate<NSObject>

- (void)formSubmitButtonTapped;

@optional
- (void)fieldHasBeenUpdatedByNewValidValue:(NSString *)value inFieldIndex:(NSUInteger)fieldIndex;

@end

@interface FormViewControl :NSObject <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ButtonTableViewCellDelegate, InputTextFieldControlDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, copy) NSString *submitTitle;
@property (nonatomic, strong) NSMutableArray *formModelList;
@property (nonatomic, weak) id<FormViewControlDelegate> delegate;

typedef FormItemModel *(^updateModelWithPreviousModel)(FormItemModel *model);

- (void)setupTableView;
- (void)registerForKeyboardNotifications;
- (void)unregisterForKeyboardNotifications;
- (void)updateFieldIndex:(NSUInteger)index WithUpdateModelBlock:(updateModelWithPreviousModel)block;
- (BOOL)showErrorMessageForField:(NSString *)fieldName errorMsg:(NSString *)string;
- (NSMutableDictionary *)getMutableDictionaryOfForm;
- (Boolean)isFormValid;
- (void)showAnyErrorInForm;
- (void)refreshView;

@end
