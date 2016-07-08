//
//  SAPopup.m
//  Pods
//
//  Created by Gabriel Coman on 07/07/2016.
//
//

// header
#import "SAPopup.h"

// other imports
#import "SASystemVersion.h"
#import "SAExtensions.h"

// interface
@interface SAPopup ()
@property (nonatomic, strong) UIAlertController *kwsPopupController;
@property (nonatomic, strong) UIAlertView *kwsPopupAlertView;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *okTitle;
@property (nonatomic, strong) NSString *nokTitle;
@property (nonatomic, assign) BOOL hasTextField;
@property (nonatomic, assign) UIKeyboardType keyboardType;
@property (nonatomic, strong) okBlock okBlock;
@property (nonatomic, strong) nokBlock nokBlock;
@end

@implementation SAPopup

// MARK: Main class functions

- (void) showWithTitle:(NSString*)title
            andMessage:(NSString*)message
            andOKTitle:(NSString*)ok
           andNOKTitle:(NSString*)nok
          andTextField:(BOOL)hasTextField
       andKeyboardTyle:(UIKeyboardType)keyboardType
            andOKBlock:(okBlock)okBlock
           andNOKBlock:(nokBlock)nokBlock{
    
    _title = title;
    _message = message;
    _okTitle = ok;
    _nokTitle = nok;
    _hasTextField = hasTextField;
    _keyboardType = keyboardType;
    _okBlock = okBlock;
    _nokBlock = nokBlock;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [self showWithAlertController];
    } else {
        [self showWithAlertView];
    }
    
}

- (void) close {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [_kwsPopupController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [_kwsPopupAlertView dismissWithClickedButtonIndex:0 animated:YES];
    }
}

// MARK: iOS 8.0+

- (void) showWithAlertController {
    
    actionBlock iOKBlock = ^(UIAlertAction *action) {
        if (_hasTextField) {
            UITextField *textField = [[_kwsPopupController textFields] firstObject];
            NSString *text = [textField text];
            _okBlock(text);
        } else {
            _okBlock(nil);
        }
    };
    actionBlock iNOKBlock = ^(UIAlertAction *action) {
        _nokBlock();
    };
    
    _kwsPopupController = [UIAlertController alertControllerWithTitle:_title
                                                              message:_message
                                                       preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:_okTitle style:UIAlertActionStyleDefault handler:iOKBlock];
    UIAlertAction *nokAction = [UIAlertAction actionWithTitle:_nokTitle style:UIAlertActionStyleDefault handler:iNOKBlock];
    [_kwsPopupController addAction:okAction];
    [_kwsPopupController addAction:nokAction];
    
    if (_hasTextField) {
        __block UITextField *localTextField;
        [_kwsPopupController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            localTextField = textField;
            localTextField.keyboardType = _keyboardType;
        }];
    }
    
    [_kwsPopupController show];
}

// MARK: iOS 8.0-

- (void) showWithAlertView {
    _kwsPopupAlertView = [[UIAlertView alloc] initWithTitle:_title
                                                    message:_message
                                                   delegate:self
                                          cancelButtonTitle:_nokTitle
                                          otherButtonTitles:_okTitle, nil];
    if (_hasTextField) {
        _kwsPopupAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    }
    [_kwsPopupAlertView show];
}

- (void) willPresentAlertView:(UIAlertView *)alertView {
    if (_hasTextField) {
        UITextField *textField = [_kwsPopupAlertView textFieldAtIndex:0];
        textField.keyboardType = _keyboardType;
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        if (_hasTextField) {
            UITextField *textField = [_kwsPopupAlertView textFieldAtIndex:0];
            NSString *text = [textField text];
            _okBlock(text);
        } else {
            _okBlock(nil);
        }
    }
    else if (buttonIndex == 0){
        _nokBlock();
    }
}

@end