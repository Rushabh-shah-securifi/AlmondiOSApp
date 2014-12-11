//
//  UIViewController(SFIViewController).h
//
//  Created by sinclair on 11/9/14.
//
#import "UIViewController+Securifi.h"
#import "iToast.h"


@implementation UIViewController (Securifi)

#pragma mark - Toast

- (void)showToast:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^() {
        iToast *toast = [iToast makeText:msg];
        toast = [toast setGravity:iToastGravityBottom];
        toast = [toast setDuration:2000];
        [toast show:iToastTypeWarning];
    });
}

- (void)showSavingToast {
    [self showToast:NSLocalizedString(@"toast.Saving...", @"Saving...")];
}

@end