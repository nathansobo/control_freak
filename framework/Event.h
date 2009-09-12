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
}

@property CGEventRef eventRef;

-(id)initWithEventRef:(CGEventRef)eventRef;

@end
