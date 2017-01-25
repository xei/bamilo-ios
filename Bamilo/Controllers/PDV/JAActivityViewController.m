//
//  JAActivityViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 04/Sep/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAActivityViewController.h"

@interface JAActivityViewController ()

@end

@implementation JAActivityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {

    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if([_delegate conformsToProtocol:@protocol(JAActivityViewControllerDelegate)] && [_delegate respondsToSelector:@selector(willDismissActivityViewController:)])
    {
        [_delegate willDismissActivityViewController:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
