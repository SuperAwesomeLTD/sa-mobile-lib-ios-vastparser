/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

#import "SAAlert.h"
#import "SAUtils.h"
#import "SAExtensions.h"

// other imports for the alert view
#define SA_OK_BUTTON                                    0
#define SA_CANCEL_BUTTON                                1

@interface SAAlert ()
@property (nonatomic, strong) UIAlertController         *popupController;
@property (nonatomic, strong) UIAlertView               *popupAlertView;

// instance vars holding the current alert view state
@property (nonatomic, strong) NSString                  *title;
@property (nonatomic, strong) NSString                  *message;
@property (nonatomic, strong) NSString                  *okTitle;
@property (nonatomic, strong) NSString                  *nokTitle;
@property (nonatomic, assign) BOOL                      hasTextField;
@property (nonatomic, assign) UIKeyboardType            keyboardType;

// current click handler
@property (nonatomic, strong) saDidClickOnAlertButton   handler;

@end

@implementation SAAlert

+ (instancetype) getInstance {
    static SAAlert *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (void) showWithTitle:(NSString*)title
            andMessage:(NSString*)message
            andOKTitle:(NSString*)okTitle
           andNOKTitle:(NSString*)nokTitle
          andTextField:(BOOL)hasInput
       andKeyboardTyle:(UIKeyboardType)inputType
            andPressed:(saDidClickOnAlertButton)handler {
    
    _title = title != NULL ? title : @"Title";
    _message = message != NULL ? message : @"Alert";
    _okTitle = okTitle != NULL ? okTitle : @"OK";
    _nokTitle = nokTitle;
    _hasTextField = hasInput;
    _keyboardType = inputType;
    _handler = handler != NULL ? handler : ^(int button, NSString* message) {};
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [self showWithAlertController];
    } else {
        [self showWithAlertView];
    }
    
}

/**
 * Method that closes the alert view in different ways, depending 
 * on iOS version
 */
- (void) close {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [_popupController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [_popupAlertView dismissWithClickedButtonIndex:0 animated:YES];
    }
}
/**
 * MARK: iOS 8.0+
 * Method that shows the current alert controller
 */
- (void) showWithAlertController {
    
    id iOKBlock = ^(UIAlertAction *action) {
        if (_hasTextField) {
            UITextField *textField = [[_popupController textFields] firstObject];
            NSString *text = [textField text];
            _handler(SA_OK_BUTTON, text);
        } else {
            _handler(SA_OK_BUTTON, nil);
        }
    };
    id iNOKBlock = ^(UIAlertAction *action) {
        _handler(SA_CANCEL_BUTTON, nil);
    };
    
    _popupController = [UIAlertController alertControllerWithTitle:_title
                                                              message:_message
                                                       preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:_okTitle style:UIAlertActionStyleDefault handler:iOKBlock];
    [_popupController addAction:okAction];
    
    // add this only if it exists
    if (_nokTitle != NULL) {
        UIAlertAction *nokAction = [UIAlertAction actionWithTitle:_nokTitle style:UIAlertActionStyleDefault handler:iNOKBlock];
        [_popupController addAction:nokAction];
    }
    
    if (_hasTextField) {
        __block UITextField *localTextField;
        __block id safeSelf = self;
        [_popupController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            localTextField = textField;
            localTextField.keyboardType = [safeSelf keyboardType];
        }];
    }
    
    [_popupController show];
}

/**
 * MARK: iOS 8.0-
 * Method that shows the current alert controller
 */
- (void) showWithAlertView {
    _popupAlertView = [[UIAlertView alloc] initWithTitle:_title
                                                    message:_message
                                                   delegate:self
                                          cancelButtonTitle:_nokTitle
                                          otherButtonTitles:_okTitle, nil];
    if (_hasTextField) {
        _popupAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    }
    [_popupAlertView show];
}

/**
 * MARK: iOS 8.0-
 * Method that gets called just before the alert view is shown
 *
 * @param alertView the current instance of the alert view
 */
- (void) willPresentAlertView:(UIAlertView*) alertView {
    if (_hasTextField) {
        UITextField *textField = [_popupAlertView textFieldAtIndex:0];
        textField.keyboardType = _keyboardType;
    }
}

/**
 * MARK: iOS 8.0-
 * Method that gets called when the alert view's buttons are clicked
 *
 * @param alertView     the current instance of the alert view
 * @param buttonIndex   the current button index
 */
- (void) alertView:(UIAlertView*) alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        if (_hasTextField) {
            UITextField *textField = [_popupAlertView textFieldAtIndex:0];
            NSString *text = [textField text];
            _handler(SA_OK_BUTTON, text);
        } else {
            _handler(SA_OK_BUTTON, nil);
        }
    }
    else if (buttonIndex == 0){
        _handler(SA_CANCEL_BUTTON, nil);
    }
}

@end
