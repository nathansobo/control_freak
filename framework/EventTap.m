//
//  EventTap.m
//  ControlFreak
//
//  Created by Nathan Sobo on 9/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EventTap.h"
#import "Event.h"
#import <MacRuby/MacRuby.h>

@interface NSObject (RubyMethods)
-(Event*)onEvent:(Event*)event;
@end

@implementation EventTap
-(id)init {
	[super init];
	CFMachPortRef tap = CGEventTapCreate(kCGHIDEventTap,
										 kCGHeadInsertEventTap,
										 kCGEventTapOptionDefault,
										 CGEventMaskBit(kCGEventKeyDown) | CGEventMaskBit(kCGEventKeyUp) | CGEventMaskBit(kCGEventFlagsChanged),
										 &eventCallback,
										 self);
	CFRunLoopSourceRef tapSource = CFMachPortCreateRunLoopSource(NULL, tap, 0);
	CFRunLoopAddSource((CFRunLoopRef) [[NSRunLoop currentRunLoop] getCFRunLoop], tapSource, kCFRunLoopCommonModes);
	
	return self;
}

-(Event*)handleEvent:(Event*)event {
	// to be overridden by ruby code
	return event;
}

@end

CGEventRef eventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *eventTapObject) {
	return [((id) eventTapObject) handleEvent:[[Event alloc] initWithEventRef:event	tapProxy:proxy type:type]].eventRef;
}
