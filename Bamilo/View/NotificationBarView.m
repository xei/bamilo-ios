//
//  NotificationBarView.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/21/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "NotificationBarView.h"
#import "NSString+Size.h"

#define cVERTICAL_PADDING 10
#define cLINE_HEIGHT 23

@implementation NotificationBarView {
@private
    NSTimer *_timer;
    float basicSpaceOfOneLine, basicNumberOfCharsPerLine;
}

static NotificationBarView *instance;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[NSBundle mainBundle] loadNibNamed:@"NotificationBarView" owner:self options:nil] objectAtIndex:0];
    });
    return instance;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.textLabel.font = JABodyFont;
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    
    [self setHidden:YES];
    [self setUserInteractionEnabled:YES];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)]];
    
    [self.iconImage setImage:[UIImage imageNamed:@"ico_error_notificationbar"]];
    
    basicSpaceOfOneLine = self.frame.size.width * 0.7;
    basicNumberOfCharsPerLine = 30.0f;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismiss];
}

#pragma mark - Public Methods
- (void)show:(UIViewController *)viewController text:(NSString *)text isSuccess:(BOOL)isSuccess {
    if(self.hidden == NO) {
        [self setY:-1 * self.frame.size.height];
    }
    [self showOnViewController:viewController text:[@"\u200F" stringByAppendingString:text] isSuccess:isSuccess];
}

- (void)dismiss {
    if(self.hidden == NO) {
        [UIView animateWithDuration:0.3f animations:^{
            [self setY:-1 * self.frame.size.height];
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            [self setHidden:YES];
        }];
    }
}

#pragma mark - Helpers
- (BOOL)showOnViewController:(UIViewController *)viewController text:(NSString *)text isSuccess:(BOOL)isSuccess {
    self.textLabel.text = text;
    self.iconImage.hidden = isSuccess;
    
    if (isSuccess) {
        self.backgroundColor = JAMessageViewSuccessColor;
    } else {
        self.backgroundColor = JAMessageViewErrorColor;
    }
    
    [viewController.view addSubview:self];
    [viewController.view bringSubviewToFront:self];
    
    float spaceForCurrentView = floor(viewController.view.size.width / basicSpaceOfOneLine);
    int actualNumberOfLines = ceilf(self.textLabel.text.length / (spaceForCurrentView * basicNumberOfCharsPerLine));
    
    [self setFrame:CGRectMake(0, 0, viewController.view.size.width, actualNumberOfLines * cLINE_HEIGHT + cVERTICAL_PADDING)];
    [self setY: -self.height];
    [self setHidden:NO];
    
    [UIView animateWithDuration:.3 animations:^{
        [self setY:0.f];
    }];
    
    [_timer invalidate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:4.0f target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
    
    return YES;
}

@end
