//
//  BamiloUITests.m
//  BamiloUITests
//
//  Created by Narbeh Mirzaei on 1/21/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface BamiloUITests : XCTestCase

@end

@implementation BamiloUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_A_UserRegister {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    
    XCUIElement *onboardingSkipButton = app.buttons[@"بستن"];
    [self waitForElementToAppear:onboardingSkipButton withTimeout:5];
    
    if (onboardingSkipButton.exists) {
        [onboardingSkipButton tap];
    }
    
    [self navigateToLoginOrRegisterFromTabBar:app];
    
    XCUIElement *emailBamiloComTextField = app.scrollViews.textFields[@"email@bamilo.com"];
    if (emailBamiloComTextField.exists) {
        [emailBamiloComTextField tap];
        [emailBamiloComTextField typeText:[NSString stringWithFormat:@"narbeh.mirzaei-%d@bamilo.com", arc4random() % 999999]];
        [app.scrollViews.otherElements.buttons[@"ادامه"] tap];
        
        XCUIElement *socialSecurityNumberTextField = app.scrollViews.otherElements.textFields[@"کد ملی"];
        [socialSecurityNumberTextField tap];
        [socialSecurityNumberTextField typeText:@"9999999999"];
        
        XCUIElement *firstNameTextField = app.scrollViews.otherElements.textFields[@"نام"];
        [firstNameTextField tap];
        [firstNameTextField typeText:@"ناربه"];
        
        XCUIElement *lastNameTextField = app.scrollViews.otherElements.textFields[@"نام خانوادگی"];
        [lastNameTextField tap];
        [lastNameTextField typeText:@"میرزائی"];
        
        XCUIElement *passwordTextField = app.scrollViews.otherElements.secureTextFields[@"رمز عبور جدید"];
        [passwordTextField tap];
        [passwordTextField typeText:@"123456"];
        
        XCUIElement *cellphoneTextField = app.scrollViews.otherElements.textFields[@"تلفن همراه"];
        [cellphoneTextField tap];
        [cellphoneTextField typeText:@"09125556666"];
        
        [app.toolbars.buttons[@"اعمال"] tap];
        [app.buttons[@"ادامه"] tap];
    }
}

- (void)test_B_UserLogin {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    
    [self navigateToLoginOrRegisterFromTabBar:app];

    XCUIElement *emailBamiloComTextField = app.scrollViews.textFields[@"email@bamilo.com"];
    if (emailBamiloComTextField.exists) {
        [emailBamiloComTextField tap];
        [emailBamiloComTextField typeText:@"narbeh.mirzaei@bamilo.com"];
        
        [app.buttons[@"ادامه"] tap];
        
        XCUIElement *passwordTextField = app.scrollViews.otherElements.secureTextFields[@"رمز عبور جدید"];
        [passwordTextField tap];
        [passwordTextField typeText:@"123456\n"];
        
        [app.buttons[@"ادامه"] tap];
    }
}

//MARK: - Private methods
- (void)navigateToLoginOrRegisterFromTabBar:(XCUIApplication *)app {
    XCUIElementQuery *userFlow = [[[[[[[[[app childrenMatchingType:XCUIElementTypeWindow] elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther];
    
    XCUIElementQuery *tabBar = [[userFlow elementBoundByIndex:1] childrenMatchingType:XCUIElementTypeOther];
    
    //Tap بیشتر
    [[[[tabBar elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeButton].element tap];
    
    //Tap ورود
    [[[[[[[userFlow elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther] elementBoundByIndex:2] childrenMatchingType:XCUIElementTypeButton].element tap];
}

//MARK: - Helpers
- (void)waitForElementToAppear:(XCUIElement *)element withTimeout:(NSTimeInterval)timeout
{
    NSUInteger line = __LINE__;
    NSString *file = [NSString stringWithUTF8String:__FILE__];
    NSPredicate *existsPredicate = [NSPredicate predicateWithFormat:@"exists == true"];
    
    [self expectationForPredicate:existsPredicate evaluatedWithObject:element handler:nil];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSString *message = [NSString stringWithFormat:@"Failed to find %@ after %f seconds",element,timeout];
            [self recordFailureWithDescription:message inFile:file atLine:line expected:YES];
        }
    }];
}

- (void)forceTapElement:(XCUIElement *)element {
    if (element.hittable) {
        [element tap];
    } else {
        XCUICoordinate *elementCoordinate = [element coordinateWithNormalizedOffset:CGVectorMake(0, 0)];
        [elementCoordinate tap];
    }
}

@end
