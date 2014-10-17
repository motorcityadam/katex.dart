// TODO(adamjcook): Add library description.
library katex.lexer;

import 'dart:core';

import 'package:logging/logging.dart';

import 'parse_error.dart';
import 'token.dart';


final Logger _logger = new Logger( 'katex.lexer' );

// TODO(adamjcook): Add class description.
class Lexer {

    final bool loggingEnabled;
    final String expression;

    // The "normal" types of tokens. These are the tokens which can be matched
    // by a simple regex.
    List<RegExp> _mathNormals = [

        new RegExp( r'^[/|@.""`0-9a-zA-Z]' ), // ords
        new RegExp( r'^[*+-]' ),    // bins
        new RegExp( r'^[=<>:]' ),   // rels
        new RegExp( r'^[,;]' ),     // punctuation
        new RegExp( r"^['\^_{}]" ), // misc
        new RegExp( r'^[(\[]' ),    // opens
        new RegExp( r'^[)\]?!]' ),  // closes
        new RegExp( r'^~' )         // spacing

    ];

    // These are "normal" tokens like above, but should instead be parsed in
    // text mode.
    List<RegExp> _textNormals = [

        new RegExp( r'^[a-zA-Z0-9`!@*()-=+\[\]";:?\/.,]' ), // ords
        new RegExp( r'^[{}]' ), // grouping
        new RegExp( r'^~' ) // spacing

    ];

    // Regular expressions for matching whitespace.
    RegExp _whitespaceRegex = new RegExp( r'^\s*', caseSensitive: true);
    RegExp _whitespaceConcatRegex = new RegExp( r'^( +|\\  +)', caseSensitive: true);

    // Regular expression to match any other TeX function, which is a backslash
    // followed by a word or a single symbol.
    RegExp _anyFunc = new RegExp( r'^\\(?:[a-zA-Z]+|.)', caseSensitive: true );

    // Regular expression to match a CSS color (for example, #ffffff or BlueViolet).
    RegExp _cssColor = new RegExp( r'^(#[a-z0-9]+|[a-z]+)', caseSensitive: false );

    // Regular expression to match a dimension (for example, "1.2em" ".4pt" or
    // "1 ex").
    RegExp _sizeRegex = new RegExp( r'^(-?)\s*(\d+(?:\.\d*)?|\.\d+)\s*([a-z]{2})',
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
            print( '${rec.level.name}: ${rec.time}: ${rec.loggerName}: ${rec.message}' );
          });
        }

        _logger.fine( 'Lexer init :: with expression: ${ this.expression }');

    }

    // ===================== START PRIVATE METHODS =====================

    // TODO(adamjcook): Add method description.
    Token _innerLex ( { int position,
                            List<RegExp> normals,
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

              return new Token(
                          text: ' ',
                          data: null,
                          position: position + whitespace.group(0).length );

            }

        }

        // If the input (expression) has been completely parsed, return an
        // EOF token.
        if ( input.isEmpty ) {

            return new Token(
                            text: 'EOF',
                            data: null,
                            position: position );

        }

        Match match = _anyFunc.firstMatch( input );

        if ( match != null ) {

            // Function token matched, return result.
            return new Token(
                            text: match.group(0),
                            data: null,
                            position: position + match.group(0).length );

        } else {

          // No function token was matched, loop through the normal token
          // regular expressions for a match, if any.

          for ( num i = 0; i < normals.length; i++ ) {

            RegExp normal = normals[ i ];

            match = normal.firstMatch( input );

            if ( match != null ) {

              return new Token(
                            text: match.group(0),
                            data: null,
                            position: position + match.group(0).length );

            }

          }

        }

        throw new ParseError( 'Unexpected character' );

    }

    // TODO(adamjcook): Add method description.
    Token _innerLexColor ( { int position } ) {

        String input = expression.substring( position );

        // Ignore whitespace.
        Match whitespace = _whitespaceRegex.firstMatch( input );
        position = position + whitespace.group(0).length;
        input = input.substring( whitespace.group(0).length );

        Match match = _cssColor.firstMatch( input );
        if ( match != null ) {
            // Color match found.
            return new Token(
                            text: match.group(0),
                            data: null,
                            position: position + match.group(0).length );
        } else {
            throw new ParseError( 'Invalid color' );
        }

    }

    // TODO(adamjcook): Add method description.
    Token _innerLexSize ( { int position } ) {

        String input = expression.substring( position );

        // Ignore whitespace.
        Match whitespace = _whitespaceRegex.firstMatch( input );
        position = position + whitespace.group(0).length;
        input = input.substring( whitespace.group(0).length );

        Match match = _sizeRegex.firstMatch( input );

        if ( match != null ) {

            // Get dimension unit.
            var unit = match.group(3);
            // Only 'em' and 'ex' units are supported.
            if ( unit != 'em' && unit != 'ex' ) {

                throw new ParseError( 'Invalid unit' );

            }

            // TODO(adamjcook): Lexer.js has a complex object for `text` not just a String like here. Change?
            return new Token(
                          text: match.group(0),
                          data: {
                              'number': match.group(1) + match.group(2),
                              'unit': unit },
                          position: position + match.group(0).length );

        }

        throw new ParseError( 'Invalid size' );

    }

    // TODO(adamjcook): Add method description.
    Token _innerLexWhitespace ( { int position } ) {

        String input = expression.substring( position );

        Match whitespace = _whitespaceRegex.firstMatch( input );
        position = position + whitespace.group(0).length;

        return new Token(
                      text: whitespace.group(0),
                      data: null,
                      position: position );

    }

    // ===================== END PRIVATE METHODS =====================

    // ===================== START PUBLIC METHODS =====================

    // TODO(adamjcook): Add method description.
    Token lex ( { int position, String mode } ) {

        if ( mode == 'math' ) {

            return _innerLex(
                        position: position,
                        normals: _mathNormals,
                        ignoreWhitespace: true );

        } else if ( mode == 'text' ) {

            return _innerLex(
                        position: position,
                        normals: _textNormals,
                        ignoreWhitespace: false );

        } else if ( mode == 'color' ) {

            return _innerLexColor( position: position );

        } else if ( mode == 'size' ) {

            return _innerLexSize( position: position );

        } else if ( mode == 'whitespace' ) {

            return _innerLexWhitespace( position: position );

        }

    }

    // ===================== END PUBLIC METHODS =====================

}