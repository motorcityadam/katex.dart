// TODO(adamjcook): Add library description
library katex.parser;

import 'package:logging/logging.dart';

import 'functions.dart';
import 'lexer.dart';
import 'parse_error.dart';
import 'parse_func_or_argument.dart';
import 'parse_node.dart';
import 'parse_result.dart';
import 'tex_function.dart';
import 'token.dart';
import 'symbols.dart';


final Logger _logger = new Logger( 'katex.parser' );

// Sets the 'greediness' of a superscript or subscript.
num SUPSUB_GREEDINESS = 1;

// TODO(adamjcook): Add class description.
class Parser {

	final bool loggingEnabled;
	final String expression;
	Lexer _lexer;

	Parser(
		{ String expression: '',
		  bool loggingEnabled: false } )
	: this._init(
      expression: expression,
      loggingEnabled: loggingEnabled );

	Parser._init(
		{ this.expression,
		  this.loggingEnabled } ) {

	    if ( this.loggingEnabled == true ) {
            Logger.root.level = Level.ALL;
            Logger.root.onRecord.listen(( LogRecord rec ) {
                print( '${rec.level.name}: ${rec.time}: ${rec.loggerName}: ${rec.message}' );
            });
	    }

        _logger.fine( 'Parser init :: with expression: ${ this.expression }');

	    _lexer = new Lexer(
                      expression: this.expression,
                      loggingEnabled: this.loggingEnabled );

        _logger.fine(
                'Parser init, Lexer created :: ' +
                '_lexer.expression: ${ _lexer.expression }');

  	}

  	// ===================== START PRIVATE METHODS =====================

    /**
     * Checks a result to make sure it has the right type, and throws an
     * appropriate error otherwise.
     */
    void _expect ( { Token result, String expected } ) {

      if ( result.text != expected ) {
        throw new ParseError(
            message: 'Expected ' + expected + ', got ' + result.text,
            lexer: _lexer,
            position: result.position );
      }

    }

    // TODO(adamjcook): Add method description.
    List<ParseNode> _handleInfixNodes ( { List<ParseNode> body, String mode } ) {

      num overIndex = -1;
      TexFunction func;
      String funcName;
      ParseNode node;

      for ( num i = 0; i < body.length; i++ ) {

        node = body[ i ];

        if ( node.type == 'infix' ) {

          if ( overIndex != -1 ) {

            throw new ParseError(
                        message: 'Only one infix operator allowed per group',
                        lexer: _lexer,
                        position: -1 );

          }

          overIndex = i;
          funcName = node.value[ 'replaceWith' ];
          func = functions[ funcName ];

        }

      }

      if ( overIndex != -1 ) {

        ParseNode numerNode;
        ParseNode denomNode;

        List<ParseNode> numerBody = body.sublist( 0, overIndex );
        List<ParseNode> denomBody = body.sublist( overIndex + 1 );

        if ( numerBody.length == 1 && numerBody[ 0 ].type == 'ordgroup' ) {
          numerNode = numerBody[ 0 ];
        } else {
          numerNode = new ParseNode(
                            type: 'ordgroup', value: numerBody, mode: mode );
        }

        if ( denomBody.length == 1 && denomBody[0].type == 'ordgroup' ) {
          denomNode = denomBody[ 0 ];
        } else {
          denomNode = new ParseNode(
                            type: 'ordgroup', value: denomBody, mode: mode );
        }

        Map<String, dynamic> value = func.handler(
                                       funcName, numerNode, denomNode, [ 0, 0 ] );

        return [ new ParseNode(
                            type: value[ 'type' ], value: value, mode: mode ) ];

      } else {

        return body;

      }

    }


