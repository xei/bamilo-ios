//
//  JAFilteredNoResultsView.m
//  Jumia
//
//  Created by jcarreira on 19/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAFilteredNoResultsView.h"


@implementation JAFilteredNoResultsView

@synthesize filtersLabel;

+(JAFilteredNoResultsView *)getFilteredNoResultsView
{
    NSArray *xibContents = nil;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        xibContents = [[NSBundle mainBundle] loadNibNamed:@"JAFilteredNoResultsView" owner:self options:nil];
    }
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        xibContents = [[NSBundle mainBundle] loadNibNamed:@"JAFilteredNoResultsView~iPad" owner:self options:nil];
    }
    
    for (NSObject *obj in xibContents)
    {
        if ([obj isKindOfClass:[JAFilteredNoResultsView class]])
        {
            return (JAFilteredNoResultsView *)obj;
        }
    }
    return nil;
}


-(void)setupView:(CGRect)frame
{
    self.viewForBaselineLayout.frame = frame;
    
    self.filtersLabel.textColor = UIColorFromRGB(0xcccccc);
    self.filtersLabel.text = STRING_FILTER_NO_RESULTS;
    
    UIButton *button = (UIButton *)[self.viewForBaselineLayout viewWithTag:1000];
    [button setTitle:STRING_CATALOG_EDIT_FILTERS forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    [button setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
}


-(IBAction)editFiltersButtonPressed
{
    NSLog(@"button was pressed");
    
    [self.delegate pressedEditFiltersButton:self];
}


@end
