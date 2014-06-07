/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "NativeNav.h"
#import "AppDelegate.h"

#import <UIKit/UIKit.h>

@interface NativeNav ()

@end

@implementation NativeNav

//@dynamic appKey, appSecret;

- (id)settingForKey:(NSString*)key
{
    return [self.commandDelegate.settings objectForKey:[key lowercaseString]];
}

- (void)pluginInitialize
{
    // SETTINGS ////////////////////////
/*
    NSString* setting = nil;

    setting = @"DropboxAppKey";
    if ([self settingForKey:setting]) {
        self.appKey = [self settingForKey:setting];
    }

    setting = @"DropboxAppSecret";
    if ([self settingForKey:setting]) {
        self.appSecret = [self settingForKey:setting];
    }
*/
    //////////////////////////

    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    __weak NativeNav* weakSelf = self;
    
    [nc addObserverForName:UIKeyboardWillShowNotification
                                                object:nil
                                                 queue:[NSOperationQueue mainQueue]
                                            usingBlock:^(NSNotification* notification) {
                                                    [weakSelf performSelector:@selector(formAccessoryBarKeyboardWillShow:) withObject:notification afterDelay:0];
                                 
                                            }];


    
    

}


// //////////////////////////////////////////////////

- (void)dealloc
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    
    [nc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

// //////////////////////////////////////////////////

#pragma Plugin interface

NSString* actionSheetRoute;
NSArray* actionSheetItems;

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex < [actionSheetItems count]) {
        [self.commandDelegate evalJs:[NSString stringWithFormat:@"NativeNav.handleAction(\"%@\", \"%@\");", actionSheetRoute, actionSheetItems[buttonIndex][@"action"]]];
    }
}

- (void) showPopupMenu:(CDVInvokedUrlCommand*)command
{
    actionSheetRoute = [command.arguments objectAtIndex:0];
    long x = [(NSNumber*)[command.arguments objectAtIndex:1] integerValue];
    long y = [(NSNumber*)[command.arguments objectAtIndex:2] integerValue];
    long w = [(NSNumber*)[command.arguments objectAtIndex:3] integerValue];
    long h = [(NSNumber*)[command.arguments objectAtIndex:4] integerValue];
    actionSheetItems = [command.arguments objectAtIndex:5];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    for (int i = 0; i < actionSheetItems.count; i++) {
        [actionSheet addButtonWithTitle:[actionSheetItems[i] objectForKey:@"title"]];
    }
    
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = [actionSheetItems count];
    
    [actionSheet showFromRect:CGRectMake(x, y, w, h) inView:[self webView] animated:NO];
     
}


NSString* navbarRoute;
UINavigationBar *navBar;
UINavigationItem *currentNavigationItem;
NSArray* navbarLeftButtons;
NSArray* navbarRightButtons;
NSString* navbarTitleChanged;
NSString* navbarTitle;