    // TODO(adamjcook): Add method description.
    ParseResult _handleSupSubscript ( { num position, String mode,
                                        String symbol, String name } ) {

      ParseFuncOrArgument group = _parseGroup( position: position, mode: mode );

      if ( group == null ) {

          throw new ParseError(
                        message: 'Expected group after: ' + symbol,
                        lexer: _lexer,
                        position: position );

      } else if ( group.numArgs > 0 ) {

          // ^ and _ have a greediness, so handle interactions with functions'
          // greediness
          num funcGreediness =
            functions[ group.result.result[ 0 ].type ].greediness;

          if ( funcGreediness > SUPSUB_GREEDINESS ) {

              return _parseFunction( position: position, mode: mode );

          } else {

              throw new ParseError(
                  message: 'Got function ' + group.result.result.toString() +
                  ' with no arguments as ' + name,
                  lexer: _lexer,
                  position: position );

          }

      } else {

          return group.result;

      }

    }


    // TODO(adamjcook): Add method description.
  	ParseResult _parseAtom ( { num position, String mode } ) {

        _logger.fine( '_parseAtom() method :: called' );

        // The body of an atom is an implicit group, so that things like
        // \left(x\right)^2 work correctly.
        ParseResult base = _parseImplicitGroup( position: position, mode: mode );

        // In text mode, we don't have superscripts or subscripts
        if ( mode == 'text' ) {
            return base;
        }

        // Handle an empty base
        num currentPosition;

        if ( base == null ) {

            currentPosition = position;
            base = null;

            _logger.fine(
                '_parseAtom() method, _parseImplicitGroup returned : ' +
                'base returned is NULL : ' +
                'currentPosition: ${ currentPosition }' );

        } else {

            _logger.fine(
                '_parseAtom() method, _parseImplicitGroup returned : ' +
                'base.position: ${ base.position } : ' +
                'base.result[0].type: ${ base.result[0].type } : ' +
                'base.result[0].value: ${ base.result[0].value } : ' +
                'base.result[0].mode: ${ base.result[0].mode }' );

            currentPosition = base.position;

        }

        ParseNode superscript;
        ParseNode subscript;

        while ( true ) {

            // Lex the first token
            Token lexResult = _lexer.lex( position: currentPosition,
                                          mode: mode );

            if ( lexResult.text == '^' ) {

                // We got a superscript start
                if ( superscript != null ) {
                    throw new ParseError(
                                  message: 'Double superscript',
                                  lexer: _lexer,
                                  position: currentPosition );
                }

                ParseResult result = _handleSupSubscript(
                                          position: lexResult.position,
                                          mode: mode,
                                          symbol: lexResult.text,
                                          name: 'superscript' );

                currentPosition = result.position;
                superscript = result.result[ 0 ];

            } else if ( lexResult.text == '_' ) {

                // We got a subscript start
                if ( subscript != null ) {
                    throw new ParseError(
                                  message: 'Double subscript',
                                  lexer: _lexer,
                                  position: currentPosition );
                }

                ParseResult result = _handleSupSubscript(
                                        position: lexResult.position,
                                        mode: mode,
                                        symbol: lexResult.text,
                                        name: 'subscript' );

                currentPosition = result.position;
                subscript = result.result[ 0 ];

            } else if ( lexResult.text == "'" ) {

                // We got a prime
                ParseNode prime = new ParseNode(
                                    type: 'textord',
                                    value: '\\prime',
                                    mode: mode );

                // Many primes can be grouped together, so we handle this here
                List<ParseNode> primes = [ prime ];
                currentPosition = lexResult.position;

                // Keep lexing tokens until we get something that's not a prime
                while ( (lexResult = _lexer.lex(
                                        position: currentPosition,
                                        mode: mode ) ).text == "'" ) {

                    // For each one, add another prime to the list
                    primes.add( prime );
                    currentPosition = lexResult.position;

                }

                // Put them into an ordgroup as the superscript
                superscript = new ParseNode(
                                        type: 'ordgroup',
                                        value: primes,
                                        mode: mode );

            } else {

                // If it wasn't ^, _, or ', stop parsing super/subscripts
                break;

            }

        }

        if ( superscript != null || subscript != null ) {

          // If we got either a superscript or subscript, create a supsub
          return new ParseResult(
            result: [ new ParseNode(
                        type: 'supsub',
                        value: {
                            'base': base != null ? base.result[ 0 ] : null, // ParseNode
                            'sup': superscript, // ParseNode
                            'sub': subscript }, // ParseNode
                        mode: mode ) ],
            position: currentPosition );

        } else {

          // Otherwise return the original body
          return base;

        }

  	}


