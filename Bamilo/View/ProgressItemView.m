//
//  ProgressItemView.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "ProgressItemView.h"

#define cCOLOR_ACTIVE [UIColor withRGBA:0 green:160 blue:0 alpha:1.0]
#define cCOLOR_PASSIVE [UIColor withRepeatingRGBA:222 alpha:1.0]

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
    [self.textLabel setText:item.title];
    [self updateAppearanceForModel:item];
}

- (IBAction)iconButtonTapped:(id)sender {
    [self.delegate progressViewItemTapped:sender];
}

#pragma mark - Helpers
-(void) updateAppearanceForModel:(ProgressItemViewModel *)model {
    switch (model.type) {
        case PROGRESS_ITEM_PENDING:
            [self.iconButton setEnabled:NO];
            [self.iconButton setImage:[UIImage imageNamed:model.icons.pending] forState:UIControlStateNormal];
            [self.textLabel applyStyle:kFontRegularName fontSize:10.0f color:cCOLOR_PASSIVE];
            [self.buttonInnerContainerView setBackgroundColor:cCOLOR_PASSIVE];
            [self.buttonOutterContainerView setBackgroundColor:cCOLOR_PASSIVE];
        break;
            
        case PROGRESS_ITEM_ACTIVE:
            [self.iconButton setEnabled:(model.isIndicator ? NO : YES)];
            [self.iconButton setImage:[UIImage imageNamed:model.icons.active] forState:UIControlStateNormal];
            [self.textLabel applyStyle:kFontRegularName fontSize:12.0f color:cCOLOR_ACTIVE];
            [self.buttonInnerContainerView setBackgroundColor:[UIColor whiteColor]];
            [self.buttonOutterContainerView setBackgroundColor:cCOLOR_ACTIVE];
        break;
            
        case PROGRESS_ITEM_DONE:
            [self.iconButton setEnabled:(model.isIndicator ? NO : YES)];
            [self.iconButton setImage:[UIImage imageNamed:model.icons.done] forState:UIControlStateNormal];
            [self.textLabel applyStyle:kFontRegularName fontSize:10.0f color:cCOLOR_ACTIVE];
            [self.buttonInnerContainerView setBackgroundColor:cCOLOR_ACTIVE];
            [self.buttonOutterContainerView setBackgroundColor:cCOLOR_ACTIVE];
        break;
    }
}

@end
