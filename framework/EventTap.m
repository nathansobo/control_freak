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

@implementation EventTap
-(id)initForEventTypes:(NSArray*)eventTypes {
	[super init];
	[self retain];
	CFMachPortRef tap = CGEventTapCreate(kCGHIDEventTap,
										 kCGHeadInsertEventTap,
										 kCGEventTapOptionListenOnly,
										 CGEventMaskBit(kCGEventKeyDown) | CGEventMaskBit(kCGEventKeyUp) | CGEventMaskBit(kCGEventFlagsChanged),
										 &eventCallback,
										 self);
	CFRunLoopSourceRef tapSource = CFMachPortCreateRunLoopSource(NULL, tap, 0);
	CFRunLoopAddSource((CFRunLoopRef) [[NSRunLoop currentRunLoop] getCFRunLoop], tapSource, kCFRunLoopCommonModes);
	
	return self;
}

-(CGEventRef)onEvent:(CGEventRef)event fromProxy:(CGEventTapProxy)proxy ofType:(CGEventType)type {
	if (delegate != NULL) {
		[delegate onEvent:[[Event alloc] initWithEventRef:event	tapProxy:proxy type:type]];
		return event;
	} else {
		return event;
	}
}

-(void)setDelegate:(id)aDelegate {
	[[NSGarbageCollector defaultCollector] disableCollectorForPointer:aDelegate];
	delegate = aDelegate;
}

@end

CGEventRef eventCallback(CGEventTapProxy proxy, 
						 CGEventType type, 
						 CGEventRef event, 
						 void *eventTapObject) {
	return [((id) eventTapObject) onEvent:event fromProxy:proxy ofType:type];
}
