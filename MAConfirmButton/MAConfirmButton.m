//
//  MAConfirmButton.m
//
//  Created by Mike on 11-03-28.
//  Copyright 2011 Mike Ahmarani. All rights reserved.
//

#import "MAConfirmButton.h"
#import "UIColor-Expanded.h"

#define kHeight 26.0
#define kPadding 20.0
#define kFontSize 14.0

@interface MAConfirmButton ()
{
	BOOL _selected;
	BOOL _confirmed;
	CALayer *_colorLayer;
	CALayer *_darkenLayer;
	UIButton *_cancelOverlay;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *confirm;
@property (nonatomic, copy) NSString *disabled;
@property (nonatomic, retain) UIColor *tint;

@end

@implementation MAConfirmButton

//+ (MAConfirmButton *) selectedButtonWithTitle:(NSString *)buttonText;
//{
//    MAConfirmButton *button = [[super alloc] initWithTitle:buttonText confirm:buttonText];
//    [button setSelected:YES];
//    return button;
//}

+ (MAConfirmButton *)buttonWithTitle:(NSString *)titleString confirm:(NSString *)confirmString
{
    MAConfirmButton *button = [[super alloc] initWithTitle:titleString confirm:confirmString];
    return button;
}

+ (MAConfirmButton *)buttonWithDisabledTitle:(NSString *)disabledString
{
    MAConfirmButton *button = [[super alloc] initWithDisabledTitle:disabledString];
    return button;
}

- (id)initWithDisabledTitle:(NSString *)disabledString
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        self.disabled = disabledString;

        self.toggleAnimation = MAConfirmButtonToggleAnimationLeft;

        self.layer.needsDisplayOnBoundsChange = YES;

        CGSize size = [self.disabled sizeWithFont:[UIFont boldSystemFontOfSize:kFontSize]];
        CGRect r = self.frame;
        r.size.height = kHeight;
        r.size.width = size.width + kPadding;
        self.frame = r;

        [self setTitle:self.disabled forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateNormal];
        [self setTitleShadowColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];		

        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.shadowOffset = CGSizeMake(0, 1);
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:kFontSize];
        self.tint = [UIColor colorWithWhite:0.85 alpha:1];	

        [self setupLayers];
    }	
    return self;	
}

- (id)initWithTitle:(NSString *)titleString confirm:(NSString *)confirmString
{
    self = [super initWithFrame:CGRectZero];
    if(self)
    {
        self.title = titleString;
        self.confirm = confirmString;

        self.toggleAnimation = MAConfirmButtonToggleAnimationLeft;

        self.layer.needsDisplayOnBoundsChange = YES;

        CGSize size = [self.title sizeWithFont:[UIFont boldSystemFontOfSize:kFontSize]];
        CGRect r = self.frame;
        r.size.height = kHeight;
        r.size.width = size.width+kPadding;
        self.frame = r;

        [self setTitle:self.title forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];		
        [self setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.5] forState:UIControlStateNormal];

        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.shadowOffset = CGSizeMake(0, -1);
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:kFontSize];
        self.tint = [UIColor colorWithRed:0.220 green:0.357 blue:0.608 alpha:1];

        [self setupLayers];
    }	
    return self;
}

