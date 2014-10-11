// TODO(adamjcook): Add library description.
library katex.lexer;

import 'dart:core';

import 'package:logging/logging.dart';

import 'lex_result.dart';
import 'parse_error.dart';


final Logger _logger = new Logger( 'katex.lexer' );


// TODO(adamjcook): Add class description.
class Lexer {

    final bool loggingEnabled;
    final String expression;

    // The "normal" types of tokens. These are the tokens which can be matched 
    // by a simple regex, and have the type which is listed.
    Map<String, RegExp> _mathNormals = {

        'textord': new RegExp( r'^[/|@."`0-9]' ),
        'mathord': new RegExp( r'^[a-zA-Z]' ),
        'bin': new RegExp( r'^[*+-]' ),
        'rel': new RegExp( r'^[=<>:]' ),
        'punct': new RegExp( r'^[,;]' ),
        "'": new RegExp( r"^'/" ),
        '^': new RegExp( r'^\^' ),
        '_': new RegExp( r'^_' ),
        '{': new RegExp( r'^{' ),
        '}': new RegExp( r'^}' ),
        'open': new RegExp( r'^[(\[]' ),
        'close': new RegExp( r'^[)\]?!]' ),
        'spacing': new RegExp( r'^~' )

    };

    // These are "normal" tokens like above, but should instead be parsed in 
    // text mode.
    Map<String, RegExp> _textNormals = {

        'textord': new RegExp( '''^[a-zA-Z0-9`!@*()-=+\[\]'";:?\/.,]''' ),
        '{': new RegExp( r'^{' ),
        '}': new RegExp( r'^}' ),
        'spacing': new RegExp( r'^~' )
    };

    // Regexes for matching whitespace.
    RegExp _whitespaceRegex = new RegExp( r'^\s*', caseSensitive: true);
    RegExp _whitespaceConcatRegex = new RegExp( r'^( +|\\  +)', caseSensitive: true);
 
    // Regex to match any other TeX function, which is a backslash followed 
    // by a word or a single symbol.
    RegExp _anyFunc = new RegExp( r'^\\(?:[a-zA-Z]+|.)', caseSensitive: true );

    // Regex to match a CSS color (for example, #ffffff or BlueViolet).
    RegExp _cssColor = new RegExp( r'^(#[a-z0-9]+|[a-z]+)', caseSensitive: false );

    // Regex to match a dimension (for example, "1.2em" ".4pt" or "1 ex").
    RegExp _sizeRegex = new RegExp( r'^(\d+(?:\.\d*)?|\.\d+)\s*([a-z]{2})', 
        caseSensitive: true );

    Lexer( 
        { String expression: '', 
          bool loggingEnabled: false } )
    : this._init( 
        expression: expression,
        loggingEnabled: loggingEnabled );

    Lexer._init(
        { this.expression,
          this.loggingEnabled } ) {
        if ( this.loggingEnabled == true ) {
          Logger.root.level = Level.ALL;
          Logger.root.onRecord.listen(( LogRecord rec ) {
            print( '${rec.level.name}: ${rec.time}: ${rec.message}' );
          });
        }

    }

    // ===================== START PRIVATE METHODS =====================
    