    // TODO(adamjcook): Add method description.
    ParseResult _parseExpression( { num position, String mode,
                                    bool breakOnInfix, String breakOnToken } ) {

      _logger.fine( '_parseExpression() method :: called' );

      List<ParseNode> body = [];

      // Continue adding atoms to the body [List] until atom parsing stops
      // (parsing stops when either the end is reached, or a '}' is encountered,
      // or a '\right' is encountered).
      while (true) {

        Token lex = _lexer.lex( position: position, mode: mode );
        if ( breakOnToken != null && lex.text == breakOnToken ) {
          break;
        }

        ParseResult atom = _parseAtom( position: position, mode: mode );
        if ( atom == null ) {
          break;
        }

        if ( breakOnInfix && atom.result[ 0 ].type == 'infix' ) {
          break;
        }

        body.add( atom.result[ 0 ] );
        position = atom.position;

      }

      return new ParseResult(
                        result: _handleInfixNodes(
                                          body: body,
                                          mode: mode ),
                        position: position );

    }


    // TODO(adamjcook): Add method description.
  	ParseResult _parseFunction ( { num position, String mode } ) {

        ParseFuncOrArgument baseGroup = _parseGroup( position: position,
                                                     mode: mode);

        if ( baseGroup != null ) {

            if ( baseGroup.isFunction ) {

                List<ParseNode> funcList = baseGroup.result.result;

                if ( mode == 'text' && baseGroup.isAllowedInText == false ) {

                    throw new ParseError(
                        message: 'Cannot use function ' + funcList.toString() +
                          ' in text mode',
                        lexer: _lexer,
                        position: baseGroup.result.position );

                }

                int newPosition = baseGroup.result.position;
                TexFunction resultFunc;
                var result;
                ParseFuncOrArgument arg;

                num totalArgs = baseGroup.numArgs + baseGroup.numOptionalArgs;

                if ( totalArgs > 0 ) {

                    num baseGreediness =
                      functions[ baseGroup.result.result[ 0 ].type ].greediness;

                    List args = [ funcList[0].type ];

                    List<int> positions = [ newPosition ];

                    for ( num i = 0; i < totalArgs; i++ ) {

                        String argType;

                        if ( baseGroup.argTypes == null ) {
                          argType = null;
                        } else {
                          argType = baseGroup.argTypes[ i ];
                        }

                        ParseFuncOrArgument arg;

                        if ( i < baseGroup.numOptionalArgs ) {

                          if ( argType != null ) {
                            arg = _parseSpecialGroup(
                                                position: newPosition,
                                                mode: argType,
                                                outerMode: mode,
                                                optional: true );
                          } else {
                            arg = _parseOptionalGroup(
                                                position: newPosition,
                                                mode: mode );
                          }

                          if ( arg == null ) {
                            args.add( null );
                            positions.add( newPosition );
                            continue;
                          }

                        } else {

                          if ( argType != null ) {
                            arg = _parseSpecialGroup(
                                        position: newPosition,
                                        mode: argType,
                                        outerMode: mode );
                          } else {
                            arg = _parseGroup(
                                        position: newPosition,
                                        mode: mode );
                          }

                          if ( arg == null ) {
                            throw new ParseError(
                                message: 'Expected group after ' +
                                  baseGroup.result.result[ 0 ].type,
                                lexer: _lexer,
                                position: newPosition );
                          }

                        }

                        ParseResult argNode;
                        if ( arg.numArgs > 0 ) {

                            num argGreediness =
                              functions[ arg.result.result[0].type ].greediness;
                            if (argGreediness > baseGreediness) {

                                argNode = _parseFunction(
                                                    position: newPosition,
                                                    mode: mode );

                            } else {

                                throw new ParseError(
                                    message: 'Got function ' +
                                      arg.result.result.toString() +
                                      ' as argument to function ' +
                                      baseGroup.result.result.toString(),
                                    lexer: _lexer,
                                    position: arg.result.position - 1 );

                            }

                        } else {

                            argNode = arg.result;

                        }

                        args.add( argNode.result[ 0 ] );
                        positions.add( argNode.position );
                        newPosition = argNode.position;

                    }

                    args.add( positions );

                    resultFunc = functions[ funcList[ 0 ].type ];
                    result = Function.apply( resultFunc.handler, args );

                } else {

                    resultFunc = functions[ funcList[ 0 ].type ];
                    result = Function.apply( resultFunc.handler, funcList );

                }

                return new ParseResult(
                    result: [ new ParseNode(
                                        type: result[ 'type' ],
                                        value: result,
                                        mode: mode ) ],
                    position: newPosition );

            } else {

                return baseGroup.result;

            }

        } else {

            return null;

        }

  	}


