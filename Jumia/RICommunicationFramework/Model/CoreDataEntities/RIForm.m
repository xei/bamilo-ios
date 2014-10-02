//
//  RIForm.m
//  Comunication Project
//
//  Created by Telmo Pinto on 23/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIForm.h"
#import "RIField.h"
#import "RIFieldDataSetComponent.h"
#import "RICustomer.h"
#import "RIFieldOption.h"
#import "RICheckout.h"
#import "RINewsletterCategory.h"

@implementation RIForm

@dynamic uid;
@dynamic method;
@dynamic action;
@dynamic fields;
@dynamic formIndex;

+ (NSString*)getForm:(NSString*)formIndexID
        successBlock:(void (^)(id form))successBlock
        failureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock;
{
    //get form for index
    return [RIFormIndex getFormWithIndexId:formIndexID successBlock:^(RIFormIndex* formIndex) {
        
        if (VALID_NOTEMPTY(formIndex, RIFormIndex) && VALID_NOTEMPTY(formIndex.form, RIForm)) {
            //index has form
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(formIndex.form);
            });
        } else {
            
            if (VALID_NOTEMPTY(formIndex.url, NSString)) {
                
                [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:formIndex.url]
                                                                 parameters:nil httpMethodPost:YES
                                                                  cacheType:RIURLCacheNoCache
                                                                  cacheTime:RIURLCacheDefaultTime
                                                               successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                                   
                                                                   NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                   
                                                                   if (VALID_NOTEMPTY(metadata, NSDictionary) && VALID_NOTEMPTY([metadata objectForKey:@"data"], NSArray)) {
                                                                       NSArray* data = [metadata objectForKey:@"data"];
                                                                       
                                                                       // Update user newsletter preferences
                                                                       for (NSDictionary *dic in data)
                                                                       {
                                                                           if ([dic objectForKey:@"id"])
                                                                           {
                                                                               if ([[dic objectForKey:@"id"] isEqualToString:@"Alice_Module_Mobapi_Form_Ext1m3_Customer_NewsletterManageForm"])
                                                                               {
                                                                                   NSArray *fields = [dic objectForKey:@"fields"];
                                                                                   
                                                                                   for (NSDictionary *field in fields)
                                                                                   {
                                                                                       NSArray *options = [field objectForKey:@"options"];
                                                                                       
                                                                                       [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RINewsletterCategory class])];
                                                                                       [[RIDataBaseWrapper sharedInstance] saveContext];
                                                                                       
                                                                                       for (NSDictionary *optionField in options)
                                                                                       {
                                                                                           NSInteger subs = [[optionField objectForKey:@"user_subscribed"] integerValue];
                                                                                           
                                                                                           if (1 == subs)
                                                                                           {
                                                                                               NSMutableDictionary *temp = [NSMutableDictionary new];
                                                                                               
                                                                                               if ([optionField objectForKey:@"value"]) {
                                                                                                   [temp addEntriesFromDictionary:@{@"id_newsletter_category" : [optionField objectForKey:@"value"]} ];
                                                                                               }
                                                                                               
                                                                                               if ([optionField objectForKey:@"label"]) {
                                                                                                   [temp addEntriesFromDictionary:@{@"name" : [optionField objectForKey:@"label"]} ];
                                                                                               }
                                                                                               
                                                                                               RINewsletterCategory *tempNews = [RINewsletterCategory parseNewsletterCategory:[temp copy]];
                                                                                               [RINewsletterCategory saveNewsLetterCategory:tempNews];
                                                                                           }
                                                                                       }
                                                                                   }
                                                                               }
                                                                           }
                                                                       }
                                                                       
                                                                       RIForm* newForm = [RIForm parseForm:[data firstObject]];
                                                                       
                                                                       [RIForm saveForm:newForm];
                                                                       newForm.formIndex = formIndex;
                                                                       formIndex.form = newForm;
                                                                       //form index was already on database, it just lacked the form variable. let's save the context without adding any other NSManagedObject
                                                                       [[RIDataBaseWrapper sharedInstance] saveContext];
                                                                       
                                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                                           successBlock(newForm);
                                                                       });
                                                                   } else {
                                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                                           failureBlock(apiResponse, nil);
                                                                       });
                                                                   }
                                                                   
                                                               } failureBlock:^(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject) {
                                                                   if(NOTEMPTY(errorJsonObject))
                                                                   {
                                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                                           failureBlock(apiResponse, [RIError getErrorMessages:errorJsonObject]);
                                                                       });
                                                                   } else if(NOTEMPTY(errorObject))
                                                                   {
                                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                                           NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                           failureBlock(apiResponse, errorArray);
                                                                       });
                                                                   } else
                                                                   {
                                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                                           failureBlock(apiResponse, nil);
                                                                       });
                                                                   }
                                                               }];
            }
        }
        
        return;
        
        
    } andFailureBlock:failureBlock];
}

