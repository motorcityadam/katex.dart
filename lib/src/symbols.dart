// TODO(adamjcook): Add library description.
library katex.symbols;

import 'tex_symbol.dart';


Map<String, Map<String, TexSymbol>> symbols = {

	'math': {

		'`': new TexSymbol(
			font: 'main',
			group: 'textord',
			replace: '\u2018'
		),

		'\\\$': new TexSymbol(
			font: 'main',
			group: 'textord',
			replace: r'$'
		),

		'\\%': new TexSymbol(
			font: 'main',
			group: 'textord',
			replace: '%'
		),

        '\\_': new TexSymbol(
        	font: 'main',
        	group: 'textord',
        	replace: '_'
        ),

        '\\angle': new TexSymbol(
        	font: 'main',
        	group: 'textord',
            replace: '\u2220'
        ),

        '\\infty': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u221e'
        ),

        '\\prime': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u2032'
        ),

        '\\triangle': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u25b3'
        ),

        '\\Gamma': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u0393'
        ),

        '\\Delta': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u0394'
        ),

        '\\Theta': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u0398'
        ),

        '\\Lambda': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u039b'
        ),

        '\\Xi': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u039e'
        ),

        '\\Pi': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u03a0'
        ),

        '\\Sigma': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u03a3'
        ),

        '\\Upsilon': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u03a5'
        ),

        '\\Phi': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u03a6'
        ),

        '\\Psi': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u03a8'
        ),

        '\\Omega': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u03a9'
        ),

        '\\neg': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u00ac'
        ),

        '\\lnot': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u00ac'
        ),

        '\\top': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u22a4'
        ),

        '\\bot': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u22a5'
        ),

        '\\emptyset': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u2205'
        ),

        '\\varnothing': new TexSymbol(
            font: 'ams',
            group: 'textord',
            replace: '\u2205'
        ),

        '\\alpha': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03b1'
        ),

        '\\beta': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03b2'
        ),

        '\\gamma': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03b3'
        ),

        '\\delta': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03b4'
        ),

        '\\epsilon': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03f5'
        ),

        '\\zeta': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03b6'
        ),

        '\\eta': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03b7'
        ),

        '\\theta': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03b8'
        ),

        '\\iota': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03b9'
        ),

        '\\kappa': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03ba'
        ),

        '\\lambda': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03bb'
        ),

        '\\mu': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03bc'
        ),

        '\\nu': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03bd'
        ),

        '\\xi': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03be'
        ),

        '\\omicron': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: 'o'
        ),

        '\\pi': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03c0'
        ),

        '\\rho': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03c1'
        ),

        '\\sigma': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03c3'
        ),

        '\\tau': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03c4'
        ),

        '\\upsilon': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03c5'
        ),

        '\\phi': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03d5'
        ),

        '\\chi': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03c7'
        ),

        '\\psi': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03c8'
        ),

        '\\omega': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03c9'
        ),

        '\\varepsilon': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03b5'
        ),

        '\\vartheta': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03d1'
        ),

        '\\varpi': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03d6'
        ),

        '\\varrho': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03f1'
        ),

        '\\varsigma': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03c2'
        ),

        '\\varphi': new TexSymbol(
            font: 'main',
            group: 'mathord',
            replace: '\u03c6'
        ),

        '*': new TexSymbol(
            font: 'main',
            group: 'bin',
            replace: '\u2217'
        ),

        '+': new TexSymbol(
            font: 'main',
            group: 'bin'
        ),

        '-': new TexSymbol(
            font: 'main',
            group: 'bin',
            replace: '\u2212'
        ),

        '\\cdot': new TexSymbol(
            font: 'main',
            group: 'bin',
            replace: '\u22c5'
        ),

        '\\circ': new TexSymbol(
            font: 'main',
            group: 'bin',
            replace: '\u2218'
        ),

        '\\div': new TexSymbol(
            font: 'main',
            group: 'bin',
            replace: '\u00f7'
        ),

        '\\pm': new TexSymbol(
            font: 'main',
            group: 'bin',
            replace: '\u00b1'
        ),

        '\\times': new TexSymbol(
            font: 'main',
            group: 'bin',
            replace: '\u00d7'
        ),

        '\\cap': new TexSymbol(
            font: 'main',
            group: 'bin',
            replace: '\u2229'
        ),

        '\\cup': new TexSymbol(
            font: 'main',
            group: 'bin',
            replace: '\u222a'
        ),

        '\\setminus': new TexSymbol(
            font: 'main',
            group: 'bin',
            replace: '\u2216'
        ),

        '\\land': new TexSymbol(
            font: 'main',
            group: 'bin',
            replace: '\u2227'
        ),

        '\\lor': new TexSymbol(
            font: 'main',
            group: 'bin',
            replace: '\u2228'
        ),

        '\\wedge': new TexSymbol(
            font: 'main',
            group: 'bin',
            replace: '\u2227'
        ),

        '\\vee': new TexSymbol(
            font: 'main',
            group: 'bin',
            replace: '\u2228'
        ),

        '\\surd': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u221a'
        ),

        '(': new TexSymbol(
            font: 'main',
            group: 'open'
        ),

        '[': new TexSymbol(
            font: 'main',
            group: 'open'
        ),

        '\\langle': new TexSymbol(
            font: 'main',
            group: 'open',
            replace: '\u27e8'
        ),

        '\\lvert': new TexSymbol(
            font: 'main',
            group: 'open',
            replace: '\u2223'
        ),

        ')': new TexSymbol(
            font: 'main',
            group: 'close'
        ),

        ']': new TexSymbol(
            font: 'main',
            group: 'close'
        ),

        '?': new TexSymbol(
            font: 'main',
            group: 'close'
        ),

        '!': new TexSymbol(
            font: 'main',
            group: 'close'
        ),

        '\\rangle': new TexSymbol(
            font: 'main',
            group: 'close',
            replace: '\u27e9'
        ),

        '\\rvert': new TexSymbol(
            font: 'main',
            group: 'close',
            replace: '\u2223'
        ),

        '=': new TexSymbol(
            font: 'main',
            group: 'rel'
        ),

        '<': new TexSymbol(
            font: 'main',
            group: 'rel'
        ),

        '>': new TexSymbol(
            font: 'main',
            group: 'rel'
        ),

        ':': new TexSymbol(
            font: 'main',
            group: 'rel'
        ),

        '\\approx': new TexSymbol(
            font: 'main',
            group: 'rel',
            replace: '\u2248'
        ),

        '\\cong': new TexSymbol(
            font: 'main',
            group: 'rel',
            replace: '\u2245'
        ),

        '\\ge': new TexSymbol(
            font: 'main',
            group: 'rel',
            replace: '\u2265'
        ),

        '\\geq': new TexSymbol(
            font: 'main',
            group: 'rel',
            replace: '\u2265'
        ),

        '\\gets': new TexSymbol(
            font: 'main',
            group: 'rel',
            replace: '\u2190'
        ),

        '\\in': new TexSymbol(
            font: 'main',
            group: 'rel',
            replace: '\u2208'
        ),

        '\\notin': new TexSymbol(
            font: 'main',
            group: 'rel',
            replace: '\u2209'
        ),

        '\\subset': new TexSymbol(
            font: 'main',
            group: 'rel',
            replace: '\u2282'
        ),

        '\\supset': new TexSymbol(
            font: 'main',
            group: 'rel',
            replace: '\u2283'
        ),

        '\\subseteq': new TexSymbol(
            font: 'main',
            group: 'rel',
            replace: '\u2286'
        ),

        '\\supseteq': new TexSymbol(
            font: 'main',
            group: 'rel',
            replace: '\u2287'
        ),

        '\\nsubseteq': new TexSymbol(
            font: 'ams',
            group: 'rel',
            replace: '\u2288'
        ),

        '\\nsupseteq': new TexSymbol(
            font: 'ams',
            group: 'rel',
            replace: '\u2289'
        ),

        '\\models': new TexSymbol(
            font: 'main',
            group: 'rel',
            replace: '\u22a8'
        ),

        '\\leftarrow': new TexSymbol(
            font: 'main',
            group: 'rel',
            replace: '\u2190'
        ),

        '\\le': new TexSymbol(
            font: 'main',
            group: 'rel',
            replace: '\u2264'
        ),

        '\\leq': new TexSymbol(
            font: 'main',
            group: 'rel',
            replace: '\u2264'
        ),

        '\\ne': new TexSymbol(
            font: 'main',
            group: 'rel',
            replace: '\u2260'
        ),

        '\\neq': new TexSymbol(
            font: 'main',
            group: 'rel',
            replace: '\u2260'
        ),

        '\\rightarrow': new TexSymbol(
            font: 'main',
            group: 'rel',
            replace: '\u2192'
        ),

        '\\to': new TexSymbol(
            font: 'main',
            group: 'rel',
            replace: '\u2192'
        ),

        '\\ngeq': new TexSymbol(
            font: 'ams',
            group: 'rel',
            replace: '\u2271'
        ),

        '\\nleq': new TexSymbol(
            font: 'ams',
            group: 'rel',
            replace: '\u2270'
        ),

        '\\!': new TexSymbol(
            font: 'main',
            group: 'spacing'
        ),

        '\\ ': new TexSymbol(
            font: 'main',
            group: 'spacing',
            replace: '\u00a0'
        ),

        '~': new TexSymbol(
            font: 'main',
            group: 'spacing',
            replace: '\u00a0'
        ),

        '\\,': new TexSymbol(
            font: 'main',
            group: 'spacing'
        ),

        '\\:': new TexSymbol(
            font: 'main',
            group: 'spacing'
        ),

        '\\;': new TexSymbol(
            font: 'main',
            group: 'spacing'
        ),

        '\\enspace': new TexSymbol(
            font: 'main',
            group: 'spacing'
        ),

        '\\qquad': new TexSymbol(
            font: 'main',
            group: 'spacing'
        ),

        '\\quad': new TexSymbol(
            font: 'main',
            group: 'spacing'
        ),

        '\\space': new TexSymbol(
            font: 'main',
            group: 'spacing',
            replace: '\u00a0'
        ),

        ',': new TexSymbol(
            font: 'main',
            group: 'punct'
        ),

        ';': new TexSymbol(
            font: 'main',
            group: 'punct'
        ),

        '\\colon': new TexSymbol(
            font: 'main',
            group: 'punct',
            replace: ':'
        ),

        '\\barwedge': new TexSymbol(
            font: 'ams',
            group: 'textord',
            replace: '\u22bc'
        ),

        '\\veebar': new TexSymbol(
            font: 'ams',
            group: 'textord',
            replace: '\u22bb'
        ),

        '\\odot': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u2299'
        ),

        '\\oplus': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u2295'
        ),

        '\\otimes': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u2297'
        ),

        '\\partial': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u2202'
        ),

        '\\oslash': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u2298'
        ),

        '\\circledcirc': new TexSymbol(
            font: 'ams',
            group: 'textord',
            replace: '\u229a'
        ),

        '\\boxdot': new TexSymbol(
            font: 'ams',
            group: 'textord',
            replace: '\u22a1'
        ),

        '\\bigtriangleup': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u25b3'
        ),

        '\\bigtriangledown': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u25bd'
        ),

        '\\dagger': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u2020'
        ),

        '\\diamond': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u22c4'
        ),

        '\\star': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u22c6'
        ),

        '\\triangleleft': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u25c3'
        ),

        '\\triangleright': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u25b9'
        ),

        '\\{': new TexSymbol(
            font: 'main',
            group: 'open',
            replace: '{'
        ),

        '\\}': new TexSymbol(
            font: 'main',
            group: 'close',
            replace: ')'
        ),

        '\\lbrace': new TexSymbol(
            font: 'main',
            group: 'open',
            replace: '{'
        ),

        '\\rbrace': new TexSymbol(
            font: 'main',
            group: 'close',
            replace: '}'
        ),

        '\\lbrack': new TexSymbol(
            font: 'main',
            group: 'open',
            replace: '['
        ),

        '\\rbrack': new TexSymbol(
            font: 'main',
            group: 'close',
            replace: ']'
        ),

        '\\lfloor': new TexSymbol(
            font: 'main',
            group: 'open',
            replace: '\u230a'
        ),

        '\\rfloor': new TexSymbol(
            font: 'main',
            group: 'close',
            replace: '\u230b'
        ),

        '\\lceil': new TexSymbol(
            font: 'main',
            group: 'open',
            replace: '\u2308'
        ),

        '\\rceil': new TexSymbol(
            font: 'main',
            group: 'close',
            replace: '\u2309'
        ),

        '\\backslash': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\\'
        ),

        '|': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u2223'
        ),

        '\\vert': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u2223'
        ),

        '\\|': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u2225'
        ),

        '\\Vert': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u2225'
        ),

        '\\uparrow': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u2191'
        ),

        '\\Uparrow': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u21d1'
        ),

        '\\downarrow': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u2193'
        ),

        '\\Downarrow': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u21d3'
        ),

        '\\updownarrow': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u2195'
        ),

        '\\Updownarrow': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u21d5'
        ),

        '\\coprod': new TexSymbol(
            font: 'math',
            group: 'op',
            replace: '\u2210'
        ),

        '\\bigvee': new TexSymbol(
            font: 'math',
            group: 'op',
            replace: '\u22c1'
        ),

        '\\bigwedge': new TexSymbol(
            font: 'math',
            group: 'op',
            replace: '\u22c0'
        ),

        '\\biguplus': new TexSymbol(
            font: 'math',
            group: 'op',
            replace: '\u2a04'
        ),

        '\\bigcap': new TexSymbol(
            font: 'math',
            group: 'op',
            replace: '\u22c2'
        ),

        '\\bigcup': new TexSymbol(
            font: 'math',
            group: 'op',
            replace: '\u22c3'
        ),

        '\\int': new TexSymbol(
            font: 'math',
            group: 'op',
            replace: '\u222b'
        ),

        '\\intop': new TexSymbol(
            font: 'math',
            group: 'op',
            replace: '\u222b'
        ),

        '\\iint': new TexSymbol(
            font: 'math',
            group: 'op',
            replace: '\u222c'
        ),

        '\\iiint': new TexSymbol(
            font: 'math',
            group: 'op',
            replace: '\u222d'
        ),

        '\\prod': new TexSymbol(
            font: 'math',
            group: 'op',
            replace: '\u220f'
        ),

        '\\sum': new TexSymbol(
            font: 'math',
            group: 'op',
            replace: '\u2211'
        ),

        '\\bigotimes': new TexSymbol(
            font: 'math',
            group: 'op',
            replace: '\u2a02'
        ),

        '\\bigoplus': new TexSymbol(
            font: 'math',
            group: 'op',
            replace: '\u2a01'
        ),

        '\\bigodot': new TexSymbol(
            font: 'math',
            group: 'op',
            replace: '\u2a00'
        ),

        '\\oint': new TexSymbol(
            font: 'math',
            group: 'op',
            replace: '\u222e'
        ),

        '\\bigsqcup': new TexSymbol(
            font: 'math',
            group: 'op',
            replace: '\u2a06'
        ),

        '\\smallint': new TexSymbol(
            font: 'math',
            group: 'op',
            replace: '\u222b'
        ),

        '\\ldots': new TexSymbol(
            font: 'main',
            group: 'punct',
            replace: '\u2026'
        ),

        '\\cdots': new TexSymbol(
            font: 'main',
            group: 'inner',
            replace: '\u22ef'
        ),

        '\\ddots': new TexSymbol(
            font: 'main',
            group: 'inner',
            replace: '\u22f1'
        ),

        '\\vdots': new TexSymbol(
            font: 'main',
            group: 'textord',
            replace: '\u22ee'
        ),

        '\\acute': new TexSymbol(
            font: 'main',
            group: 'accent',
            replace: '\u00b4'
        ),

        '\\grave': new TexSymbol(
            font: 'main',
            group: 'accent',
            replace: '\u0060'
        ),

        '\\ddot': new TexSymbol(
            font: 'main',
            group: 'accent',
            replace: '\u00a8'
        ),

        '\\tilde': new TexSymbol(
            font: 'main',
            group: 'accent',
            replace: '\u007e'
        ),

        '\\bar': new TexSymbol(
            font: 'main',
            group: 'accent',
            replace: '\u00af'
        ),

        '\\breve': new TexSymbol(
            font: 'main',
            group: 'accent',
            replace: '\u02d8'
        ),

        '\\check': new TexSymbol(
            font: 'main',
            group: 'accent',
            replace: '\u02c7'
        ),

        '\\hat': new TexSymbol(
            font: 'main',
            group: 'accent',
            replace: '\u005e'
        ),

        '\\vec': new TexSymbol(
            font: 'main',
            group: 'accent',
            replace: '\u20d7'
        ),

        '\\dot': new TexSymbol(
            font: 'main',
            group: 'accent',
            replace: '\u02d9'
        )

	},
	'text': {

		'\\ ': new TexSymbol(
			font: 'main', 
			group: 'spacing',
			replace: '\u00a0'
		),

		' ': new TexSymbol(
			font: 'main', 
			group: 'spacing',
			replace: '\u00a0'
		),

		'~': new TexSymbol(
			font: 'main', 
			group: 'spacing',
			replace: '\u00a0'
		)

	}

};

void initSymbols () {

    List<String> mathTextSymbols = "0123456789/@.\"".split('');
    List<String> textSymbols = "0123456789`!@*()-=+[]'\";:?/.,".split('');
    List<String> letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".split('');

    mathTextSymbols.forEach( ( character ) {
        symbols[ 'math' ][ character ] = new TexSymbol( font: 'main',
                                                        group: 'textord' );
    });

    textSymbols.forEach( ( character ) {
        symbols[ 'text' ][ character ] = new TexSymbol( font: 'main',
                                                        group: 'textord' );
    });

    letters.forEach( ( character ) {
        symbols[ 'math' ][ character ] = new TexSymbol( font: 'main',
                                                        group: 'mathord' );
        symbols[ 'text' ][ character ] = new TexSymbol( font: 'main',
                                                        group: 'textord' );
    });

}