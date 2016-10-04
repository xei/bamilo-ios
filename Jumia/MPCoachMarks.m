//
//  MPCoachMarks.m
//  Example
//
//  Created by marcelo.perretta@gmail.com on 7/8/15.
//  Copyright (c) 2015 MAWAPE. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MPCoachMarks.h"

static const CGFloat kAnimationDuration = 0.3f;
static const CGFloat kCutoutRadius = 5.0f;
static const CGFloat kMaxLblWidth = 220.0f;
static const CGFloat kLblSpacing = 35.0f;
static const CGFloat kLabelMargin = 40.0f;
static const CGFloat kMaskAlpha = 0.85f;
static const BOOL kEnableContinueLabel = YES;
static const BOOL kEnableSkipButton = YES;
NSString *const kSkipButtonText = @"بستن";
NSString *const kContinueLabelText = @"بعدی";
NSString *const KOkGotIt = @"متوجه شدم";

@implementation MPCoachMarks {
    CAShapeLayer *mask;
    NSUInteger markIndex;
    UIView *currentView;
    UIImageView *imageView;
    CGRect previousCircleFrame;
}

#pragma mark - Properties

@synthesize delegate;
@synthesize coachMarks;
@synthesize lblCaption;
@synthesize verticalCaption;
@synthesize verticalCaption2;
@synthesize lblContinue;
@synthesize btnSkipCoach;
@synthesize maskColor = _maskColor;
@synthesize animationDuration;
@synthesize cutoutRadius;
@synthesize maxLblWidth;
@synthesize lblSpacing;
@synthesize enableContinueLabel;
@synthesize enableSkipButton;
@synthesize continueLabelText;
@synthesize skipButtonText;
@synthesize horizontalImage;
@synthesize verticalImage;
@synthesize continueLocation;

#pragma mark - Methods

- (id)initWithFrame:(CGRect)frame coachMarks:(NSArray *)marks {
    self = [super initWithFrame:frame];
    if (self) {
        // Save the coach marks
        self.coachMarks = marks;
        
        // Setup
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Setup
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Setup
        [self setup];
    }
    return self;
}

- (void)setup {
    // Default
    self.animationDuration = kAnimationDuration;
    self.cutoutRadius = kCutoutRadius;
    self.maxLblWidth = kMaxLblWidth;
    self.lblSpacing = kLblSpacing;
    self.enableContinueLabel = kEnableContinueLabel;
    self.enableSkipButton = kEnableSkipButton;
    self.continueLabelText = kContinueLabelText;
    self.skipButtonText = kSkipButtonText;
    
    // Shape layer mask
    mask = [CAShapeLayer layer];
    [mask setFillRule:kCAFillRuleEvenOdd];
    [mask setFillColor:[[UIColor colorWithHue:0.0f saturation:0.0f brightness:0.0f alpha:kMaskAlpha] CGColor]];
    [self.layer addSublayer:mask];
    
    // Capture touches
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTap:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    // Captions
    self.lblCaption = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {self.maxLblWidth, 0.0f}}];
    self.lblCaption.backgroundColor = [UIColor clearColor];
    self.lblCaption.textColor = [UIColor whiteColor];
    self.lblCaption.font = [UIFont fontWithName:@"Bamilo-Sans" size:12.0f];
    self.lblCaption.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblCaption.numberOfLines = 0;
    self.lblCaption.textAlignment = NSTextAlignmentCenter;
    self.lblCaption.alpha = 0.0f;
    [self addSubview:self.lblCaption];
    
    //Location Position
    self.continueLocation = LOCATION_CENTER;
    
    // Hide until unvoked
    self.hidden = YES;
}

#pragma mark - Cutout modify