- (void) clickedLeftNavbarButton:(UIBarButtonItem*)button
{
    if (button.tag < [navbarLeftButtons count]) {
        NSDictionary* bdef = navbarLeftButtons[button.tag];
        if (bdef[@"action"]) {
            NSString* escapedAction = [[bdef[@"action"]
                    stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"]
                    stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];

            NSString* script =[NSString stringWithFormat:@"NativeNav.handleAction(\"%@\", \"%@\");", navbarRoute, escapedAction];
            NSLog(script);
        [self.commandDelegate evalJs:script];
            NSLog(@"Clicked navbar button");
        }
        else if (bdef[@"items"]) {
            NSLog(@"Clicked navbar menu");
        }
    }
}


- (void) clickedRightNavbarButton:(UIBarButtonItem*)button
{
    
    if (button.tag < [navbarRightButtons count]) {
        NSDictionary* bdef = navbarRightButtons[button.tag];
        if (bdef[@"action"]) {
            NSString* escapedAction = [[bdef[@"action"]
                    stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"]
                    stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];

            NSString* script =[NSString stringWithFormat:@"NativeNav.handleAction(\"%@\", \"%@\");", navbarRoute, escapedAction];
            NSLog(script);
        [self.commandDelegate evalJs:script];
            NSLog(@"Clicked navbar button");
        }
        else if (bdef[@"items"]) {
            NSLog(@"Clicked navbar menu");
            
            actionSheetRoute = navbarRoute;
            actionSheetItems = bdef[@"items"];
            
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:nil
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:nil];
            
            for (int i = 0; i < actionSheetItems.count; i++) {
                [actionSheet addButtonWithTitle:[actionSheetItems[i] objectForKey:@"title"]];
            }
/*
            [actionSheet addButtonWithTitle:@"Cancel"];
            actionSheet.cancelButtonIndex = [actionSheetItems count];
  */
            [actionSheet showFromBarButtonItem:button animated:YES];
        }
    }
    
}

- (void) navbarTitleEdited:(UITextView*)textbox
{

    navbarTitle = [textbox text];

    NSString* escapedTitle = [[[textbox text]
                                stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\\\\\"]
                               stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\\\\\""];
    
    NSString* script =[NSString stringWithFormat:@"NativeNav.handleAction(\"%@\", \"%@(\\\"%@\\\")\");", navbarRoute, navbarTitleChanged,  escapedTitle];
    NSLog(script);
    [self.commandDelegate evalJs:script];

    
    NSLog(@"Title edited");
}

- (void) showNavbar:(CDVInvokedUrlCommand*)command
{
// todo: put this somewhere better

    
    NSString* newNavbarRoute =[command.arguments objectAtIndex:0];
  
    bool active = [(NSNumber*)[command.arguments objectAtIndex:1] boolValue];
    navbarLeftButtons = (NSArray*)[command.arguments objectAtIndex:2];
    NSString* title = [command.arguments objectAtIndex:3];
    navbarRightButtons = (NSArray*)[command.arguments objectAtIndex:4];
    navbarTitleChanged = [command.arguments objectAtIndex:5];
    
    
    
    if ([navbarLeftButtons isEqual:[NSNull null]]) navbarLeftButtons = nil;
    if ([navbarRightButtons isEqual:[NSNull null]]) navbarRightButtons = nil;
    if ([title isEqual:[NSNull null]]) title = nil;
    if ([newNavbarRoute isEqual:[NSNull null]]) newNavbarRoute = nil;
    if ([navbarTitleChanged isEqual:[NSNull null]]) navbarTitleChanged = nil;
    
    if (active) {
        UIEdgeInsets insets = self.webView.scrollView.contentInset;
        [self.webView.scrollView setContentInset:UIEdgeInsetsMake(80, insets.left, insets.bottom, insets.right)];
    }
    
    /*
    long y = [(NSNumber*)[command.arguments objectAtIndex:2] integerValue];
    long w = [(NSNumber*)[command.arguments objectAtIndex:3] integerValue];
    long h = [(NSNumber*)[command.arguments objectAtIndex:4] integerValue];
    actionSheetItems = [command.arguments objectAtIndex:5];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    for (int i = 0; i < actionSheetItems.count; i++) {
        [actionSheet addButtonWithTitle:[actionSheetItems[i] objectForKey:@"title"]];
    }
    
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = [actionSheetItems count];
    
    [actionSheet showFromRect:CGRectMake(x, y, w, h) inView:[self webView] animated:NO];
   */
    if (!navBar) {
    navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.viewController.view.bounds.size.width, 64.0)];
       navBar.autoresizingMask = (UIViewAutoresizingFlexibleWidth);

        // navBar.tintColor=[UIColor blueColor];
        [navBar setTranslucent:YES];
        [self.viewController.view addSubview:navBar];

    }
    if (!currentNavigationItem || !navbarRoute || ![navbarRoute isEqualToString:newNavbarRoute]) {
        currentNavigationItem = [[UINavigationItem alloc] initWithTitle:@"This is a long TITLE"];
        navbarRoute = newNavbarRoute;
        [navBar setItems:@[currentNavigationItem] animated:NO];
    }
    
    NSMutableArray* buttons = [NSMutableArray array];
    if (navbarLeftButtons) {
    for (int i = 0; i < navbarLeftButtons.count; i++) {
        NSDictionary*  bdef = navbarLeftButtons[i];
        NSString* buttonTitle = bdef[@"title"];
        UIBarButtonItem *button;
        if ([buttonTitle isEqualToString:@"Add"]) {
            button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(clickedLeftNavbarButton:)];

        } else {
        button = [[UIBarButtonItem alloc] initWithTitle:buttonTitle style:UIBarButtonItemStylePlain target:self action:@selector(clickedLeftNavbarButton:)];
        }
        button.tag = i;
        [buttons addObject: button];
//        [actionSheet addButtonWithTitle:[actionSheetItems[i] objectForKey:@"title"]];
    }
    }
    [currentNavigationItem setLeftBarButtonItems:buttons];

    
    buttons = [NSMutableArray array];
    if (navbarRightButtons) {
        for (int i = 0; i < navbarRightButtons.count; i++) {
            NSDictionary*  bdef = navbarRightButtons[i];
            NSString* buttonTitle = bdef[@"title"];
            UIBarButtonItem *button;
            if ([buttonTitle isEqualToString:@"Add"]) {
                button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(clickedRightNavbarButton:)];
                
            } else if ([buttonTitle isEqualToString:@"Edit"]) {
                button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(clickedRightNavbarButton:)];
                
            } else {
                button = [[UIBarButtonItem alloc] initWithTitle:buttonTitle style:UIBarButtonItemStylePlain target:self action:@selector(clickedRightNavbarButton:)];
            }
            button.tag = i;
            [buttons addObject: button];
            //        [actionSheet addButtonWithTitle:[actionSheetItems[i] objectForKey:@"title"]];
        }
    }
    [currentNavigationItem setRightBarButtonItems:buttons];

    
    
    /*
     NSDictionary *titleAttributesDictionary =  [NSDictionary dictionaryWithObjectsAndKeys:
     [UIColor blackColor],
     UITextAttributeTextColor,
     [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0],
     UITextAttributeTextShadowColor,
     [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
     UITextAttributeTextShadowOffset,
     [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0],
     UITextAttributeFont,
     nil];
       navBar.titleTextAttributes = titleAttributesDictionary;
     */
    if (title != nil) {
    currentNavigationItem.title = title;// = [[UINavigationItem alloc] initWithTitle:title];
//    navBar.items = @[titleItem];
    }

    
    if (navbarTitleChanged && title && ![title isEqualToString:navbarTitle] ) {
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 200, 22)];
        textField.text =title;
        textField.font = [UIFont boldSystemFontOfSize:19];
        textField.textColor = [UIColor blackColor];
        textField.textAlignment = NSTextAlignmentCenter;
        currentNavigationItem.titleView = textField;
        [textField addTarget:self
                      action:@selector(navbarTitleEdited:)
            forControlEvents:UIControlEventEditingChanged];
    }
    
    navbarTitle = title;
    
    
}