    // TODO(adamjcook): Add method description.
  	ParseFuncOrArgument _parseGroup ( { num position, String mode } ) {

      Token start = _lexer.lex( position: position, mode: mode );

      // Try to parse an open brace
      if ( start.text == '{' ) {

          // If we get a brace, parse an expression
          ParseResult expression = _parseExpression(
                                            position: start.position,
                                            mode: mode,
                                            breakOnInfix: false,
                                            breakOnToken: '}' );

          // Make sure we get a close brace
          Token closeBrace = _lexer.lex( position: expression.position,
                                         mode: mode );
          _expect( result: closeBrace, expected: '}' );

          return new ParseFuncOrArgument(
              result: new ParseResult(
                  result: [ new ParseNode( type: 'ordgroup',
                                           value: expression.result,
                                           mode: mode ) ],
                  position: closeBrace.position ),
              isFunction: false);

      } else {

          // Otherwise, just return a nucleus
          return _parseSymbol( position: position, mode: mode );

      }

  	}


    // A [List] of the functions which change the size of the output.
    // This is for use in `_parseImplicitGroup` method.
    List<String> _sizeFuncs = [

        "\\tiny",
        "\\scriptsize",
        "\\footnotesize",
        "\\small",
        "\\normalsize",
        "\\large",
        "\\Large",
        "\\LARGE",
        "\\huge",
        "\\Huge"

    ];


    // A [List] of the functions which change the style of the output.
    // This is for use in the `_parseImplicitGroup` method.
    List<String> _styleFuncs = [

        "\\displaystyle",
        "\\textstyle",
        "\\scriptstyle",
        "\\scriptscriptstyle"

    ];