- (void)setCutoutToRect:(CGRect)rect withShape:(MaskShape)shape{
    
    UIBezierPath *maskPath;
    UIBezierPath *cutoutPath;

    CGFloat width = [UIScreen mainScreen].bounds.size.width + 50;
    CGFloat height = [UIScreen mainScreen].bounds.size.height + 50;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        maskPath = [UIBezierPath bezierPathWithRect:CGRectMake(-25, -25, width, height)];
    }
    else{
    // Define shape
        maskPath = [UIBezierPath bezierPathWithRect:CGRectMake(-25, -25, width, height)];
    }
    
    if (shape == SHAPE_CIRCLE)
        cutoutPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    else if (shape == SHAPE_SQUARE)
        cutoutPath = [UIBezierPath bezierPathWithRect:rect];
    else
        cutoutPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.cutoutRadius];
    
    [maskPath appendPath:cutoutPath];
    
    // Set the new path
    mask.path = maskPath.CGPath;
   
}

-(void)setOuterCircle:(CGRect)rect{
    CGRect currentRect = CGRectMake(rect.origin.x-45, rect.origin.y-45, rect.size.width+90, rect.size.height+90);
    previousCircleFrame = currentRect;
    self.outerCircleImageView = [[UIImageView alloc]initWithFrame:currentRect];
    self.outerCircleImageView.image = [UIImage imageNamed:@"ring.png"];
    [self addSubview:self.outerCircleImageView];
}

- (void)animateCutoutToRect:(CGRect)rect withShape:(MaskShape)shape{
    UIBezierPath *maskPath;
    UIBezierPath *cutoutPath;
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width + 50;
    CGFloat height = [UIScreen mainScreen].bounds.size.height + 50;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        maskPath = [UIBezierPath bezierPathWithRect:CGRectMake(-25, -25, width, height)];
    }
    else{
        // Define shape
        maskPath = [UIBezierPath bezierPathWithRect:CGRectMake(-25, -25, width, height)];
    }
    if (shape == SHAPE_CIRCLE)
        cutoutPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    else if (shape == SHAPE_SQUARE)
        cutoutPath = [UIBezierPath bezierPathWithRect:rect];
    else
        cutoutPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.cutoutRadius];

    [maskPath appendPath:cutoutPath];
    
    // Animate it
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
    anim.delegate = self;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anim.duration = self.animationDuration;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    anim.fromValue = (__bridge id)(mask.path);
    anim.toValue = (__bridge id)(maskPath.CGPath);
    [mask addAnimation:anim forKey:@"path"];
    mask.path = maskPath.CGPath;
    mask.strokeColor = [UIColor orangeColor].CGColor;
//    mask.lineWidth = 2.0f;
}

-(void)animateOuterCircle:(CGRect)fromValue toPosition:(CGRect)toValue{
    [UIView animateWithDuration:self.animationDuration
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.outerCircleImageView setFrame:toValue];
                     }
                     completion:^(BOOL finished){
                     }];
}

#pragma mark - Mask color

- (void)setMaskColor:(UIColor *)maskColor {
    _maskColor = maskColor;
    [mask setFillColor:[maskColor CGColor]];
}

#pragma mark - Touch handler

- (void)userDidTap:(UITapGestureRecognizer *)recognizer {
    // Go to the next coach mark
    [self goToCoachMarkIndexed:(markIndex+1)];
}

-(void)didClickNextButton:(id)sender{
    // Go to the next coach mark
    [self goToCoachMarkIndexed:(markIndex+1)];
}

#pragma mark - Navigation

- (void)start {
    // Fade in self
    self.alpha = 0.0f;
    self.hidden = NO;
    [UIView animateWithDuration:self.animationDuration
                     animations:^{
                         self.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         // Go to the first coach mark
                         [self goToCoachMarkIndexed:0];
                     }];
}

- (void)skipCoach {
    [self goToCoachMarkIndexed:self.coachMarks.count];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [self.delegate coachMarksViewDidClicked:self atIndex:markIndex];
    [self cleanup];
}