- (void)toggle
{
    if (self.userInteractionEnabled)
    {
        self.userInteractionEnabled = NO;
        self.titleLabel.alpha = 0;

        CGSize size;

        if(self.disabled)
        {
            [self setTitle:self.disabled forState:UIControlStateNormal];
            [self setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateNormal];
            [self setTitleShadowColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
            self.titleLabel.shadowOffset = CGSizeMake(0, 1);
            size = [self.disabled sizeWithFont:[UIFont boldSystemFontOfSize:kFontSize]];
        }
        else if(_selected)
        {
            [self setTitle:self.confirm forState:UIControlStateNormal];
            size = [self.confirm sizeWithFont:[UIFont boldSystemFontOfSize:kFontSize]];
        }
        else
        {
            [self setTitle:self.title forState:UIControlStateNormal];
            size = [self.title sizeWithFont:[UIFont boldSystemFontOfSize:kFontSize]];
        }

        size.width += kPadding;
        float offset = size.width - self.frame.size.width;

        [CATransaction begin];
        [CATransaction setAnimationDuration:0.25];
        [CATransaction setCompletionBlock:^{
            //Readjust button frame for new touch area, move layers back now that animation is done

            CGRect frameRect = self.frame;
            switch(self.toggleAnimation){
                case MAConfirmButtonToggleAnimationLeft:
                    frameRect.origin.x = frameRect.origin.x - offset;
                    break;
                case MAConfirmButtonToggleAnimationRight:
                    break;
                case MAConfirmButtonToggleAnimationCenter:
                    frameRect.origin.x = frameRect.origin.x - offset/2.0;
                    break;
                default:
                    break;
            }
            frameRect.size.width = frameRect.size.width + offset;
            self.frame = frameRect;

            [CATransaction setDisableActions:YES];
            [CATransaction setCompletionBlock:^{
                self.userInteractionEnabled = YES;
            }];
            
            for(CALayer *layer in self.layer.sublayers)
            {
                CGRect rect = layer.frame;
                switch(self.toggleAnimation){
                    case MAConfirmButtonToggleAnimationLeft:
                        rect.origin.x = rect.origin.x+offset;
                        break;
                    case MAConfirmButtonToggleAnimationRight:
                        break;
                    case MAConfirmButtonToggleAnimationCenter:
                        rect.origin.x = rect.origin.x+offset/2.0;
                        break;
                    default:
                        break;
                }

                layer.frame = rect;
            }
            [CATransaction commit];

            self.titleLabel.alpha = 1;
            [self setNeedsLayout];
        }];

        UIColor *greenColor = [UIColor colorWithRed:0.439 green:0.741 blue:0.314 alpha:1.];

        //Animate color change
        CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
        colorAnimation.removedOnCompletion = NO;
        colorAnimation.fillMode = kCAFillModeForwards;

        if(self.disabled)
        {
            colorAnimation.fromValue = (id)greenColor.CGColor;
            colorAnimation.toValue = (id)[UIColor colorWithWhite:0.85 alpha:1].CGColor;
        }
        else
        {
            colorAnimation.fromValue = _selected ? (id)self.tint.CGColor : (id)greenColor.CGColor;
            colorAnimation.toValue = _selected ? (id)greenColor.CGColor : (id)self.tint.CGColor;
        }

        [_colorLayer addAnimation:colorAnimation forKey:@"colorAnimation"];

        //Animate layer scaling
        for(CALayer *layer in self.layer.sublayers)
        {
            CGRect rect = layer.frame;

            switch(self.toggleAnimation){
                case MAConfirmButtonToggleAnimationLeft:
                    rect.origin.x = rect.origin.x-offset;
                    break;
                case MAConfirmButtonToggleAnimationCenter:
                    rect.origin.x = rect.origin.x-offset/2.0;
                    break;
                case MAConfirmButtonToggleAnimationRight:
                default:
                    break;
            }
            rect.size.width = rect.size.width+offset;
            layer.frame = rect;
        }

        [CATransaction commit];
        [self setNeedsDisplay];
    }
}

- (void)setupLayers
{  
    CAGradientLayer *bevelLayer = [CAGradientLayer layer];
    bevelLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));		
    bevelLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0 alpha:0.5].CGColor, [UIColor whiteColor].CGColor, nil];
    bevelLayer.cornerRadius = 4.0;
    bevelLayer.needsDisplayOnBoundsChange = YES;

    _colorLayer = [CALayer layer];
    _colorLayer.frame = CGRectMake(0, 1, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-2);		
    _colorLayer.borderColor = [UIColor colorWithWhite:0 alpha:0.1].CGColor;
    _colorLayer.backgroundColor = self.tint.CGColor;
    _colorLayer.borderWidth = 1.0;	
    _colorLayer.cornerRadius = 4.0;
    _colorLayer.needsDisplayOnBoundsChange = YES;		

    CAGradientLayer *colorGradient = [CAGradientLayer layer];
    colorGradient.frame = CGRectMake(0, 1, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-2);		
    colorGradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:1 alpha:0.1].CGColor, [UIColor colorWithWhite:0.2 alpha:0.1].CGColor , nil];		
    colorGradient.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0], nil];		
    colorGradient.cornerRadius = 4.0;
    colorGradient.needsDisplayOnBoundsChange = YES;	

    [self.layer addSublayer:bevelLayer];
    [self.layer addSublayer:_colorLayer];
    [self.layer addSublayer:colorGradient];
    [self bringSubviewToFront:self.titleLabel];
}

- (void)setSelected:(BOOL)s;
{
    _selected = s;
    [self toggle];
}

- (void) setSelected:(BOOL)selected withTitle:(NSString *)title;
{
    self.confirm = title;
    [self setSelected:selected];
}

- (void)disableWithTitle:(NSString *)disabledString;
{
    self.disabled = disabledString;
    [self toggle];	
}

- (void)setAnchor:(CGPoint)anchor;
{
    //Top-right point of the view (MUST BE SET LAST)
    CGRect rect = self.frame;
    rect.origin = CGPointMake(anchor.x - rect.size.width, anchor.y);
    self.frame = rect;
}

- (void)setTintColor:(UIColor *)color;
{
    self.tint = [UIColor colorWithHue:color.hue saturation:color.saturation+0.15 brightness:color.brightness alpha:1];
    _colorLayer.backgroundColor = self.tint.CGColor;
    [self setNeedsDisplay];
}

- (void)darken;
{
    _darkenLayer = [CALayer layer];
    _darkenLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    _darkenLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2].CGColor;
    _darkenLayer.cornerRadius = 4.0;
    _darkenLayer.needsDisplayOnBoundsChange = YES;
    [self.layer addSublayer:_darkenLayer];
}

- (void)lighten;
{
    if(_darkenLayer)
    {
        [_darkenLayer removeFromSuperlayer];
        _darkenLayer = nil;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
    if(!self.disabled && !_confirmed && self.userInteractionEnabled)
    {
        [self darken];
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{  
    if(!self.disabled && !_confirmed && self.userInteractionEnabled)
    {
        if(!CGRectContainsPoint(self.frame, [[touches anyObject] locationInView:self.superview]))
        { //TouchUpOutside (Cancelled Touch)
            [self lighten];
            [super touchesCancelled:touches withEvent:event];
        }
        else if(_selected)
        {
            [self lighten];
            _confirmed = YES;
            [_cancelOverlay removeFromSuperview];
            _cancelOverlay = nil;
            [super touchesEnded:touches withEvent:event];
        }
        else
        {
            [self lighten];
            self.selected = YES;
            if(!_cancelOverlay)
            {
                _cancelOverlay = [UIButton buttonWithType:UIButtonTypeCustom];
                [_cancelOverlay setFrame:CGRectMake(0, 0, 1024, 1024)];
                [_cancelOverlay addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchDown];
                [self.superview addSubview:_cancelOverlay];                
            }
            [self.superview bringSubviewToFront:self];
        }
    }
    
}

- (void)cancel;
{
    if(_cancelOverlay && self.userInteractionEnabled)
    {
        [_cancelOverlay removeFromSuperview];
        _cancelOverlay = nil;	
    }	
    self.selected = NO;
}


@end
