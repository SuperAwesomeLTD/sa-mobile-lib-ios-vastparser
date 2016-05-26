//
//  SAExtensions.m
//  Pods
//
//  Created by Gabriel Coman on 09/03/2016.
//
//

#import "SAExtensions.h"
#import <objc/runtime.h>

////////////////////////////////////////////////////////////////////////////////
// SuperAwesome extension for NSDictionary
////////////////////////////////////////////////////////////////////////////////

@implementation NSDictionary (SAExtensions)

- (void) enumerateKeysAndObjectsUsingBlock:(void (^)(id _Nonnull, id _Nonnull, BOOL * _Nonnull))block atEnd:(void (^)())end {
    [self enumerateKeysAndObjectsUsingBlock:block];
    end();
}

@end

////////////////////////////////////////////////////////////////////////////////
// SuperAwesome extension for NSArray
////////////////////////////////////////////////////////////////////////////////

@implementation NSArray (SAExtensions)

- (NSArray*) filterBy:(NSString*) member withValue:(NSString*) value {
    NSMutableArray *_mutableSelf = [self mutableCopy];
    NSPredicate *searchPred = [NSPredicate predicateWithFormat:@"%K CONTAINS[c] %@", member, value];
    return [_mutableSelf filteredArrayUsingPredicate:searchPred];
}

- (NSArray*) filterBy:(NSString *)member withBool:(BOOL)value {
    NSMutableArray *_mutableSelf = [self mutableCopy];
    NSPredicate *searchPref = [NSPredicate predicateWithFormat:@"%K == %d", member, value];
    return [_mutableSelf filteredArrayUsingPredicate:searchPref];
}

- (NSArray*) removeAllButFirstElement {
    NSMutableArray *_mutableSelf = [self mutableCopy];
    
    if (_mutableSelf.count >= 1) {
        return [[NSMutableArray alloc] initWithObjects:[_mutableSelf firstObject], nil];
    } else {
        return _mutableSelf;
    }
}

@end

////////////////////////////////////////////////////////////////////////////////
// SuperAwesome extension for UIAlertController
////////////////////////////////////////////////////////////////////////////////


@interface UIAlertController (Private)
@property (nonatomic, strong) UIWindow *alertWindow;
@end

@implementation UIAlertController (Private)

@dynamic alertWindow;

- (void) setAlertWindow:(UIWindow *)alertWindow {
    objc_setAssociatedObject(self, @selector(alertWindow), alertWindow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIWindow *)alertWindow {
    return objc_getAssociatedObject(self, @selector(alertWindow));
}

@end

@implementation UIAlertController (SAExtensions)

- (void)show {
    [self show:YES];
}

- (void)show:(BOOL)animated {
    self.alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.alertWindow.rootViewController = [[UIViewController alloc] init];
    self.alertWindow.windowLevel = UIWindowLevelAlert + 1;
    [self.alertWindow makeKeyAndVisible];
    [self.alertWindow.rootViewController presentViewController:self animated:animated completion:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.alertWindow.hidden = YES;
    self.alertWindow = nil;
}

@end