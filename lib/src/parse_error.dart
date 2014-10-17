// TODO(adamjcook): Add library description.
library katex.parse_error;

import 'dart:math' as Math;

import 'lexer.dart';


// TODO(adamjcook): Add class description.
class ParseError implements Exception {

	final String message;
  final Lexer lexer;
  final int position;

  String output;

	ParseError( { this.message: '',
                this.lexer: null,
                this.position: null } ) : super() {

    output = "katex ParseError :: " + message;

    if( lexer != null && position != null && position >= 0 ) {

      output += " at position " + position.toString() + ": ";

      // Get the input
      String expression = lexer.expression;
      // Insert a combining underscore at the correct position
      expression = expression.substring( 0, position ) + "\u0332" +
      expression.substring( position );

    }

  }

	String toString() => output;

}