UIToolbar* inputAccessoryView;
NSMutableDictionary* namedKbButtons;
NSMutableArray* kbButtons;
NSMutableArray* kbButtonDefinitions;
UIBarButtonItem* flexspace;

- (void)formAccessoryBarKeyboardWillShow:(NSNotification*)notif
{
    if (!inputAccessoryView) return;
    
    NSArray* windows = [[UIApplication sharedApplication] windows];
    
    for (UIWindow* window in windows) {
        for (UIView* view in window.subviews) {
            if ([[view description] hasPrefix:@"<UIPeripheralHostView"]) {
                for (UIView* peripheralView in view.subviews) {
                    

                    // replaces the accessory bar
                    if ([[peripheralView description] hasPrefix:@"<UIWebFormAccessory"]) {
                        
                        [view addSubview:inputAccessoryView];
//                        [inputAccessoryView setUserInteractionEnabled:NO];
                        inputAccessoryView.frame = peripheralView.frame;
                        inputAccessoryView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
                        /*
                        [inputAccessoryView setTranslatesAutoresizingMaskIntoConstraints:NO];

                        
                        [view addConstraint:
                         [NSLayoutConstraint constraintWithItem:inputAccessoryView
                                                      attribute:NSLayoutAttributeWidth
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:view
                                                      attribute:NSLayoutAttributeWidth
                                                     multiplier:1
                                                       constant:0]];
                        [view addConstraint:
                         [NSLayoutConstraint constraintWithItem:inputAccessoryView
                                                      attribute:NSLayoutAttributeCenterX
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:view
                                                      attribute:NSLayoutAttributeCenterX
                                                     multiplier:1
                                                       constant:0]];

                        */
                        // remove the form accessory bar
                        [peripheralView removeFromSuperview];

                    }
                    // hides the thin grey line used to adorn the bar (iOS 6)
                    if ([[peripheralView description] hasPrefix:@"<UIImageView"]) {
                        [[peripheralView layer] setOpacity:0.0];
                    }
                }
            }
        }
    }
}

