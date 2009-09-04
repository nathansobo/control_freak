//
//  Event.h
//  ControlFreak
//
//  Created by Nathan Sobo on 9/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Event : NSObject {
	CGEventRef eventRef;
	CGEventTapProxy tapProxy;
	CGEventType type;
}

@property CGEventRef eventRef;
@property CGEventTapProxy tapProxy;
@property CGEventType type;

-(id)initWithEventRef:(CGEventRef)eventRef tapProxy:(CGEventTapProxy)tapProxy type:(CGEventType)type;

@end
