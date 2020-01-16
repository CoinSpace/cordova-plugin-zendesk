#import "Zendesk.h"

@import ZendeskSDK;
@import ZendeskCoreSDK;
#import <CommonUISDK/CommonUISDK-Swift.h>

@implementation Zendesk

- (void)initialize:(CDVInvokedUrlCommand *)command {
  NSString *appId = [command.arguments objectAtIndex:0];
  NSString *clientId = [command.arguments objectAtIndex:1];
  NSString *zendeskUrl = [command.arguments objectAtIndex:2];
  
  [ZDKZendesk initializeWithAppId:appId clientId:clientId zendeskUrl:zendeskUrl];
  [ZDKSupport initializeWithZendesk: [ZDKZendesk instance]];
  [ZDKTheme currentTheme].primaryColor = [UIColor colorWithRed:0.14 green:0.48 blue:0.29 alpha:1.0];
  
  [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)setAnonymousIdentity:(CDVInvokedUrlCommand *)command { 
  NSString *name = @"user";

  id<ZDKObjCIdentity> userIdentity = [[ZDKObjCAnonymous alloc] initWithName:name email:nil];
  [[ZDKZendesk instance] setIdentity:userIdentity];

  [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId]; 
}

- (void)showHelpCenter:(CDVInvokedUrlCommand *)command {
  ZDKHelpCenterUiConfiguration *helpCenterConfig = [ZDKHelpCenterUiConfiguration new];
  ZDKRequestUiConfiguration *requestConfig = [ZDKRequestUiConfiguration new];
  requestConfig.tags = @[@"mobile", @"ios"];
  
  NSString *groupType = [command.arguments objectAtIndex: 0];
  NSArray *groupIds = [command.arguments objectAtIndex: 1];
  NSArray *labels = [command.arguments objectAtIndex:2];
  
  if (![groupType isEqual:[NSNull null]] && ![groupIds isEqual:[NSNull null]]) {
    if ([groupType isEqualToString:@"category"]) {
      [helpCenterConfig setGroupType:ZDKHelpCenterOverviewGroupTypeCategory];
    } else if ([groupType isEqualToString:@"section"]) {
      [helpCenterConfig setGroupType:ZDKHelpCenterOverviewGroupTypeSection];
    } else {
      [helpCenterConfig setGroupType:ZDKHelpCenterOverviewGroupTypeDefault];
    }
    
    [helpCenterConfig setGroupIds:groupIds];
  }
  
  if (![labels isEqual:[NSNull null]]) {
    helpCenterConfig.labels = labels;
  }

  UIViewController *helpCenterController = [ZDKHelpCenterUi buildHelpCenterOverviewUiWithConfigs:@[helpCenterConfig, requestConfig]];
  [self presentViewController:helpCenterController];
  
  [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)showHelpCenterArticle:(CDVInvokedUrlCommand *)command {
  NSString *articleId = [command.arguments objectAtIndex:0];
  
  UIViewController *articleController = [ZDKHelpCenterUi buildHelpCenterArticleUiWithArticleId:articleId andConfigs:@[]];
  [self presentViewController:articleController];
  [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)showTicketRequest:(CDVInvokedUrlCommand *)command {
  NSString *subject = [command.arguments objectAtIndex:0];
  NSArray *tags = [command.arguments objectAtIndex:1];
  
  ZDKRequestUiConfiguration *config = [ZDKRequestUiConfiguration new];
  
  if (![subject isEqual:[NSNull null]]) {
    config.subject = subject;
  }
  
  if (![tags isEqual:[NSNull null]]) {
    config.tags = tags;
  }
  
  UIViewController *ticketRequestController = [ZDKRequestUi buildRequestUiWith:@[config]];
  [self presentViewController:ticketRequestController];
  
  [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)showUserTickets:(CDVInvokedUrlCommand *)command {
  UIViewController *requestListController = [ZDKRequestUi buildRequestList];
  [self presentViewController:requestListController];
  
  [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)presentViewController:(UIViewController *)viewController {
  UINavigationController *navigationController = [[UINavigationController alloc] init];
  [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:navigationController animated:YES completion:^{}];
  [navigationController pushViewController:viewController animated:YES];
}

@end