- (void) reportKeyboardAccessoryClick:(UIBarButtonItem *) sender {
    int i = [kbButtons indexOfObject:sender];
    NSLog(@"rkac %i", i);
    NSDictionary *d = kbButtonDefinitions[i];
    NSLog(@"rkac %@", d[@"value"]);
    NSString* value =d[@"value"];
    if ([value isEqualToString:@"done"]) {
        [self.webView endEditing:YES];
    }
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"NativeNav.handleKeyboardAcessoryClick(\"%@\")", value ]];

    
}

- (void) addKbButton:(NSDictionary *) d {
    UIBarButtonItem* button;
    NSString* name =d[@"name"];
    if (namedKbButtons[name]) {
        button =namedKbButtons[name];
    }
    else {
        if ([name isEqualToString:@"add"]) {
            button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(reportKeyboardAccessoryClick:)];
        }
        else if ([name isEqualToString:@"done"]) {
            button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(reportKeyboardAccessoryClick:)];
        }
        else {
            button = [[UIBarButtonItem alloc] initWithTitle:d[@"title"] style:UIBarButtonItemStylePlain target:self action:@selector(reportKeyboardAccessoryClick:)];
        }
        namedKbButtons[name] = button;
    }
    
    [kbButtons addObject:button];
    [kbButtonDefinitions addObject:d];

}



- (void) setKeyboardAccessoryButtonState:(CDVInvokedUrlCommand *)command {
    NSDictionary* buttonStates = [command.arguments objectAtIndex:0];
    NSLog(@"Setting kb accessory button state");
    
    if (!namedKbButtons) return;
    
    for (NSString* buttonName in buttonStates) {
        NSDictionary* sd = buttonStates[buttonName];
        UIBarButtonItem * button = namedKbButtons[buttonName];
        if (!button) continue;
        id oActivated = [sd objectForKey:@"active"];
        if (oActivated) {
            BOOL isActivated = [oActivated boolValue];
            if (isActivated) {
                [button setTintColor:[UIColor redColor]];
            } else {
                [button setTintColor:[UIColor blueColor]];
            }
        }
    }
    
}

- (void) setKeyboardAccessory:(CDVInvokedUrlCommand *)command {
    NSDictionary* options = [command.arguments objectAtIndex:0];
    NSLog(@"Setting kb accessory");
    
    if (!namedKbButtons) namedKbButtons = [NSMutableDictionary dictionary];
    
    if (!inputAccessoryView) {
        inputAccessoryView = [[UIToolbar alloc] init];
    }
    
//    CGRect accessFrame = CGRectMake(0.0, 0.0, 768.0, 77.0);
    
//    inputAccessoryView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.5];
//    inputAccessoryView.backgroundColor = [UIColor blueColor];
    

//    [compButton setTintColor:[UIColor redColor]];
    
    if (!kbButtons) {
        kbButtons = [NSMutableArray array];
    }
    if (!kbButtonDefinitions) {
        kbButtonDefinitions = [NSMutableArray array];
    }
    if (!flexspace) {
        flexspace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    }
    
    [kbButtonDefinitions removeAllObjects];
    [kbButtons removeAllObjects];
    
    for (NSDictionary* d  in options[@"leftButtons"]) {
        [self addKbButton:d];
    }
    
    [kbButtons addObject:flexspace];
    [kbButtonDefinitions addObject:@""];

    for (NSDictionary* d  in options[@"middleButtons"]) {
        [self addKbButton:d];
    }
    
    [kbButtons addObject:flexspace];
    [kbButtonDefinitions addObject:@""];

    for (NSDictionary* d  in options[@"rightButtons"]) {
        [self addKbButton:d];
    }
    

    
    [inputAccessoryView setItems:kbButtons animated:YES];
    
    /*
    UIButton *compButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    compButton.frame = CGRectMake(400, 0.0, 158.0, 37.0);
    [compButton setTitle: @"Button 3" forState:UIControlStateNormal];
    [compButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [compButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    compButton.tag=42;
    [compButton addTarget:self action:@selector(reportKeyboardAccessoryClick:)
         forControlEvents:UIControlEventTouchUpInside];
    [inputAccessoryView addSubview:compButton];
    */
    /*
    [inputAccessoryView constraintWithItem:label
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:tab
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1.0
                                  constant:0]
    */

    

//    self.webView.inputAccessoryView = inputAccessoryView;
    
    

    

}

