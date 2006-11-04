/* Interaggregate2View.m --
   Copyright (C) 2006  Casey Marshall <casey.s.marshall@gmail.com>
   Based on "Intersection Aggregate," by "j.tarbell" <complexification.net>
   And the xscreensaver hack, (C) 1997, 1998, 2002 Jamie Zawinski <jwz@jwz.org>
   
Permission to use, copy, modify, distribute, and sell this software and its
documentation for any purpose is hereby granted without fee, provided that
the above copyright notice appear in all copies and that both that
copyright notice and this permission notice appear in supporting
documentation.  No representations are made about the suitability of this
software for any purpose.  It is provided "as is" without express or 
implied warranty.  */


#import <ScreenSaver/ScreenSaver.h>

struct Painter
{
	float p, g;
	float red, green, blue;
};

typedef struct Painter Painter;

struct Disc
{
	// Index of this disc.
	int index;

	// Location of the disc center.
	NSPoint p;
	
	// Radius.
	float r;
	
	// Destination radius.
	float dr;
	
	// Velocity.
	NSPoint v;
	
	int numpainters;
	
	Painter *painters;
};

typedef struct Disc Disc;

@interface Interaggregate2View : ScreenSaverView
{
	BOOL firstFrame;

	// Maximum disc size.
	int dim;
	
	// Number of discs.
	int num;
	
	// The discs.
	Disc *discs;
	
	ScreenSaverDefaults *defaults;
	
	float bgRed;
	float bgGreen;
	float bgBlue;
	
	IBOutlet id configSheet;
	IBOutlet id numDiscsSlider;
	IBOutlet id numDiscsLabel;
	IBOutlet id discVelocitySlider;
	IBOutlet id discVelocityLabel;
	IBOutlet id discSizeSlider;
	IBOutlet id discSizeLabel;
	IBOutlet id okayButton;
	IBOutlet id cancelButton;
	IBOutlet id colorWell;
}

- (IBAction) okayClick: (id) sender;
- (IBAction) cancelClick: (id) sender;
- (IBAction) numDiscsSlid: (id) sender;
- (IBAction) discVelocitySlid: (id) sender;
- (IBAction) discSizeSlid: (id) sender;
- (void) initDiscs;
- (void) releaseDiscs;
@end
