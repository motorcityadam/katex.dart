/**
 * These classes store the data about the DOM nodes that are created,
 * as well as, some extra data in the form of class properties. 
 * These objects can then be transformed into real Dart-native [Elements] 
 * toNode() method or to a HTML markup [String] representation via the
 * toMarkup() method on each class.
 */

// TODO(adamjcook): Polymer implementation to extend Dart HTML classes?
library katex.dom_tree;

import 'dart:html' show SpanElement, DocumentFragment;


// TODO(adamjcook): Abstract class?
class DomNode {

	DomNode() {}

}

/**
 * A [SpanNode] represents a [SpanElement], with a class name, a list of 
 * children, and any inline styles. It also contains information about its 
 * height, depth, and maxFontSize.
 */
 // TODO(adamjcook): Height, depth and maxFontSize should be final?
class SpanNode extends DomNode {

	final List<String> classes;
	final List<DomNode> children;
	num height;
	num depth;
	num width; // TODO(adamjcook): `width` property? See build_tree.dart for usage.
	num maxFontSize;

	Map<String, String> styles = {};

	SpanNode( 
		{ List<String> classes: null,
		  List<DomNode> children: null,
		  num height: 0.0,
		  num depth: 0.0,
		  num maxFontSize: 0 } )
	: this._init( 
		classes: classes,
		children: children,
		height: height,
		depth: depth,
		maxFontSize: maxFontSize );

	SpanNode._init(
		{ this.classes,
		  this.children,
		  this.height,
		  this.depth,
		  this.maxFontSize } ) {}

	/**
	 * Convert the [SpanNode] into a [SpanElement].
	 */ 
	SpanElement toNode () {

		SpanElement span = new SpanElement();

		// Apply classes to `span` element.
		if ( classes != null ) {

			if ( classes.length > 0 ) {

				span.classes.addAll( classes );

			}

		}

		// Apply inline styles to `span` element.
		styles.forEach( ( propery, value ) {

			span.style.setProperty( propery, value );

		});

		// TODO(adamjcook): Check for null hackish?
		if ( children != null ) { 

			// Append any children as HTML nodes.
			children.forEach( ( child ) {

				span.append( child.toNode() );

			});

		}

		return span;

	}

	/**
 	 * Convert the [SpanNode] into an HTML markup [String].
 	 */
	String toMarkup() {

		return this.toNode().outerHtml;

	}

}

/**
 * A [DocumentFragmentNode] represents a [DocumentFragment], which contains 
 * [Elements], but when it is placed into the DOM it does not have any 
 * representation itself. Therefore, it only contains children and does not 
 * have any HTML properties. It also stores information about a height, depth, 
 * and maxFontSize.
 */
class DocumentFragmentNode extends DomNode {

	final List<DomNode> children;
	final num height;
	final num depth;
	final num maxFontSize;

	DocumentFragmentNode( 
		{ List<DomNode> children: null,
		  num height: 0.0,
		  num depth: 0.0,
		  num maxFontSize: 0 } )
	: this._init( 
		children: children,
		height: height,
		depth: depth,
		maxFontSize: maxFontSize );

	DocumentFragmentNode._init(
		{ this.children,
		  this.height,
		  this.depth,
		  this.maxFontSize } ) { }

	/**
	 * Convert the [DocumentFragmentNode] into an [DocumentFragment].
	 * The [DocumentFragment] class is Dart-native.
	 */ 
	DocumentFragment toNode () {

		DocumentFragment documentFragment = new DocumentFragment();

		// Append any children as HTML nodes.
		children.forEach( ( child ) {

			documentFragment.append( child.toNode() );

		});

		return documentFragment;

	}

	/**
 	 * Convert the [DocumentFragmentNode] into HTML markup [String].
     */
	String toMarkup() {

		String markup;

		children.forEach( ( child ) {

			markup += child.toMarkup();

		});

		return markup;

	}

}

/**
 * A [SymbolNode] contains information about a single symbol. It renders
 * to a [SpanElement] with a text node within it. Any CSS classes, styles, or 
 * italic corrections are applied.
 */
  // TODO(adamjcook): italic, height, depth and maxFontSize properties should be final?
class SymbolNode extends DomNode {

	final String value;
	num height;
	num depth;
	num italic;
	final num skew;
	final List<String> classes;
	num maxFontSize;

	Map<String, String> styles = {};

	SymbolNode( 
		{ String value: '',
		  num height: 0.0,
		  num depth: 0.0,
		  num italic: 0.0,
		  num skew: 0.0,
		  List<String> classes: null,
		  num maxFontSize: 0 } )
	: this._init( 
		value: value,
		height: height,
		depth: depth,
		italic: italic,
		skew: skew,
		classes: classes,
		maxFontSize: maxFontSize );

	SymbolNode._init(
		{ this.value,
		  this.height,
		  this.depth,
		  this.italic,
		  this.skew,
		  this.classes,
		  this.maxFontSize } ) { }


	/**
	 * Creates a [SpanElement] from a [SymbolNode].
	 */
 	SpanElement toNode () {

	    SpanElement span = new SpanElement();

	    if ( italic > 0 ) {

	        span.style.marginRight = italic.toString() + 'em';

	    }

	    if ( classes != null ) {

	    	// Apply inline styles to [SpanElement].
	    	if ( classes.length > 0 ) {

	    		span.classes.addAll( classes );

	    	}

	    }

	    // Apply inline styles to [SpanElement].
		styles.forEach( ( propery, value ) {

			span.style.setProperty( propery, value );

		});
	    
	    // Append text to [SpanElement].
	    span.appendText( value );

	    return span;

	}

	/**
 	 * Convert the [SymbolElement] into an HTML markup [String].
 	 */
	String toMarkup() {

		return this.toNode().outerHtml;

	}

}