//
//  EventTap.h
//  ControlFreak
//
//  Created by Nathan Sobo on 9/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface EventTap : NSObject {
	id delegate;
}
-(id)initForEventTypes:(NSArray*)eventTypes;
-(void)setDelegate:(id)delegate;
-(CGEventRef)onEvent:(CGEventRef)event fromProxy:(CGEventTapProxy)proxy ofType:(CGEventType)type;
@end

CGEventRef eventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *eventTapObject);