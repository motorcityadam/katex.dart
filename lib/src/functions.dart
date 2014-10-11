// TODO(adamjcook): Add library description.
library katex.functions;

import 'parse_error.dart';
import 'parse_node.dart';
import 'tex_function.dart';


Map<String, TexFunction> functions = {
    // Normal square root.
    '\\sqrt': new TexFunction(
        numArgs: 1,
        handler: ( body ) {
            return {
                'type': 'sqrt',
                'body': body
            };
        }
    ),

    // Non-mathematical text.
    '\\text': new TexFunction(
        numArgs: 1,
        argTypes: [ 'text' ],
        greediness: 2,
        handler: ( body ) {
            // Since the corresponding buildTree function expects a list of
            // elements, we normalize for different kinds of arguments
            var inner;
            if ( body[ 'type' ] == 'ordgroup' ) {
                inner = body[ 'value' ];
            } else {
                inner = [ body ];
            }

            return {
                'type': 'text',
                'body': inner
            };
        }
    ),

    // Two-argument custom color.
    '\\color': new TexFunction(
        numArgs: 2,
        allowedInText: true,
        argTypes: [ 'color', 'original' ],
        handler: ( color, body ) {
            // Normalize the different kinds of bodies (see \text above)
            var inner;
            if ( body.type == 'ordgroup' ) {
                inner = body[ 'value' ];
            } else {
                inner = [ body ];
            }

            return {
                'type': 'color',
                'color': color.value,
                'value': inner
            };
        }
    ),

    // Overline.
    '\\overline': new TexFunction(
        numArgs: 1,
        handler: ( body ) {
            return {
                'type': 'overline',
                'body': body
            };
        }
    ),

    // Box of the width and height.
    '\\rule': new TexFunction(
        numArgs: 2,
        argTypes: [ 'size', 'size' ],
        handler: ( width, height ) {
            return {
                'type': 'rule',
                'width': width.value,
                'height': height.value
            };
        }
    ),

    // A KaTeX logo
    '\\KaTeX': new TexFunction(
        numArgs: 0,
        handler: () {
            return {
                'type': 'katex'
            };
        }
    )
};

// Extra data needed for the delimiter handler down below
// TODO(adamjcook): Eliminate dynamic type.
Map<String, Map<String, dynamic>> delimiterSizes = {

    '\\bigl': {
        'type': 'open',
        'size': 1
    },

    '\\Bigl': {
        'type': 'open',
        'size': 2
    },

    '\\biggl': {
        'type': 'open',
        'size': 3
    },

    '\\Biggl': {
        'type': 'open',
        'size': 4
    },

    '\\bigr': {
        'type': 'close',
        'size': 1
    },

    '\\Bigr': {
        'type': 'close',
        'size': 2
    },

    '\\biggr': {
        'type': 'close',
        'size': 3
    },

    '\\Biggr': {
        'type': 'close',
        'size': 4
    },

    '\\bigm': {
        'type': 'rel',
        'size': 1
    },

    '\\Bigm': {
        'type': 'rel',
        'size': 2
    },

    '\\biggm': {
        'type': 'rel',
        'size': 3
    },

    '\\Biggm': {
        'type': 'rel',
        'size': 4
    },

    '\\big': {
        'type': 'textord',
        'size': 1
    },

    '\\Big': {
        'type': 'textord',
        'size': 2
    },

    '\\bigg': {
        'type': 'textord',
        'size': 3
    },

    '\\Bigg': {
        'type': 'textord',
        'size': 4
    }

};

List<String> delimiters = [

    '(', ')', '[', ']', '<', '>', '\\{', '\\}', '/', '|', '\\|', '.'
    '\\lbrack', '\\rbrack',
    '\\lbrace', '\\rbrace',
    '\\lfloor', '\\rfloor',
    '\\lceil', '\\rceil',
    '\\langle', '\\rangle',
    '\\backslash',
    '\\vert', '\\Vert',
    '\\uparrow', '\\Uparrow',
    '\\downarrow', '\\Downarrow',
    '\\updownarrow', '\\Updownarrow'

];

