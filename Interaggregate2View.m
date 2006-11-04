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


#import "Interaggregate2View.h"


@implementation Interaggregate2View

static void move (Disc *d, NSSize screenSize)
{
	d->p.x += d->v.x;
	d->p.y += d->v.y;
	
	if (d->r < d->dr)
	{
		d->r += 0.1;
	}

	if (d->p.x < 0)
	{
		d->p.x = screenSize.width;
	}
	if (d->p.x > screenSize.width)
	{
		d->p.x = 0;
	}
	if (d->p.y < 0)
	{
		d->p.y = screenSize.height;
	}
	if (d->p.y > screenSize.height)
	{
		d->p.y = 0;
	}
}

static void paint (CGContextRef cg, Painter *p, float x, float y, float ox, float oy)
{
	int i;
	
	p->g += SSRandomFloatBetween (-0.05, 0.05);
	if (p->g < -0.22)
	{
		p->g = -0.22;
	}
	if (p->g > 0.22)
	{
		p->g = 0.22;
	}
	
	p->p += SSRandomFloatBetween (-0.05, 0.05);
	if (p->p < 0.0)
	{
		p->p = 0.0;
	}
	if (p->p > 1.0)
	{
		p->p = 1.0;
	}
	
	float w = p->g / 10.0;
	
	for (i = 0; i < 11; i++)
	{
		float a = 0.1 - (float) i / 110;
		
		CGContextSetRGBFillColor (cg, p->red, p->green, p->blue, a);
		float x1 = ox + (x - ox) * sin (p->p + sin (i * w));
		float y1 = oy + (y - oy) * sin (p->p + sin (i * w));
		CGContextFillRect (cg, CGRectMake (x1, y1, 1, 1));
		float x2 = ox + (x - ox) * sin (p->p - sin (i * w));
		float y2 = oy + (y - oy) * sin (p->p - sin (i * w));
		CGContextFillRect (cg, CGRectMake (x2, y2, 1, 1));
	}
}

static NSString *kModuleName = @"org.metastatic.Interaggregate2";

#define NUMBER_OF_DISCS_KEY @"NumberOfDiscs"
#define DISC_VELOCITY_KEY   @"DiscVelocity"
#define DISC_SIZE_KEY       @"MaxDiscSize"
#define BGCOLOR_RED_KEY	    @"BackgroundRed"
#define BGCOLOR_GREEN_KEY   @"BackgroundGreen"
#define BGCOLOR_BLUE_KEY    @"BackgroundBlue"

- (id) initWithFrame: (NSRect) frame isPreview: (BOOL) isPreview
{
	if ((self = [super initWithFrame: frame isPreview: isPreview]) != nil)
	{
		if (isPreview)
		{
			[self setAnimationTimeInterval: 1 / 15.0];
		}
		else
		{
			[self setAnimationTimeInterval: 1 / 60.0];
		}
		
		defaults = [ScreenSaverDefaults defaultsForModuleWithName: kModuleName];
		[defaults registerDefaults: [NSDictionary dictionaryWithObjectsAndKeys:
									 @"100", NUMBER_OF_DISCS_KEY,
									 @"1.2", DISC_VELOCITY_KEY,
									 @"60", DISC_SIZE_KEY,
									 @"0.0", BGCOLOR_RED_KEY,
									 @"0.0", BGCOLOR_GREEN_KEY,
									 @"0.0", BGCOLOR_BLUE_KEY,
									 nil]];
		[self initDiscs];
	}
	return self;
}