/* Transitions */


UIImageView* imageView1;
UIImageView* imageView2;
UIView* modalOverlay;


- (void)handleModalOverlayTap:(UIView*)sender
{
        [self.commandDelegate evalJs:[NSString stringWithFormat:@"NativeNav.closeModal();"]];
}

- (void) startNativeTransition:(CDVInvokedUrlCommand*)command
{
    // todo: put this somewhere better
    self.webView.backgroundColor = [UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1]; /*#efeff4*/

    UIView* container = self.webView.superview;
    
    NSString* transitionType =[command.arguments objectAtIndex:0];
    NSDictionary* ord =[command.arguments objectAtIndex:1];
    CGRect originRect;
    BOOL hasOrigin = NO;
    
    if (![ord isEqual:[NSNull null]]) {
        originRect = CGRectMake([(NSNumber*)ord[@"left"] floatValue], [(NSNumber*)ord[@"top"] floatValue], [(NSNumber*)ord[@"width"] floatValue], [(NSNumber*)ord[@"height"] floatValue]);
        hasOrigin = YES;
    }
    
    
    
    UIView* capturedView;
    
    
    
    if ([transitionType isEqualToString:@"popup"]) {
        capturedView =self.webView.superview;
    }
    else {
        capturedView = self.webView;
    }
    
    
    UIGraphicsBeginImageContextWithOptions(capturedView.bounds.size, YES, 0.0f);
    [capturedView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (!imageView1) {
        imageView1 = [[UIImageView alloc] initWithFrame:self.webView.frame];
        imageView1.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        
        [container addSubview:imageView1];
        imageView1.alpha = 0.0f;
    }
    if (!imageView2) {
        imageView2 = [[UIImageView alloc] initWithFrame:self.webView.frame];
        imageView2.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [container addSubview:imageView2];
        imageView2.alpha = 0.0f;
    }

    if (!modalOverlay) {
        modalOverlay = [[UIView alloc] initWithFrame:self.webView.frame];
        modalOverlay.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [container addSubview:modalOverlay];
        modalOverlay.backgroundColor = [UIColor blackColor];
        modalOverlay.alpha = 0.0f;
        
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleModalOverlayTap:)];
        [modalOverlay addGestureRecognizer:singleFingerTap];

    }

    
    if ([transitionType isEqualToString:@"popup"]) {
        
        // popup
        // image 1 replaces web view
        // modal overlay added in front of image view
        // webview resized to popup and animated into place
        
        
        CGRect targetRect;
           if(CDV_IsIPad()) {
               targetRect = CGRectMake(self.webView.superview.bounds.size.width/2-300,self.webView.superview.bounds.size.height/2-300,600.0f,600.0f);
           }
           else {
               targetRect = self.webView.bounds;
           }
        
        if (!hasOrigin) {
            originRect = CGRectMake(targetRect.origin.x, self.webView.superview.bounds.size.height, targetRect.size.width, targetRect.size.height);
        }
        



        CATransform3D transform = CATransform3DIdentity;
//     transform.m34 = 1.0 / -5000;


        transform = CATransform3DTranslate(transform, (originRect.origin.x+originRect.size.width/2)-(targetRect.origin.x+targetRect.size.width/2), (originRect.origin.y+originRect.size.height/2)-(targetRect.origin.y+targetRect.size.height/2), 0);
        
        transform = CATransform3DScale(transform, originRect.size.width/targetRect.size.width, originRect.size.height/targetRect.size.height, 1);
        
        
        if (hasOrigin) {
            //      transform = CATransform3DRotate(transform, 180.0f * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);

        }
        

        
        
//        self.webView.superview.backgroundColor = [UIColor blackColor]; /*#efefef*/
        
        [imageView1 setFrame:self.webView.bounds];
        [imageView1 setImage: viewImage];

        imageView1.alpha = 1.0f;
        [container bringSubviewToFront:imageView1];

        modalOverlay.alpha = 0.0f;
        modalOverlay.backgroundColor = [UIColor blackColor];
        [container bringSubviewToFront:modalOverlay];
        
        self.webView.alpha = 1.0f;
        [container bringSubviewToFront:self.webView];

        
//        if (navBar) {
//            navBar.alpha = 0.0f;
//        }

        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:transitionType] callbackId:command.callbackId];
        
        if(CDV_IsIPad()) {
        self.webView.frame = targetRect;
        }
        
        
        
        //self.webView.transform = atrans;
        CALayer *layer = self.webView.layer;
    //    layer.doubleSided = NO;
        layer.transform = transform;

        self.webView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
        
        self.webView.alpha = 0.0f;

        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3f];
        self.webView.alpha = 1.0f;
        imageView1.alpha = 1.0f;

        modalOverlay.alpha = 0.5f;

        
     //   self.webView.transform =  CGAffineTransformMakeTranslation(0.0f, 0.0f);
        layer.transform = CATransform3DIdentity;
        
        [UIView commitAnimations];

    }
    else if ([transitionType isEqualToString:@"closepopup"]) {

        // close popup
        // image 2 replaces popup webview
        // image 1 is background as set by popup opening
        // webview resized to full frame
        // image 2 animated with close transform
        // image 1 fades out.
        
        CGRect targetRect;
        targetRect = self.webView.frame;
        
        if (!hasOrigin) {
            originRect = CGRectMake(targetRect.origin.x, self.webView.superview.bounds.size.height, targetRect.size.width, targetRect.size.height);
        }
     
        
        CATransform3D transform = CATransform3DIdentity;

        transform = CATransform3DTranslate(transform, (originRect.origin.x+originRect.size.width/2)-(targetRect.origin.x+targetRect.size.width/2), (originRect.origin.y+originRect.size.height/2)-(targetRect.origin.y+targetRect.size.height/2), 0);
        
        transform = CATransform3DScale(transform, originRect.size.width/targetRect.size.width, originRect.size.height/targetRect.size.height, 1);
        
        
        if (hasOrigin) {
            
            
        }
        
        imageView2.alpha = 1.0f;
        CALayer *layer = imageView2.layer;
        layer.transform = CATransform3DIdentity;
        
        
        [imageView2 setFrame:self.webView.frame];
        [imageView2 setImage: viewImage];


        imageView2.alpha = 1.0f;
        //    layer.doubleSided = NO;

        [self.webView.superview bringSubviewToFront:imageView2];
        self.webView.alpha = 1.0f;
        [self.webView.superview sendSubviewToBack:self.webView];
        self.webView.frame = self.webView.superview.bounds;
        layer.transform = CATransform3DIdentity;
        
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:transitionType] callbackId:command.callbackId];
        
        self.webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3f];
        
        
        layer.transform = transform;

        
        if (navBar) {
            navBar.alpha = 1.0f;
        }

        
        imageView2.alpha = 0.0f;
        imageView1.alpha = 0.0f;
        modalOverlay.alpha = 0.0f;
        
        
        
        [UIView commitAnimations];
    }
    else if ([transitionType isEqualToString:@"crossfade"]) {
        
        [imageView1 setFrame:self.webView.frame];
        [imageView1 setImage: viewImage];
        
        imageView1.alpha = 1.0f;
        self.webView.alpha = 0.0f;
        [self.webView.superview sendSubviewToBack:imageView1];
        
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:transitionType] callbackId:command.callbackId];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.4f];
        self.webView.alpha = 1.0f;
        imageView1.alpha = 1.0f;
        [UIView commitAnimations];
        
    }
    else {
        // invalid transition - don't do anything
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:transitionType] callbackId:command.callbackId];

    }

    

}


@end
