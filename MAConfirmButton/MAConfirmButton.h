//
//  MAConfirmButton.h
//
//  Created by Mike on 11-03-28.
//  Copyright 2011 Mike Ahmarani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class MAConfirmButtonOverlay;

typedef enum {
  MAConfirmButtonToggleAnimationLeft = 0,
  MAConfirmButtonToggleAnimationRight = 1,
  MAConfirmButtonToggleAnimationCenter = 2

} MAConfirmButtonToggleAnimation;

@interface MAConfirmButton : UIButton

@property (nonatomic, assign) MAConfirmButtonToggleAnimation toggleAnimation;

//+ (MAConfirmButton *) selectedButtonWithTitle:(NSString *)buttonText;
+ (id)buttonWithTitle:(NSString *)titleString confirm:(NSString *)confirmString;
+ (id)buttonWithDisabledTitle:(NSString *)disabledString;

- (id) initWithTitle:(NSString *)titleString confirm:(NSString *)confirmString;
- (id) initWithDisabledTitle:(NSString *)disabledString;

- (void) disableWithTitle:(NSString *)disabledString;
- (void) setAnchor:(CGPoint)anchor;
- (void) setTintColor:(UIColor *)color;

- (void) setSelected:(BOOL)selected;
- (void) setSelected:(BOOL)selected withTitle:(NSString *)title;

- (void) resetWithTitle:(NSString *)title;

@end