- (UIImage*)fetchImage:(NSString*)name {
    // Check for iOS 8
    if ([UIImage respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        return [UIImage imageNamed:name];
    }
}

- (void)goToCoachMarkIndexed:(NSUInteger)index {
    // Out of bounds
    if (index >= self.coachMarks.count) {
        [self cleanup];
        return;
    }
    
    // Current index
    markIndex = index;
    
    // Coach mark definition
    NSDictionary *markDef = [self.coachMarks objectAtIndex:index];
    NSString *markCaption = [markDef objectForKey:@"caption"];
    CGRect markRect = [[markDef objectForKey:@"rect"] CGRectValue];
    
    MaskShape shape = DEFAULT;
    if([[markDef allKeys] containsObject:@"shape"])
        shape = [[markDef objectForKey:@"shape"] integerValue];
    
    
    //Label Position
    LabelAligment labelAlignment = [[markDef objectForKey:@"alignment"] integerValue];
    LabelPosition labelPosition = [[markDef objectForKey:@"position"] integerValue];
    if([markDef objectForKey:@"cutoutRadius"]) {
        self.cutoutRadius = [[markDef objectForKey:@"cutoutRadius"] floatValue];
    } else {
        self.cutoutRadius = kCutoutRadius;
    }
    
    if ([self.delegate respondsToSelector:@selector(coachMarksViewDidClicked:atIndex:)]) {
        [currentView removeFromSuperview];
        currentView = [[UIView alloc] initWithFrame:markRect];
        currentView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleSingleTap:)];
        [currentView addGestureRecognizer:singleFingerTap];
        [self addSubview:currentView];
    }
    
    [self.lblContinue removeFromSuperview];
    [self.btnSkipCoach removeFromSuperview];
    [self.verticalImage removeFromSuperview];
    [self.horizontalImage removeFromSuperview];
    
    //set showArrow bool value
    BOOL showArrow = NO;
    if( [markDef objectForKey:@"showArrow"])
        showArrow = [[markDef objectForKey:@"showArrow"] boolValue];
    
    //as its an image remove outerringcircle
    if(showArrow){
        [self.outerCircleImageView setHidden:TRUE];
    }
    else{
        [self.outerCircleImageView setHidden:FALSE];
    }
    
    // Calculate the caption position and size
    self.lblCaption.alpha = 0.0f;
    self.lblCaption.frame = (CGRect){{0.0f, 0.0f}, {self.maxLblWidth, 0.0f}};
    self.lblCaption.text = markCaption;
    
    //Bold the below text if substring is found in caption
    NSRange range1 = [self.lblCaption.text rangeOfString:@"جستجو در فروشگاه"];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:self.lblCaption.text];
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Bamilo-Sans-Bold" size:18.0]}range:range1];
    self.lblCaption.attributedText = attributedText;
    [self.lblCaption sizeToFit];
    
    CGFloat y;
    CGFloat x;
    
    //Label Aligment and Position, set x value
    switch (labelAlignment) {
        case LABEL_ALIGNMENT_RIGHT:
            x = floorf(self.bounds.size.width - self.lblCaption.frame.size.width - kLabelMargin);
            break;
        case LABEL_ALIGNMENT_LEFT:
            x = kLabelMargin;
            break;
        default:
            x = floorf((self.bounds.size.width - self.lblCaption.frame.size.width) / 2.0f);
            break;
    }
    
    //set y value, sethorizontal and vertical image if showArrow is TRUE
    switch (labelPosition) {
        case LABEL_POSITION_TOP:
        {
            y = markRect.origin.y - self.lblCaption.frame.size.height - 20.0f;
            
            if(showArrow) {
                
                self.horizontalImage = [[UIImageView alloc] initWithImage:[self fetchImage:@"slideFingerVertical_iPhone.png"]];
                self.verticalImage = [[UIImageView alloc] initWithImage:[self fetchImage:@"slideFingerHorizontal_iPhone.png"]];
                
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
                    
                    //horizontal swipe/scroll
                    CGRect imageViewFrame = self.horizontalImage.frame;
                    imageViewFrame.origin.x = x + 20.0;
                    imageViewFrame.origin.y = y - 50.0;
                    self.horizontalImage.frame = imageViewFrame;
                    [self addSubview:self.horizontalImage];
                    
                    //setting new value to y
                    y -= (self.horizontalImage.frame.size.height + kLabelMargin + 20.0);
                    
                    //vertical swipe/scroll
                    CGFloat  y2 = markRect.origin.y + markRect.size.height + self.lblSpacing;
                    CGRect verticalImageViewFrame = self.verticalImage.frame;
                    verticalImageViewFrame.origin.x = x - markRect.size.width/2 - verticalImageViewFrame.size.width/2;
                    verticalImageViewFrame.origin.y = y2 - kLabelMargin; //self.lblCaption.frame.size.height/2
                    self.verticalImage.frame = verticalImageViewFrame;
                    [self addSubview:self.verticalImage];
                    
                    //setting new value to y2
                    y2 += verticalImageViewFrame.size.height/2;
                    
                }
                else{
                    
                    //should replace with iPad image
                    //                    self.horizontalImage = [[UIImageView alloc] initWithImage:[self fetchImage:@"slideFingerVertical_iPhone.png"]];
                    //                    self.verticalImage = [[UIImageView alloc] initWithImage:[self fetchImage:@"slideFingerHorizontal_iPhone.png"]];
                    
                    horizontalImage.center = self.center;
                    CGRect continueButtonFrame = horizontalImage.frame;
                    continueButtonFrame.origin.y -= 150;
                    horizontalImage.frame = continueButtonFrame;
                    [self addSubview:self.horizontalImage];
                    
                    y -= (self.horizontalImage.frame.size.height + kLabelMargin + 120.0);
                    
                    //vertical
                    CGFloat  y2 = markRect.origin.y + markRect.size.height + self.lblSpacing;
                    
                    CGRect imageViewFrame = self.verticalImage.frame;
                    imageViewFrame.origin.x = self.center.x - 100;
                    imageViewFrame.origin.y = y2 - kLabelMargin;
                    y2 += imageViewFrame.size.height/2;
                    self.verticalImage.frame = imageViewFrame;
                    [self addSubview:self.verticalImage];
                }
            }
        }
            break;
        case LABEL_POSITION_LEFT:
        {
            y = markRect.origin.y + markRect.size.height/2 - self.lblCaption.frame.size.height/2;
            x = self.bounds.size.width - self.lblCaption.frame.size.width - kLabelMargin - markRect.size.width;
            if(showArrow) {
                self.horizontalImage = [[UIImageView alloc] initWithImage:[self fetchImage:@"arrow-right"]];
                CGRect imageViewFrame = self.horizontalImage.frame;
                imageViewFrame.origin.x = self.bounds.size.width - self.horizontalImage.frame.size.width - kLabelMargin - markRect.size.width;
                imageViewFrame.origin.y = y + self.lblCaption.frame.size.height/2 - imageViewFrame.size.height/2;
                self.horizontalImage.frame = imageViewFrame;
                x -= (self.horizontalImage.frame.size.width + kLabelMargin);
                [self addSubview:self.horizontalImage];
            }
        }
            break;
        case LABEL_POSITION_RIGHT:
        {
            y = markRect.origin.y + markRect.size.height/2 - self.lblCaption.frame.size.height/2;
            x = markRect.origin.x + markRect.size.width + kLabelMargin;
            if(showArrow) {
                BOOL pdvGallery = NO;
                
                if( [markDef objectForKey:@"PDVGallery"])
                    pdvGallery = [[markDef objectForKey:@"PDVGallery"] boolValue];
                
                if(pdvGallery){
                    self.verticalImage = [[UIImageView alloc] initWithImage:[self fetchImage:@"zoom_iPhone.png"]];
                }
                else if([markDef objectForKey:@"addToCart"]){
                    break;
                }
                else{
                    self.verticalImage = [[UIImageView alloc] initWithImage:[self fetchImage:@"tap_iPhone.png"]];
                }
                CGRect imageViewFrame = self.verticalImage.frame;
                imageViewFrame.origin = self.center;
                imageViewFrame.origin.y -= 40;
                if(pdvGallery){
                    imageViewFrame.origin.x -= 60;
                }
                else{
                    imageViewFrame.origin.x -= 40;
                }
                self.verticalImage.frame = imageViewFrame;

            [self addSubview:self.verticalImage];
    
            }
        }
            break;
        case LABEL_POSITION_RIGHT_BOTTOM:
        {
            y = markRect.origin.y + markRect.size.height + self.lblSpacing;
            CGFloat bottomY = y + self.lblCaption.frame.size.height + self.lblSpacing;
            if (bottomY > self.bounds.size.height) {
                y = markRect.origin.y - self.lblSpacing - self.lblCaption.frame.size.height;
            }
            x = markRect.origin.x + markRect.size.width + kLabelMargin;
            if(showArrow) {
                self.horizontalImage = [[UIImageView alloc] initWithImage:[self fetchImage:@"arrow-top"]];
                CGRect imageViewFrame = self.horizontalImage.frame;
                imageViewFrame.origin.x = x - markRect.size.width/2 - imageViewFrame.size.width/2;
                imageViewFrame.origin.y = y - kLabelMargin; //self.lblCaption.frame.size.height/2
                y += imageViewFrame.size.height/2;
                self.horizontalImage.frame = imageViewFrame;
                [self addSubview:self.horizontalImage];
            }
        }
            break;
        default: {
            //vertical
            CGFloat  y2 = markRect.origin.y + markRect.size.height + self.lblSpacing;
            CGFloat bottomY = y2 + self.lblCaption.frame.size.height + self.lblSpacing;
            if (bottomY > self.bounds.size.height) {
                y2 = markRect.origin.y - self.lblSpacing - self.lblCaption.frame.size.height;
            }
            if(showArrow) {

                BOOL productDetailPage = NO;
                if( [markDef objectForKey:@"productDetailPage"])
                    productDetailPage = [[markDef objectForKey:@"productDetailPage"] boolValue];
                
                if(productDetailPage){
                    self.verticalImage = [[UIImageView alloc] initWithImage:[self fetchImage:@"scrollDown_iPhone.png"]];
                    //                    self.verticalImage = [[UIImageView alloc] initWithImage:[self fetchImage:@"slideFingerHorizontal_iPhone.png"]];
                }
                else{
                    self.verticalImage = [[UIImageView alloc] initWithImage:[self fetchImage:@"slideFingerHorizontal_iPhone.png"]];
                }
                CGRect imageViewFrame = self.verticalImage.frame;
                imageViewFrame.origin.x = self.center.x;
                imageViewFrame.origin.y = self.center.y; //self.lblCaption.frame.size.height/2
                if(productDetailPage){
                    imageViewFrame.origin.y = self.center.y;
                    imageViewFrame.origin.x -= 20;
                }

                y2 += imageViewFrame.size.height/2;
                self.verticalImage.frame = imageViewFrame;
                [self addSubview:self.verticalImage];
            }
        }
            break;
    }
    
    // Animate the caption label
    self.lblCaption.frame = (CGRect){{x, y}, self.lblCaption.frame.size};
    
    if(showArrow){
        
        BOOL pdvGallery = NO;
        if( [markDef objectForKey:@"PDVGallery"])
            pdvGallery = [[markDef objectForKey:@"PDVGallery"] boolValue];

        if(pdvGallery){
            self.lblCaption.center = self.center;
             CGRect lblCaptionFrame = self.lblCaption.frame;
            lblCaptionFrame.origin.y -= 80;
            self.lblCaption.frame = lblCaptionFrame;
            self.verticalImage = [[UIImageView alloc] initWithImage:[self fetchImage:@"zoom_iPhone.png"]];
            self.verticalImage.x -= 30;
        }
        else if([markDef objectForKey:@"addToCart"]){
            self.lblCaption.frame = (CGRect){{20, self.lblCaption.frame.origin.y - 50}, self.lblCaption.frame.size};
        }
        else{
            // Animate the caption label
            self.lblCaption.frame = (CGRect){{self.verticalImage.frame.origin.x, y}, self.lblCaption.frame.size};
        }
        BOOL productDetailPage = NO;
        if( [markDef objectForKey:@"productDetailPage"])
            productDetailPage = [[markDef objectForKey:@"productDetailPage"] boolValue];
        
        if(productDetailPage){
            self.lblCaption.center = self.center;
            CGRect lblCaptionFrame = self.lblCaption.frame;
            lblCaptionFrame.origin.y -= 60;
            self.lblCaption.frame = lblCaptionFrame;
        }
        else{
            // caption2 and 3 for scroll screen
            NSDictionary *markDef = [self.coachMarks objectAtIndex:index];
            NSString *verticalText = [markDef objectForKey:@"caption2"];
            NSString *verticalText2 = [markDef objectForKey:@"caption3"];
            
            self.verticalCaption = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {self.maxLblWidth, 0.0f}}];
            
            self.verticalCaption.backgroundColor = [UIColor clearColor];
            self.verticalCaption.textColor = [UIColor whiteColor];
            self.verticalCaption.font = [UIFont fontWithName:@"Bamilo-Sans" size:12.0f];
            self.verticalCaption.lineBreakMode = NSLineBreakByWordWrapping;
            self.verticalCaption.numberOfLines = 0;
            self.verticalCaption.textAlignment = NSTextAlignmentRight;
            self.verticalCaption.text = verticalText;
            [self.verticalCaption sizeToFit];
            
            self.verticalCaption.frame = (CGRect){{self.verticalImage.frame.origin.x, y+ 120}, self.lblCaption.frame.size};
            
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                self.verticalCaption.frame = (CGRect){{self.verticalImage.frame.origin.x, y+ 180}, self.lblCaption.frame.size};
            }
            [self addSubview:self.verticalCaption];
            
            self.verticalCaption2 = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {self.maxLblWidth, 0.0f}}];
            self.verticalCaption2.backgroundColor = [UIColor clearColor];
            self.verticalCaption2.textColor = [UIColor whiteColor];
            self.verticalCaption2.font = [UIFont fontWithName:@"Bamilo-Sans" size:12.0f];
            self.verticalCaption2.lineBreakMode = NSLineBreakByWordWrapping;
            self.verticalCaption2.numberOfLines = 0;
            self.verticalCaption2.textAlignment = NSTextAlignmentRight;
            
            self.verticalCaption2.text = verticalText2;
            [self.verticalCaption2 sizeToFit];
            self.verticalCaption2.frame = (CGRect){{self.horizontalImage.frame.origin.x, y+ 220}, self.verticalCaption2.frame.size};
            
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                self.verticalCaption2.frame = (CGRect){{self.horizontalImage.frame.origin.x, y+ 320}, self.verticalCaption2.frame.size};
            }
            [self addSubview:self.verticalCaption2];
        }
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        self.lblCaption.alpha = 1.0f;
    }];
    
    // Delegate (coachMarksView:willNavigateTo:atIndex:)
    if ([self.delegate respondsToSelector:@selector(coachMarksView:willNavigateToIndex:)]) {
        [self.delegate coachMarksView:self willNavigateToIndex:markIndex];
    }
    
    // If first mark, set the cutout to the center of first mark
    if (markIndex == 0) {
        CGPoint center = CGPointMake(floorf(markRect.origin.x + (markRect.size.width / 2.0f)), floorf(markRect.origin.y + (markRect.size.height / 2.0f)));
        CGRect centerZero = (CGRect){center, CGSizeZero};
        [self setCutoutToRect:centerZero withShape:shape];
        [self setOuterCircle:markRect];
    }
    
    //as its an image remove outerringcircle
    if(showArrow){
        [self.outerCircleImageView setHidden:TRUE];
    }
    else{
        [self.outerCircleImageView setHidden:FALSE];
    }

    CGRect currentRect = CGRectMake(markRect.origin.x-45, markRect.origin.y-45, markRect.size.width+90, markRect.size.height+90);
    // Animate the cutout
    [self animateCutoutToRect:markRect withShape:shape];
    [self animateOuterCircle:previousCircleFrame toPosition:currentRect];
    
    CGFloat lblContinueWidth = 120.0f;
    //    CGFloat btnSkipWidth = self.bounds.size.width - lblContinueWidth;
    
    // Show continue lbl if first mark
    if (self.enableContinueLabel) {
        lblContinue = [[UIButton alloc] initWithFrame:(CGRect){{self.bounds.size.width / 2, [self yOriginForContinueLabel]}, {lblContinueWidth, 50.0f}}];
        lblContinue.center = self.center;
        CGRect continueButtonFrame = lblContinue.frame;
        continueButtonFrame.origin.y += 100.0;
        [lblContinue addTarget:self action:@selector(didClickNextButton:) forControlEvents:UIControlEventTouchUpInside];
        BOOL pdvGallery = NO;
        if( [markDef objectForKey:@"PDVGallery"])
            pdvGallery = [[markDef objectForKey:@"PDVGallery"] boolValue];
        
        if(!pdvGallery){
            if (markIndex == [coachMarks count]-1){
                self.continueLabelText = KOkGotIt;
                continueButtonFrame.origin.y += 110.0;
            }
        }
        else{
            self.continueLabelText = KOkGotIt;
            continueButtonFrame.origin.y += 50.0;
        }
        lblContinue.frame = continueButtonFrame;
        [lblContinue setTitle: self.continueLabelText forState: UIControlStateNormal];
        lblContinue.titleLabel.font = [UIFont fontWithName:@"Bamilo-Sans" size:20.0f];;
        lblContinue.layer.borderWidth = 1.0f;
        lblContinue.layer.borderColor = [UIColor whiteColor].CGColor;
        [self addSubview:lblContinue];
    }
    
    if (self.enableSkipButton) {
        btnSkipCoach = [[UIButton alloc] initWithFrame:(CGRect){{self.bounds.size.width / 2, [self yOriginForContinueLabel] + 50}, {lblContinueWidth, 50.0f}}];
        btnSkipCoach.center = CGPointMake(self.bounds.size.width  / 2,
                                          self.bounds.size.height / 2 +150);
        [btnSkipCoach addTarget:self action:@selector(skipCoach) forControlEvents:UIControlEventTouchUpInside];
        NSDictionary *attrDict = @{NSFontAttributeName : [UIFont
                                                          fontWithName:@"Bamilo-Sans" size:10.0],NSForegroundColorAttributeName : [UIColor
                                                                                                                                   whiteColor]};
        NSMutableAttributedString *title =[[NSMutableAttributedString alloc] initWithString:self.skipButtonText attributes: attrDict];
        [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0,[title length])];
        [btnSkipCoach setAttributedTitle:title forState:UIControlStateNormal];
        btnSkipCoach.tintColor = [UIColor whiteColor];
        [self addSubview:btnSkipCoach];
        if (markIndex == [coachMarks count]-1){
            [self.btnSkipCoach removeFromSuperview];
        }
        //        [UIView animateWithDuration:0.3f delay:1.0f options:0 animations:^{
        //            btnSkipCoach.alpha = 1.0f;
        //        } completion:nil];
    }
}