#pragma mark - Facebook Login
+ (NSString*)sendForm:(RIForm*)form
         successBlock:(void (^)(id object))successBlock
      andFailureBlock:(void (^)(RIApiResponse apiResponse, id errorObject))failureBlock
{
    return [RIForm sendForm:form
                 parameters:[RIForm getParametersForForm:form]
               successBlock:successBlock
            andFailureBlock:failureBlock];
}

+ (NSString*)sendForm:(RIForm*)form
           parameters:(NSDictionary*)parameters
         successBlock:(void (^)(id object))successBlock
      andFailureBlock:(void (^)(RIApiResponse apiResponse, id errorObject))failureBlock
{
    BOOL isPostRequest = [@"post" isEqualToString:[form.method lowercaseString]];
    
    NSMutableDictionary *allParameters = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    for(RIField *formField in form.fields)
    {
        if([@"hidden" isEqualToString:formField.type] && ![parameters objectForKey:formField.name])
        {
            [allParameters setValue:formField.value forKey:formField.name];
        }
    }
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:form.action]
                                                            parameters:allParameters
                                                        httpMethodPost:isPostRequest
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              
                                                              NSString *password = nil;
                                                              NSArray *parameterKeys = [parameters allKeys];
                                                              for(NSString *key in parameterKeys)
                                                              {
                                                                  if(NSNotFound != [[key lowercaseString] rangeOfString:@"password"].location)
                                                                  {
                                                                      password = [parameters objectForKey:key];
                                                                      break;
                                                                  }
                                                              }
                                                              
                                                              BOOL responseProcessed = NO;
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                              {
                                                                  if([@"form-account-login" isEqualToString:form.uid])
                                                                  {
                                                                      responseProcessed = YES;
                                                                      RICustomer *customer = [RICustomer parseCustomerWithJson:[metadata objectForKey:@"user"] plainPassword:password loginMethod:@"normal"];
                                                                      successBlock(customer);
                                                                  }
                                                                  else if([@"Alice_Module_Mobapi_Form_Ext1m4_Customer_RegistrationForm" isEqualToString:form.uid])
                                                                  {
                                                                      responseProcessed = YES;
                                                                      RICustomer *customer = [RICustomer parseCustomerWithJson:metadata plainPassword:password loginMethod:@"normal"];
                                                                      successBlock(customer);
                                                                  }
                                                                  else if([@"Alice_Module_Mobapi_Form_Ext1m1_Customer_RegisterSignupForm" isEqualToString:form.uid])
                                                                  {
                                                                      NSDictionary *data = [metadata objectForKey:@"data"];
                                                                      if(VALID_NOTEMPTY(data, NSDictionary))
                                                                      {
                                                                          responseProcessed = YES;
                                                                          RICustomer *customer = [RICustomer parseCustomerWithJson:[data objectForKey:@"user"] plainPassword:password loginMethod:@"signup"];
                                                                          successBlock(customer);
                                                                      }
                                                                  }
                                                                  else if([@"address-form" isEqualToString:form.uid])
                                                                  {
                                                                      responseProcessed = YES;
                                                                      RICheckout *checkout = [RICheckout parseCheckout:metadata country:nil];
                                                                      successBlock(checkout);
                                                                  }
                                                                  else if ([@"Alice_Module_Mobapi_Form_Ext1m3_Customer_NewsletterManageForm" isEqualToString:form.uid])
                                                                  {
                                                                      [RICustomer updateCustomerNewsletterWithJson:metadata];
                                                                      responseProcessed = YES;
                                                                      successBlock(nil);
                                                                  }
                                                                  else
                                                                  {
                                                                      responseProcessed = YES;
                                                                      successBlock(metadata);
                                                                  }
                                                              }
                                                              else
                                                              {
                                                                  responseProcessed = YES;
                                                                  successBlock(nil);
                                                              }
                                                              
                                                              if(!responseProcessed)
                                                              {
                                                                  failureBlock(apiResponse, nil);
                                                              }
                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if(NOTEMPTY(errorJsonObject))
                                                              {
                                                                  NSDictionary *errorDictionary = [RIError getErrorDictionary:errorJsonObject];
                                                                  NSArray *errorArray = [RIError getErrorMessages:errorJsonObject];
                                                                  if(VALID_NOTEMPTY(errorDictionary, NSDictionary))
                                                                  {
                                                                      failureBlock(apiResponse, errorDictionary);
                                                                  }
                                                                  else if(VALID_NOTEMPTY(errorArray, NSArray))
                                                                  {
                                                                      failureBlock(apiResponse, errorArray);
                                                                  }
                                                                  else
                                                                  {
                                                                      failureBlock(apiResponse, nil);
                                                                  }
                                                              }
                                                              else if(NOTEMPTY(errorObject))
                                                              {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(apiResponse, errorArray);
                                                              }
                                                              else
                                                              {
                                                                  failureBlock(apiResponse, nil);
                                                              }
                                                          }];
}

