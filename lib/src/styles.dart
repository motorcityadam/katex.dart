// TODO(adamjcook): Add library description.
library katex.styles;

import 'tex_style.dart';


// Identifiers for the different styles.
int D = 0;
int Dc = 1;
int T = 2;
int Tc = 3;
int S = 4;
int Sc = 5;
int SS = 6;
int SSc = 7;

// String names for the different sizes.
List<String> sizeNames = [

	'displaystyle textstyle',
	'textstyle',
	'scriptstyle',
	'scriptscriptstyle'

];

// Reset names for the different sizes.
List<String> resetNames = [

    'reset-textstyle',
    'reset-textstyle',
    'reset-scriptstyle',
    'reset-scriptscriptstyle'

];

// Instances of the different styles.
List<TexStyle> styles = [

    new TexStyle(
    	id: D,
    	size: 0,
    	isCramped: false,
    	sizeMultiplier: 1.0 ),

    new TexStyle(
    	id: Dc,
    	size: 0,
    	isCramped: true,
    	sizeMultiplier: 1.0 ),

    new TexStyle(
    	id: T,
    	size: 1,
    	isCramped: false,
    	sizeMultiplier: 1.0 ),

    new TexStyle(
    	id: Tc,
    	size: 1,
    	isCramped: true,
    	sizeMultiplier: 1.0 ),

    new TexStyle(
    	id: S,
    	size: 2,
    	isCramped: false,
    	sizeMultiplier: 0.7 ),

    new TexStyle(
    	id: Sc,
    	size: 2,
    	isCramped: true,
    	sizeMultiplier: 0.7 ),

    new TexStyle(
    	id: SS,
    	size: 3,
    	isCramped: false,
    	sizeMultiplier: 0.5 ),

    new TexStyle(
    	id: SSc,
    	size: 3,
    	isCramped: true,
    	sizeMultiplier: 0.5 )

];

// Lookup tables for switching from one style to another.
List<int> sup = [ S, Sc, S, Sc, SS, SSc, SS, SSc ];
List<int> sub = [ Sc, Sc, Sc, Sc, SSc, SSc, SSc, SSc ];
List<int> fracNum = [ T, Tc, S, Sc, SS, SSc, SS, SSc ];
List<int> fracDen = [ Tc, Tc, Sc, Sc, SSc, SSc, SSc, SSc ];
List<int> cramp = [ Dc, Dc, Tc, Tc, Sc, Sc, SSc, SSc ];

TexStyle DISPLAY = styles[ D ];
TexStyle TEXT = styles[ T ];
TexStyle SCRIPT = styles[ S ];
TexStyle SCRIPTSCRIPT = styles[ SS ];