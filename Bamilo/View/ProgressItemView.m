//
//  ProgressItemView.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "ProgressItemView.h"

@interface ProgressItemView()
@property (weak, nonatomic) IBOutlet UIView *buttonInnerContainerView;
@property (weak, nonatomic) IBOutlet UIView *buttonOutterContainerView;
@property (weak, nonatomic) IBOutlet UIButton *iconButton;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@end

@implementation ProgressItemView

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.buttonInnerContainerView.clipsToBounds = YES;
    self.buttonInnerContainerView.cornerRadius = self.buttonInnerContainerView.width / 2;
    
    self.buttonOutterContainerView.clipsToBounds = YES;
    self.buttonOutterContainerView.cornerRadius = self.buttonOutterContainerView.width / 2;
}

-(void)updateWithModel:(ProgressItemViewModel *)item {
    [self updateAppearanceForModel:item];
}

- (IBAction)iconButtonTapped:(id)sender {
    [self.delegate progressViewItemTapped:sender];
}

#pragma mark - Helpers
-(void) updateAppearanceForModel:(ProgressItemViewModel *)model {
    [self.textLabel setText:model.title];
    
    switch (model.type) {
        case PROGRESS_ITEM_PENDING:
            [self.iconButton setEnabled:NO];
            [self.iconButton setImage:[UIImage imageNamed:model.icons.pending] forState:UIControlStateNormal];
            [self.textLabel applyStyle:kFontRegularName fontSize:10.0f color:[Theme color:kColorExtraLightGray]];
            [self.buttonInnerContainerView setBackgroundColor:[Theme color:kColorExtraLightGray]];
            [self.buttonOutterContainerView setBackgroundColor:[Theme color:kColorExtraLightGray]];
        break;
            
        case PROGRESS_ITEM_ACTIVE:
            [self.iconButton setEnabled:(model.isIndicator ? NO : YES)];
            [self.iconButton setImage:[UIImage imageNamed:model.icons.active] forState:UIControlStateNormal];
            [self.textLabel applyStyle:kFontRegularName fontSize:12.0f color:[Theme color:kColorGreen]];
            [self.buttonInnerContainerView setBackgroundColor:[UIColor whiteColor]];
            [self.buttonOutterContainerView setBackgroundColor:[Theme color:kColorGreen]];
        break;
            
        case PROGRESS_ITEM_DONE:
            [self.iconButton setEnabled:(model.isIndicator ? NO : YES)];
            [self.iconButton setImage:[UIImage imageNamed:model.icons.done] forState:UIControlStateNormal];
            [self.textLabel applyStyle:kFontRegularName fontSize:10.0f color:[Theme color:kColorGreen]];
            [self.buttonInnerContainerView setBackgroundColor:[Theme color:kColorGreen]];
            [self.buttonOutterContainerView setBackgroundColor:[Theme color:kColorGreen]];
        break;
            
        case PROGRESS_ITEM_ERROR:
            [self.iconButton setEnabled:NO];
            [self.iconButton setImage:[UIImage imageNamed:model.icons.error] forState:UIControlStateNormal];
            [self.textLabel setText:model.errorTitle];
            [self.textLabel applyStyle:kFontRegularName fontSize:12.0f color:[Theme color:kColorRed]];
            [self.buttonInnerContainerView setBackgroundColor:[Theme color:kColorExtraLightRed]];
            [self.buttonOutterContainerView setBackgroundColor:[Theme color:kColorRed]];
        break;
    }
}

@end