+ (RIForm *)parseForm:(NSDictionary *)formDict;
{
    RIForm* newForm = (RIForm*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIForm class])];
    
    if (VALID_NOTEMPTY(formDict, NSDictionary)) {
        
        if ([formDict objectForKey:@"id"]) {
            newForm.uid = [formDict objectForKey:@"id"];
        }
        if ([formDict objectForKey:@"action"]) {
            newForm.action = [formDict objectForKey:@"action"];
        }
        if ([formDict objectForKey:@"method"]) {
            newForm.method = [formDict objectForKey:@"method"];
        }
        
        NSArray* fields = [formDict objectForKey:@"fields"];
        
        if (VALID_NOTEMPTY(fields, NSArray)) {
            for (NSDictionary* fieldJSON in fields) {
                RIField* newField = [RIField parseField:fieldJSON];
                newField.form = newForm;
                [newForm addFieldsObject:newField];
            }
        }
    }
    
    return newForm;
}

+ (void)saveForm:(RIForm *)form;
{
    for (RIField* field in form.fields) {
        
        for (RIFieldDataSetComponent *component in field.dataSet) {
            [RIFieldDataSetComponent saveFieldDataSetComponent:component];
        }
        
        for(RIFieldOption *option in field.options)
        {
            [RIFieldOption saveFieldOption:option];
        }
        
        [RIField saveField:field];
    }
    
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:form];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

+ (NSDictionary *) getParametersForForm:(RIForm *)form
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    for(RIField *field in form.fields)
    {
        if(VALID_NOTEMPTY(field.value, NSString) && VALID_NOTEMPTY(field.name, NSString))
        {
            [parameters setValue:field.value forKey:field.name];
        }
    }
    return [parameters copy];
}

#pragma mark - Cancel requests

+ (void)cancelRequest:(NSString *)operationID
{
    if(VALID_NOTEMPTY(operationID, NSString))
        [[RICommunicationWrapper sharedInstance] cancelRequest:operationID];
}

@end