- (void) initDiscs
{
	NSRect frame = [self frame];
	num = [defaults integerForKey: NUMBER_OF_DISCS_KEY];
	discs = (Disc *) malloc (num * sizeof (Disc));

	// Answer me: what the fuck?! Why am I doing it this way? Why does using
	// NSColor make this shit crash, and why can't I have
	//   colors[x] = { a, b, c };
	// here in This Modern World of ours?
	float colors[7][3];
	colors[0][0] = 1.0;
	colors[0][1] = 1.0;
	colors[0][2] = 1.0;       // white
	colors[1][0] = 0.0;
	colors[1][1] = 0.0;
	colors[1][2] = 0.0;       // black
	colors[2][0] = 0.0;
	colors[2][1] = 0.0;
	colors[2][2] = 0.0;       // more black
	colors[3][0] = 0.305;
	colors[3][1] = 0.243;
	colors[3][2] = 0.18;      // olive
	colors[4][0] = 0.412;
	colors[4][1] = 0.302;
	colors[4][2] = 0.208;     // camel
	colors[5][0] = 0.69;
	colors[5][1] = 0.627;
	colors[5][2] = 0.522;     // tan
	colors[6][0] = 0.902;
	colors[6][1] = 0.827;
	colors[6][2] = 0.682;

	int i;
	float velocity = [defaults floatForKey: DISC_VELOCITY_KEY];
	int maxSize= [defaults integerForKey: DISC_SIZE_KEY];
	for (i = 0; i < num; i++)
	{
		discs[i].index = i;
		discs[i].p.x = SSRandomFloatBetween (0.0, frame.size.width);
		discs[i].p.y = SSRandomFloatBetween (0.0, frame.size.height);
		discs[i].v.x = SSRandomFloatBetween (-velocity, velocity);
		discs[i].v.y = SSRandomFloatBetween (-velocity, velocity);
		discs[i].r = 0;
		discs[i].dr = SSRandomIntBetween (5, maxSize);
		discs[i].numpainters = 3; // XXX
		discs[i].painters = (Painter *) malloc (discs[i].numpainters * sizeof (Painter));
		int j;
		for (j = 0; j < discs[i].numpainters; j++)
		{
			int c = random () % 7;
			discs[i].painters[j].red = colors[c][0];
			discs[i].painters[j].green = colors[c][1];
			discs[i].painters[j].blue = colors[c][2];
			discs[i].painters[j].p = SSRandomFloatBetween (0.0, 1.0);
			discs[i].painters[j].g = SSRandomFloatBetween (0.01, 1.0);
		}
	}		
	firstFrame = YES;
  
  bgRed = [defaults floatForKey: BGCOLOR_RED_KEY];
  bgGreen = [defaults floatForKey: BGCOLOR_GREEN_KEY];
  bgBlue = [defaults floatForKey: BGCOLOR_BLUE_KEY];
}

- (void) releaseDiscs
{
	if (discs)
	{
		int i;
		for (i = 0; i < num; i++)
		{
			free (discs[i].painters);
		}
	}
	free (discs);
}

- (void) animateOneFrame
{
	CGContextRef cg = [[NSGraphicsContext currentContext] graphicsPort];
	NSRect frame = [self frame];

	if (firstFrame)
	{
		CGContextSetRGBFillColor (cg, bgRed, bgGreen, bgBlue, 1.0);
		CGContextFillRect (cg, CGRectMake (frame.origin.x, frame.origin.y,
										   frame.size.width, frame.size.height));
		firstFrame = NO;
	}

	int i;
	for (i = 0; i < num; i++)
	{
		move (&(discs[i]), frame.size);
		int j;
		for (j = i + 1; j < num; j++)
		{
			float dx = discs[j].p.x - discs[i].p.x;
			float dy = discs[j].p.y - discs[i].p.y;
			float d = sqrt (dx * dx + dy * dy);
			if (d < discs[j].r + discs[i].r)
			{
				if (d > fabsf (discs[j].r - discs[i].r))
				{
					float a = ((discs[i].r * discs[i].r)
							   - (discs[j].r * discs[j].r)
							   + (d * d)) / (2 * d);
					float p2x = (discs[i].p.x
						         + (a * (discs[j].p.x - discs[i].p.x)) / d);
					float p2y = (discs[i].p.y
					             + (a * (discs[j].p.y - discs[i].p.y)) / d);
          
					float h = sqrt ((discs[i].r * discs[i].r) - (a * a));
          
					float p3ax = p2x + (h * (discs[j].p.y - discs[i].p.y)) / d;
					float p3ay = p2y - (h * (discs[j].p.x - discs[i].p.x)) / d;
          
					float p3bx = p2x - (h * (discs[j].p.y - discs[i].p.y)) / d;
					float p3by = p2y + (h * (discs[j].p.x - discs[i].p.x)) / d;
					
					int k;
					for (k = 0; k < discs[i].numpainters; k++)
					{
						paint (cg, &(discs[i].painters[k]), p3ax, p3ay, p3bx, p3by);
					}
				}
			}
		}
	}
}