    // TODO(adamjcook): Add method description.
  	ParseResult _parseImplicitGroup ( { num position, String mode } ) {

        _logger.fine( '_parseImplicitGroup() method :: called' );

        ParseFuncOrArgument start = _parseSymbol(
                                            position: position,
                                            mode: mode );

        if ( start == null ) {

            _logger.fine(
                '_parseImplicitGroup() method, _parseSymbol returned : ' +
                'start returned is NULL' );

            // If we didn't get anything we handle, fall back to parseFunction
            return _parseFunction( position: position, mode: mode );

        }

        _logger.fine(
                '_parseImplicitGroup() method, _parseSymbol returned : ' +
                'start.result: ${ start.result } : ' +
                'start.isFunction: ${ start.isFunction } : ' +
                'start.isAllowedInText: ${ start.isAllowedInText } : ' +
                'start.numArgs: ${ start.numArgs } : ' +
                'start.argTypes: ${ start.argTypes }' );

        List<ParseNode> func = start.result.result;

        _logger.fine(
                '_parseImplicitGroup() method : ' +
                'start.result.result: ${ start.result.result }' );

        if ( func[ 0 ].value == '\\left' ) {

            // If we see a left:
            // Parse the entire left function (including the delimiter)
            ParseResult left = _parseFunction( position: position, mode: mode );

            // Parse out the implicit body
            ParseResult body = _parseExpression(
                                        position: left.position,
                                        mode: mode,
                                        breakOnInfix: false,
                                        breakOnToken: '}' );

            // Check the next token
            ParseFuncOrArgument rightLex = _parseSymbol(
                                                position: body.position,
                                                mode: mode );

            if ( rightLex != null &&
                 rightLex.result.result[ 0 ].value == '\\right' ) {

                // If it's a \right, parse the entire right function
                // (including the delimiter)
                ParseResult right = _parseFunction(
                                        position: body.position,
                                        mode: mode );

                return new ParseResult(
                    result: [ new ParseNode(
                                type: 'leftright',
                                value: {
                                    'body': body.result,
                                    'left': left.result[ 0 ].value,
                                    'right': right.result[ 0 ].value },
                                mode: mode ) ],
                    position: right.position );

            } else {

                throw new ParseError(
                              message: 'Missing \\right',
                              lexer: _lexer,
                              position: body.position );

            }

        } else if ( func[ 0 ].value == '\\right' ) {

            // If we see a right, explicitly fail the parsing here so the \left
            // handling ends the group
            return null;

        } else if ( _sizeFuncs.contains( func[ 0 ].value ) ) {

            // If we see a sizing function, parse out the implict body
            ParseResult body = _parseExpression(
                                          position: start.result.position,
                                          mode: mode,
                                          breakOnInfix: false,
                                          breakOnToken: '}' );

            return new ParseResult(
            // Figure out what size to use based on the list of functions above
            result: [ new ParseNode(
                            type: 'sizing',
                            value: {
                                'size': 'size' + ( _sizeFuncs.indexOf(
                                            func[ 0 ].value ) + 1 ).toString(),
                                'value': body.result },
                            mode: mode ) ],
            position: body.position );

        } else if ( _styleFuncs.contains( func[ 0 ].value ) ) {

            // If we see a styling function, parse out the implict body
            ParseResult body = _parseExpression(
                                    position: start.result.position,
                                    mode: mode,
                                    breakOnInfix: true,
                                    breakOnToken: '}' );

            return new ParseResult(
              // Figure out what style to use by pulling out the style from
              // the function name
              result: [ new ParseNode(
                                type: 'styling',
                                value: {
                                    'style': func[ 0 ]
                                                .value
                                                .substring( 1, func[ 0 ].value.length - 5 ),
                                    'value': body.result },
                               mode: mode ) ],
              position: body.position );

        } else {

            // Defer to parseFunction if it's not a function we handle
            return _parseFunction( position: position, mode: mode );

        }

  	}

  	// TODO(adamjcook): Add method description.
  	ParseResult _parseInput ( { num position, String mode } ) {

        _logger.fine( '_parseInput() method :: called' );

        // Parse an expression.
        ParseResult expression = _parseExpression(
                                                position: position,
                                                mode: mode,
                                                breakOnInfix: false,
                                                breakOnToken: null );

        _logger.fine(
            '_parseInput() method, _parseExpression returned :: ' +
            'expression.position: ${ expression.position }');

        Token EOF = _lexer.lex( position: expression.position, mode: mode );
        _expect( result: EOF, expected: 'EOF' );

        return expression;

  	}

    // TODO(adamjcook): Add method description.
    ParseFuncOrArgument _parseOptionalGroup ( { num position, String mode } ) {

      Token start = _lexer.lex( position: position, mode: mode );

      // Try to parse an open bracket
      if ( start.text == "[" ) {

        // If we get a brace, parse an expression
        var expression = _parseExpression(
                                    position: start.position,
                                    mode: mode,
                                    breakOnInfix: false,
                                    breakOnToken: ']' );

        // Make sure we get a close bracket
        var closeBracket = _lexer.lex( position: expression.position,
                                       mode: mode);

        _expect( result: closeBracket, expected: ']' );

        return new ParseFuncOrArgument(
            result: new ParseResult(
                result: [ new ParseNode( type: 'ordgroup',
                                         value: expression.result,
                                         mode: mode ) ],
                position: closeBracket.position ),
            isFunction: false );

      } else {

        return null;

      }

    }