    // TODO(adamjcook): Add method description.
    LexResult _innerLex ( { int position,
                            Map<String, RegExp> normals,
                            bool ignoreWhitespace } ) {

        String input = expression.substring( position );

        if ( ignoreWhitespace ) {

            // Discard whitespace.
            Match whitespace = _whitespaceRegex.firstMatch( input );
            position += whitespace.group(0).length;
            input = input.substring( whitespace.group(0).length );

        } else {

            Match whitespace = _whitespaceConcatRegex.firstMatch( input );

            if ( whitespace != null ) {

                return new LexResult(
                                type: ' ',
                                text: ' ', 
                                position: position + whitespace.group(0).length );
            }

        }

        // If the input (expression) has been completely parsed, return an
        // EOF token.
        if ( input.isEmpty ) {

            return new LexResult(
                            type: 'EOF', 
                            text: null, 
                            position: position );

        }

        Match match = _anyFunc.firstMatch( input );
        Match actualMatch = null;
        String matchedToken;

        if ( match != null ) {

            // Function token matched, return result.
            return new LexResult(
                            type: match.group(0), 
                            text: match.group(0),
                            position: position + match.group(0).length );

        } else {

            // No function token was matched, loop through the normal token
            // regular expressions for a match, if any.
            normals.forEach( ( token, regexp ) {

                match = regexp.firstMatch( input );

                if ( match != null ) {

                    actualMatch = match;
                    matchedToken = token;
                }

            } );

        }

        if ( actualMatch != null ) {

            return new LexResult(
                            type: matchedToken, 
                            text: actualMatch.group(0),
                            position: position + actualMatch.group(0).length );

        } else {

            // TODO(adamjcook): Add `lexer` and `positon` arguments to ParseError implementation.
            throw new ParseError( 'Unexpected character' );

        }

    }

    // TODO(adamjcook): Add method description.
    LexResult _innerLexColor ( { int position } ) {

        String input = expression.substring( position );

        // Ignore whitespace.
        Match whitespace = _whitespaceRegex.firstMatch( input );
        position = position + whitespace.group(0).length;
        input = input.substring( whitespace.group(0).length );

        Match match = _cssColor.firstMatch( input );
        if ( match != null ) {

            // Color match found.
            return new LexResult(
                            type: 'color',
                            text: match.group(0),
                            position: position + match.group(0).length );

        } else {

            // TODO(adamjcook): Add `lexer` and `positon` arguments to ParseError implementation.
            throw new ParseError( 'Invalid color' );

        }

    }

    // TODO(adamjcook): Add method description.
    LexResult _innerLexSize ( { int position } ) {

        String input = expression.substring( position );

        // Ignore whitespace.
        Match whitespace = _whitespaceRegex.firstMatch( input );
        position = position + whitespace.group(0).length;
        input = input.substring( whitespace.group(0).length );

        Match match = _sizeRegex.firstMatch( input );

        if ( match != null ) {

            // Get dimension unit.
            var unit = match.group(2);
            // Only 'em' and 'ex' units are supported.
            if ( unit != 'em' && unit != 'ex' ) {

                throw new ParseError( 'Invalid unit' );

            }

            // TODO(adamjcook): Lexer.js has a complex object for `text` not just a String like here. Change?
            return new LexResult(
                            type: 'size',
                            text: match.group(1) + unit,
                            position: position + match.group(0).length );

        }

        throw new ParseError( 'Invalid size' );

    }

    // TODO(adamjcook): Add method description.
    LexResult _innerLexWhitespace ( { int position } ) {

        String input = expression.substring( position );

        Match whitespace = _whitespaceRegex.firstMatch( input );
        position = position + whitespace.group(0).length;

        return new LexResult(
                        type: 'whitespace',
                        text: whitespace.group(0),
                        position: position );

    }

    // ===================== END PRIVATE METHODS =====================
    
    // ===================== START PUBLIC METHODS =====================
    
    // TODO(adamjcook): Add method description.
    LexResult lex ( { int position, String mode } ) {

      LexResult returnValue;

        if ( mode == 'math' ) {

            returnValue = _innerLex(
                                position: position,
                                normals: _mathNormals,
                                ignoreWhitespace: true );

        } else if ( mode == 'text' ) {

            returnValue = _innerLex(
                                position: position,
                                normals: _textNormals,
                                ignoreWhitespace: false );

        } else if ( mode == 'color' ) {

            returnValue = _innerLexColor( position: position );

        } else if ( mode == 'size' ) {

            returnValue = _innerLexSize( position: position );

        } else if ( mode == 'whitespace' ) {

            returnValue = _innerLexWhitespace( position: position );
        
        }

      return returnValue;

    }

    // ===================== END PUBLIC METHODS =====================

}