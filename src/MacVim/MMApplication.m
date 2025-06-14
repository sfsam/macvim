/* vi:set ts=8 sts=4 sw=4 ft=objc:
 *
 * VIM - Vi IMproved		by Bram Moolenaar
 *				MacVim GUI port by Bjorn Winckler
 *
 * Do ":help uganda"  in Vim to read copying and usage conditions.
 * Do ":help credits" in Vim to see a list of people who contributed.
 * See README.txt for an overview of the Vim source code.
 */
/*
 * MMApplication
 *
 * Some default NSApplication key input behavior is overridden here.
 */

#import "MacVim.h"
#import "MMApplication.h"

@implementation MMApplication

- (void)sendEvent:(NSEvent *)event
{
    NSEventType type = [event type];
    NSUInteger flags = [event modifierFlags];

    // HACK! Intercept 'help' key presses and clear the 'help key flag', else
    // Cocoa turns the mouse cursor into a question mark and goes into 'context
    // help mode' (the keyDown: event itself never reaches the text view).  By
    // clearing the 'help key flag' this event will be treated like a normal
    // key event.
    if ((NSEventTypeKeyDown == type || NSEventTypeKeyUp == type) &&
            (flags & NSEventModifierFlagHelp)) {
        flags &= ~NSEventModifierFlagHelp;
        event = [NSEvent keyEventWithType:[event type]
                                 location:[event locationInWindow]
                            modifierFlags:flags
                                timestamp:[event timestamp]
                             windowNumber:[event windowNumber]
                                  context:nil // [event context] is always nil
                               characters:[event characters]
              charactersIgnoringModifiers:[event charactersIgnoringModifiers]
                                isARepeat:[event isARepeat]
                                  keyCode:[event keyCode]];
    }

    [super sendEvent:event];
}

- (void)orderFrontStandardAboutPanel:(id)sender
{
    NSString *macVimVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:
                               @"CFBundleVersion"];
    NSString *vimVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:
                            @"CFBundleShortVersionString"];

    BOOL isPrerelease = [macVimVersion rangeOfString:@"."].length > 0;
    NSString *prerelease = isPrerelease ? @"\npre-release" : @"";

    NSString *version = [NSString stringWithFormat: @"Version %@%@\n\nVim %@",
                         macVimVersion,
                         prerelease,
                         vimVersion];

    // Credits is simply a macvim.org link, monospaced, bold, centered...

    NSMutableParagraphStyle *creditsParaStyle = [NSMutableParagraphStyle new];
    [creditsParaStyle setAlignment: NSTextAlignmentCenter];

    NSDictionary *creditsAttrs = @{
        NSParagraphStyleAttributeName: creditsParaStyle,
        NSFontAttributeName: [NSFont fontWithName: @"Menlo-Bold" size: 12],
        NSLinkAttributeName: [NSURL URLWithString: @"https://macvim.org"]
    };

    NSMutableAttributedString *credits = [[NSMutableAttributedString alloc]
                                          initWithString: @"\nmacvim.org\n"
                                          attributes: creditsAttrs];

    [self orderFrontStandardAboutPanelWithOptions: @{
        @"Version": @"",
        @"ApplicationVersion": version,
        @"Credits": credits
    }];
}

@end