- (void) startAnimation
{
    [super startAnimation];
}

- (void) stopAnimation
{
    [super stopAnimation];
}

- (void) drawRect: (NSRect) rect
{
    [super drawRect: rect];
}

- (BOOL) hasConfigureSheet
{
    return YES;
}

- (NSWindow *) configureSheet
{
	if (!configSheet)
	{
		if (![NSBundle loadNibNamed: @"InteraggregateSheet" owner: self])
		{
			NSLog (@"failed to load configure sheet NIB");
		}
	}
	
	int numDiscs = [defaults integerForKey: NUMBER_OF_DISCS_KEY];
	[numDiscsSlider setIntValue: numDiscs];
	[numDiscsLabel setIntValue: numDiscs];
	
	float discVelocity = [defaults floatForKey: DISC_VELOCITY_KEY];
	[discVelocitySlider setFloatValue: discVelocity];
	[discVelocityLabel setFloatValue: discVelocity];
	
	int discSize = [defaults integerForKey: DISC_SIZE_KEY];
	[discSizeSlider setIntValue: discSize];
	[discSizeLabel setIntValue: discSize];
	
  [colorWell setColor: [NSColor colorWithCalibratedRed: bgRed
   green: bgGreen
   blue: bgBlue
   alpha: 1.0]];
  
	return configSheet;
}

- (IBAction) okayClick: (id) sender
{
	int numDiscs = [numDiscsSlider intValue];
	float discVelocity = [discVelocitySlider floatValue];
	int discSize = [discSizeSlider intValue];
	[defaults setInteger: numDiscs forKey: NUMBER_OF_DISCS_KEY];
	[defaults setFloat: discVelocity forKey: DISC_VELOCITY_KEY];
	[defaults setInteger: discSize forKey: DISC_SIZE_KEY];
	[defaults synchronize];
  NSColor *color = [[colorWell color] colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
  [defaults setFloat: [color redComponent] forKey: BGCOLOR_RED_KEY];
  [defaults setFloat: [color greenComponent] forKey: BGCOLOR_GREEN_KEY];
  [defaults setFloat: [color blueComponent] forKey: BGCOLOR_BLUE_KEY];

	[[NSApplication sharedApplication] endSheet: configSheet];
  
	[self stopAnimation];
	[self releaseDiscs];
	[self initDiscs];
	[self startAnimation];
}

- (IBAction) cancelClick: (id) sender
{
	[[NSApplication sharedApplication] endSheet: configSheet];
}

- (IBAction) numDiscsSlid: (id) sender
{
	if (numDiscsLabel && numDiscsSlider)
	{
		[numDiscsLabel setIntValue: [numDiscsSlider intValue]];
	}
}

- (IBAction) discVelocitySlid: (id) sender
{
	if (discVelocityLabel && discVelocitySlider)
	{
		[discVelocityLabel setFloatValue: [discVelocitySlider floatValue]];
	}
}

- (IBAction) discSizeSlid: (id) sender
{
	if (discSizeSlider && discSizeLabel)
	{
		[discSizeLabel setIntValue: [discSizeSlider intValue]];
	}
}

@end