    // TODO(adamjcook): Add method description.
  	ParseFuncOrArgument _parseSpecialGroup ( { num position,
                                               String mode,
                                               String outerMode,
                                               bool optional: false } ) {

        if ( mode == 'color' || mode == 'size' ) {

            // color and size modes are special because they should have braces and
            // should only lex a single symbol inside
            Token openBrace = _lexer.lex( position: position,
                                          mode: outerMode );
            if (optional && openBrace.text != '[' ) {
              // Optional arguments should return null if they do not exist.
              return null;
            }
            _expect( result: openBrace, expected: optional ? '[' : '{' );


            Token inner = _lexer.lex( position: openBrace.position,
                                      mode: mode);
            dynamic data;
            if ( mode == 'color' ) {
              data = inner.text;
            } else {
              data = inner.data;
            }

            Token closeBrace = _lexer.lex( position: inner.position,
                                           mode: outerMode );
            _expect( result: closeBrace, expected: optional ? ']' : '}' );

            return new ParseFuncOrArgument(
                result: new ParseResult(
                            result: [ new ParseNode( type: mode,
                                                     value: data,
                                                     mode: outerMode ) ],
                            position: closeBrace.position ),
                isFunction: false );

        } else if ( mode == 'text' ) {

            // text mode is special because it should ignore the whitespace before
            // it
            Token whitespace = _lexer.lex( position: position,
                                           mode: 'whitespace' );

            return _parseGroup( position: whitespace.position, mode: mode );

        } else {

            return _parseGroup( position: position, mode: mode );

        }

  	}


    // TODO(adamjcook): Add method description.
  	ParseFuncOrArgument _parseSymbol( { num position, String mode } ) {



  		Token nucleus = _lexer.lex( position: position, mode: mode );

        if ( functions[ nucleus.text ] != null ) {

            TexFunction texFunction = functions[ nucleus.text ];
            List<String> argTypes = texFunction.argTypes;

            if ( argTypes != null ) {

                for ( num i = 0; i < argTypes.length; i++ ) {

                    if ( argTypes[ i ] == 'original' ) {
                        argTypes[ i ] = mode;
                    }

                }

            }

            return new ParseFuncOrArgument(
                result: new ParseResult(
                    result: [ new ParseNode(
                                    type: nucleus.text,
                                    value: nucleus.text ) ],
                    position: nucleus.position ),
                isFunction: true,
                isAllowedInText: texFunction.allowedInText,
                numArgs: texFunction.numArgs,
                numOptionalArgs: texFunction.numOptionalArgs,
                argTypes: argTypes );

        } else if ( symbols[ mode ][ nucleus.text ] != null ) {

            // Otherwise if this is a no-argument function, find the type it
            // corresponds to in the symbols map
            return new ParseFuncOrArgument(
                result: new ParseResult(
                    result: [ new ParseNode(
                        type: symbols[ mode ][ nucleus.text ].group,
                        value: nucleus.text,
                        mode: mode ) ],
                    position: nucleus.position ),
                isFunction: false );

        } else {

            return null;

        }

  	}

  	// ===================== END PRIVATE METHODS =====================

  	// ===================== START PUBLIC METHODS =====================

  	// TODO(adamjcook): Add method description.
  	List<ParseNode> parse () {

        _logger.fine( 'parse() method :: called' );

        ParseResult parse = _parseInput( position: 0, mode: 'math' );

        _logger.fine(
            'parse() method, _parseInput returned :: ' +
            'parse.result: ${ parse.result }' );

        return parse.result;

  	}

  	// ===================== END PUBLIC METHODS =====================

}