//
//  Event.m
//  ControlFreak
//
//  Created by Nathan Sobo on 9/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Event.h"

@implementation Event

-(id)initWithEventRef:(CGEventRef)anEventRef tapProxy:(CGEventTapProxy)aTapProxy type:(CGEventType)aType {
	eventRef = anEventRef;
	tapProxy = aTapProxy;
	type = aType;
	return self;
}

@synthesize eventRef;
@synthesize tapProxy;
@synthesize type;

@end