List<Map<String, dynamic>> duplicatedFunctions = [
    // Single-argument color functions
    {
        'funcs': [

            '\\blue', 
            '\\orange',
            '\\pink',
            '\\red',
            '\\green',
            '\\gray',
            '\\purple'

        ],
        'data': new TexFunction(
            numArgs: 1,
            allowedInText: true,
            handler: ( func, body ) {
                var atoms;
                if ( body.type == 'ordgroup' ) {
                    atoms = body.value;
                } else {
                    atoms = [body];
                }

                return {
                    'type': "color",
                    'color': "katex-" + func.slice(1),
                    'value': atoms
                };
            }
        )
    },

    // There are 2 flags for operators; whether they produce limits in
    // displaystyle, and whether they are symbols and should grow in
    // displaystyle. These four groups cover the four possible choices.

    // No limits, not symbols
    {
        'funcs': [

            '\\arcsin', '\\arccos', '\\arctan',
            '\\arg',
            '\\cos', '\\cosh', '\\cot', '\\coth', '\\csc',
            '\\deg',
            '\\dim',
            '\\exp',
            '\\hom',
            '\\ker',
            '\\lg', '\\ln',
            '\\log',
            '\\sec', '\\sin', '\\sinh',
            '\\tan', '\\tanh'

        ],
        'data': new TexFunction(
            numArgs: 0,
            handler: ( func ) {
                return {
                    'type': 'op',
                    'limits': false,
                    'symbol': false,
                    'body': func
                };
            }
        )
    },

    // Limits, not symbols
    {
        'funcs': [

            '\\det',
            '\\gcd',
            '\\inf',
            '\\lim',
            '\\liminf',
            '\\limsup',
            '\\max',
            '\\min',
            '\\Pr',
            '\\sup'

        ],
        'data': new TexFunction(
            numArgs: 0,
            handler: ( func ) {
                return {
                    'type': 'op',
                    'limits': true,
                    'symbol': false,
                    'body': func
                };
            }
        )
    },

    // No limits, symbols
    {
        'funcs': [

            '\\int',
            '\\iint',
            '\\iiint',
            '\\oint'

        ],
        'data': new TexFunction(
            numArgs: 0,
            handler: ( func ) {
                return {
                    'type': 'op',
                    'limits': false,
                    'symbol': true,
                    'body': func
                };
            }
        )
    },

    // Limits, symbols
    {
        'funcs': [

            '\\coprod',
            '\\bigvee',
            '\\bigwedge',
            '\\biguplus',
            '\\bigcap',
            '\\bigcup',
            '\\intop',
            '\\prod',
            '\\sum',
            '\\bigotimes',
            '\\bigoplus',
            '\\bigodot',
            '\\bigsqcup',
            '\\smallint'

        ],
        'data': new TexFunction(
            numArgs: 0,
            handler: ( func ) {
                return {
                    'type': "op",
                    'limits': true,
                    'symbol': true,
                    'body': func
                };
            }
        )
    },

    // Fractions
    {
        'funcs': [

            '\\dfrac',
            '\\frac', 
            '\\tfrac'

        ],
        'data': new TexFunction(
            numArgs: 2,
            greediness: 2,
            handler: ( String func, ParseNode numer,
                       ParseNode denom, List<num> positions ) {

                return {
                    'type': 'frac',
                    'numer': numer,
                    'denom': denom,
                    'size': func.substring(1)
                };

            }
        )
    },

    // Left and right overlap functions
    {
        'funcs': [

            '\\llap', '\\rlap'

        ],
        'data': new TexFunction(
            numArgs: 1,
            allowedInText: true,
            handler: ( func, body ) {
                return {
                    'type': func.slice(1),
                    'body': body
                };
            }
        )
    },

    // Delimiter functions
    {
        'funcs': [

            '\\bigl', '\\Bigl', '\\biggl', '\\Biggl',
            '\\bigr', '\\Bigr', '\\biggr', '\\Biggr',
            '\\bigm', '\\Bigm', '\\biggm', '\\Biggm',
            '\\big', '\\Big', '\\bigg', '\\Bigg',
            '\\left', '\\right'

        ],
        'data': new TexFunction(
            numArgs: 1,
            handler: ( String func, ParseNode delim, List<num> positions ) {
                if ( !delimiters.contains( delim.value ) ) {
                    throw new ParseError( 'Invalid delimiter.' );
                }

                // left and right are caught somewhere in Parser.js, which is
                // why this data doesn't match what is in buildTree
                if ( func == '\\left' || func == '\\right' ) {
                    return {
                        'type': 'leftright',
                        'value': delim.value
                    };
                } else {
                    return {
                        'type': 'delimsizing',
                        'size': delimiterSizes[ func ][ 'size' ],
                        'delimType': delimiterSizes[ func ][ 'type' ],
                        'value': delim.value
                    };
                }
            }
        )
    },

    // Sizing functions (handled in Parser.js explicitly, hence no handler)
    {
        'funcs': [

            '\\tiny',
            '\\scriptsize',
            '\\footnotesize',
            '\\small',
            '\\normalsize',
            '\\large', '\\Large', '\\LARGE',
            '\\huge', '\\Huge'

        ],
        'data': new TexFunction(
            numArgs: 0
        )
    },

    // Style changing functions (handled in Parser.js explicitly, hence no
    // handler)
    {
        'funcs': [

            '\\displaystyle',
            '\\textstyle',
            '\\scriptstyle',
            '\\scriptscriptstyle'

        ],
        'data': new TexFunction(
            numArgs: 0
        )
    },

    // Accents
    {
        'funcs': [

            '\\acute',
            '\\grave',
            '\\ddot',
            '\\tilde',
            '\\bar',
            '\\breve',
            '\\check',
            '\\hat',
            '\\vec',
            '\\dot'
            // TODO(adamjcook): Add support for expanding accents.
            // '\\widetilde', '\\widehat'
        ],
        'data': new TexFunction(
            numArgs: 1,
            handler: ( func, base ) {
                return {
                    'type': 'accent',
                    'accent': func,
                    'base': base
                };
            }
        )
    }
];

void addFuncsWithData ( List<String> funcs, dynamic data ) {

    funcs.forEach( ( func ) {

        functions[func] = data;

    });

}

void initFunctions () {
    // Add all of the functions in duplicatedFunctions to the functions map
    duplicatedFunctions.forEach( ( element ) {

            addFuncsWithData( element[ 'funcs' ], element[ 'data' ] );

    });

}