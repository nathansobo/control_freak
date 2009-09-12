//
//  Event.m
//  ControlFreak
//
//  Created by Nathan Sobo on 9/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Event.h"

@implementation Event

@synthesize eventRef;

-(id)initWithEventRef:(CGEventRef)anEventRef {
	eventRef = anEventRef;
	return self;
}



@end