- (CGFloat)yOriginForContinueLabel {
    switch (self.continueLocation) {
        case LOCATION_TOP:
            return 20.0f;
        case LOCATION_CENTER:
            return self.bounds.size.height / 2 + 60.0f;
        default:
            return self.bounds.size.height - 30.0f;
    }
}

#pragma mark - Cleanup

- (void)cleanup {
    // Delegate (coachMarksViewWillCleanup:)
    if ([self.delegate respondsToSelector:@selector(coachMarksViewWillCleanup:)]) {
        [self.delegate coachMarksViewWillCleanup:self];
    }
    
    // Fade out self
    [UIView animateWithDuration:self.animationDuration
                     animations:^{
                         self.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         // Remove self
                         [self removeFromSuperview];
                         
                         // Delegate (coachMarksViewDidCleanup:)
                         if ([self.delegate respondsToSelector:@selector(coachMarksViewDidCleanup:)]) {
                             [self.delegate coachMarksViewDidCleanup:self];
                         }
                     }];
}

#pragma mark - Animation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    // Delegate (coachMarksView:didNavigateTo:atIndex:)
    if ([self.delegate respondsToSelector:@selector(coachMarksView:didNavigateToIndex:)]) {
        [self.delegate coachMarksView:self didNavigateToIndex:markIndex];
    }
}

@end

