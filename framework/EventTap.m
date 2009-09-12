//
//  EventTap.m
//  ControlFreak
//
//  Created by Nathan Sobo on 9/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EventTap.h"
#import "Event.h"

@interface NSObject (RubyMethods)
-(Event*)onEvent:(Event*)event;
@end

@implementation EventTap
@synthesize eventTapProxy;

-(id)init {
	[super init];
	eventTapProxy = NULL;
	CFMachPortRef tap = CGEventTapCreate(kCGHIDEventTap,
										 kCGHeadInsertEventTap,
										 kCGEventTapOptionDefault,
										 kCGEventMaskForAllEvents,
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

-(void)postEvent:(Event*)event {
	if (eventTapProxy != NULL) {
		CGEventTapPostEvent(eventTapProxy, event.eventRef);	
	}
}
@end

CGEventRef eventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *eventTapObj) {
	EventTap *eventTapObject = (EventTap*) eventTapObj;
	if ([eventTapObject eventTapProxy] == NULL) [eventTapObject setEventTapProxy:proxy];
	return [eventTapObject handleEvent:[[Event alloc] initWithEventRef:event]].eventRef;
}
