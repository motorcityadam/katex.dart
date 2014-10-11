// TODO(adamjcook): Add library description.
library katex.build_common;

import 'dart:html';
import 'dart:math' as Math;

import 'dom_node.dart';
import 'font_metrics.dart' as fontMetrics;
import 'options.dart';
import 'symbols.dart';


/**
 * Creates a [SymbolNode] after translation via the [List] of symbols in found
 * in katex.symbols library. Correctly extracts the metrics for the character, 
 * and optionally, takes a [List] of classes to be attached to the node.
 */
SymbolNode makeSymbol ( { String value, String style, String mode,
                          String color, List<String> classes } ) {

    SymbolNode symbolNode;

    // Replace the value with its replaced value from symbol.js
    if ( symbols[ mode ][ value ] != null && 
         symbols[mode][value].replace != '' ) {

        value = symbols[ mode ][ value ].replace;

    }

    Map<String, num> metrics = fontMetrics.getCharacterMetrics(
                                    character: value,
                                    style: style );

    if ( metrics != null ) {

        symbolNode = new SymbolNode(
                                value: value,
                                height: metrics[ 'height' ],
                                depth: metrics[ 'depth' ],
                                italic: metrics[ 'italic' ],
                                skew: metrics[ 'skew' ],
                                classes: classes );

    } else {

        // TODO(adamjcook): Use pub `logging` package to print this to the console.
         window.console.error(
            'No character metrics for ' + value + ' in style ' + style );

        symbolNode = new SymbolNode(
                                value: value,
                                height: 0.0,
                                depth: 0.0,
                                italic: 0.0,
                                skew: 0.0,
                                classes: classes );

    }

    if ( color != null ) {
        symbolNode.styles[ 'color' ] = color;
    }

    return symbolNode;

}

/**
 * Returns a [SymbolNode] using the italic math font.
 */
SymbolNode makeSymbolItalic ( { String value, String mode, 
                                String color, List<String> classes } ) {

    classes.add( 'mathit' );

    return makeSymbol( value: value,
                       style: 'Math-Italic',
                       mode: mode,
                       color: color,
                       classes: classes );

}

/**
 * Returns a [SymbolNode] in the upright roman font.
 */
SymbolNode makeSymbolRoman ( { String value, String mode,
                               String color, List<String> classes } ) {

    // Decide what font to render the symbol in by its entry in the symbols
    // table.
    if (symbols[ mode ][ value ].font == 'main') {

        return makeSymbol( value: value,
                           style: 'Main-Regular',
                           mode: mode,
                           color: color,
                           classes: classes);

    } else {

        classes.add( 'amsrm' );

        return makeSymbol( value: value,
                           style: 'AMS-Regular',
                           mode: mode,
                           color: color,
                           classes: classes );

    }

}

/**
 * Calculate the height, depth, and maxFontSize of an element based on its
 * children.
 */
void sizeElementFromChildren ( DomNode domNode ) {

    num height = 0;
    num depth = 0;
    num maxFontSize = 0;

    if ( domNode.children != null ) {

        for ( num i = 0; i < domNode.children.length; i++ ) {

            if ( domNode.children[ i ].height > height ) {
                height = domNode.children[ i ].height;
            }

            if ( domNode.children[ i ].depth > depth ) {
                depth = domNode.children[ i ].depth;
            }

            if ( domNode.children[ i ].maxFontSize > maxFontSize ) {
                maxFontSize = domNode.children[ i ].maxFontSize;
            }

        }

    }

    domNode.height = height;
    domNode.depth = depth;
    domNode.maxFontSize = maxFontSize;

}

/**
 * Returns a [SpanNode] with the given list of classes, list of children, and
 * a color attached.
 */
SpanNode makeSpan ( { List<String> classes, List<DomNode> children,
                      String color } ) {

    SpanNode spanNode = new SpanNode( classes: classes,
                                      children: children );

    sizeElementFromChildren( spanNode );

    if ( color != null ) {
        spanNode.styles[ 'color' ] = color;
    }

    return spanNode;

}

/**
 * Returns a [DocumentFragmentNode] containing the provided list of [DomNode] 
 * children.
 */
DocumentFragmentNode makeFragment ( { List<DomNode> children } ) {

    DocumentFragmentNode documentFragmentNode = 
        new DocumentFragmentNode( children: children );

    sizeElementFromChildren( documentFragmentNode );

    return documentFragmentNode;

}

/**
 * Creates a zero-width space [SpanNode] with the correct font size to ensure
 * that each element has the same maximum font size. This element is placed in
 * each of the vertical list elements. Returns a [SpanNode].
 */
SpanNode makeFontSizer ( { Options options, num fontSize } ) {

    SpanNode fontSizeInner = makeSpan(
        classes: null,
        children: [ new SymbolNode( value: '\u200b' ) ] );

    fontSizeInner.styles[ 'fontSize' ] =
        ( fontSize / options.style.sizeMultiplier ).toString() + 'em';

    SpanNode fontSizer = makeSpan(
        classes: [ 'fontsize-ensurer', 'reset-' + options.size, 'size5' ],
        children: [ fontSizeInner ] );

    return fontSizer;

}

/**
 * Creates a vertical list [SpanNode] by stacking other [SpanNode] elements 
 * and kerns on top of each other. Allows for many different schemes of 
 * specifying the positioning method.
 *
 * Arguments:
 * 
 *  - children: A list of child or kern nodes to be stacked on top of each other
 *              (i.e. the first element will be at the bottom, and the last at
 *              the top). Element nodes are specified as
 *                { 'type': 'elem', 'elem': node }
 *              while kern nodes are specified as
 *                { 'type': 'kern', 'size': size }
 * 
 *  - positionType: The method by which the vertical list should be positioned.
 *                  Valid values are:
 *                   - 'individualShift': The children list only contains elem
 *                                        nodes, and each node contains an extra
 *                                        'shift' value of how much it should be
 *                                        shifted (note that shifting is always
 *                                        moving downwards). positionData is
 *                                        ignored.
 *                   - 'top': The positionData specifies the topmost point of
 *                            the vertical list (note this is expected to be a 
 *                            height, so positive values will move up)
 *                   - 'bottom': The positionData specifies the bottommost point
 *                               of the vertical list (note this is expected to
 *                               be a depth, so positive values will move down.
 *                   - 'shift': The vertical list will be positioned such that
 *                              its baseline is positionData away from the 
 *                              baseline of the first child. Positive values 
 *                              move downwards.
 *                   - 'firstBaseline': The vertical list will be positioned 
 *                                      such that its baseline is aligned with
 *                                      the baseline of the first child.
 *                                      positionData is ignored. (this is
 *                                      equivalent to 'shift' with
 *                                      positionData=0)
 * 
 *  - positionData: Data used in different ways depending on the value of 
 *                  positionType.
 * 
 *  - options: [Options] object.
 *
 */
 // TODO(adamjcook): Refactor this - especially the type associated with the `children` argument. Messy for Dart.
SpanNode makeVerticalList ( { List<Map<String, dynamic>> children,
                              String positionType, 
                              num positionData,
                              Options options } ) {

    num depth;

    if ( positionType == 'individualShift' ) {

        List<Map<String, dynamic>> oldChildren = children;
        children = [ oldChildren[ 0 ] ];

        // Add in the kerns to the list of children to get each element to be
        // shifted to the correct specified shift.
        depth = -oldChildren[ 0 ][ 'shift' ] - oldChildren[ 0 ][ 'elem' ].depth;
        num currentPosition = depth;

        for ( num i = 1; i < oldChildren.length; i++ ) {

            num diff = -oldChildren[ i ][ 'shift' ] - currentPosition -
                oldChildren[ i ][ 'elem' ].depth;

            num size = diff -
                ( oldChildren[ i - 1 ][ 'elem' ].height +
                  oldChildren[ i - 1 ][ 'elem' ].depth );

            currentPosition = currentPosition + diff;

            children.add( { 'type': 'kern', 'size': size } );

            children.add( oldChildren[ i ] );

        }

    } else if (positionType == 'top') {

        // Starting from the bottom, compute the bottom by adding up all of the
        // sizes.
        num bottom = positionData;

        for ( num i = 0; i < children.length; i++ ) {

            if (children[ i ][ 'type' ] == 'kern') {
                bottom -= children[ i ][ 'size' ];
            } else {
                bottom -= children[ i ][ 'elem' ].height + 
                    children[ i ][ 'elem' ].depth;
            }

        }

        depth = bottom;

    } else if ( positionType == 'bottom' ) {

        depth = -positionData;

    } else if ( positionType == 'shift' ) {

        depth = -children[ 0 ][ 'elem' ].depth - positionData;

    } else if ( positionType == 'firstBaseline' ) {

        depth = -children[ 0 ][ 'elem' ].depth;

    } else {

        depth = 0;

    }

    // Create the fontSizer [SpanNode] element.
    num maxFontSize = 0;
    for ( var i = 0; i < children.length; i++ ) {

        if ( children[ i ][ 'type' ] == 'elem' ) {

            maxFontSize = Math.max( maxFontSize,
                                    children[ i ][ 'elem' ].maxFontSize );

        }

    }

    SpanNode fontSizer = makeFontSizer( options: options,
                                        fontSize: maxFontSize );

    // Create a new list of actual [SpanNode] children at the correct offsets.
    List<SpanNode> realChildren = [];
    var currentPosition = depth;

    for ( var i = 0; i < children.length; i++ ) {

        if ( children[ i ][ 'type' ] == 'kern' ) {

            currentPosition += children[ i ][ 'size' ];

        } else {

            SpanNode child = children[ i ][ 'elem' ];

            num shift = -child.depth - currentPosition;
            currentPosition += child.height + child.depth;

            SpanNode childWrap = makeSpan( classes: [],
                                           children: [ fontSizer, child ] );

            childWrap.height -= shift;
            childWrap.depth += shift;
            childWrap.styles[ 'top' ] = shift.toString() + 'em';

            realChildren.add( childWrap );

        }

    }

    // Add in an [SpanNode] element at the end with no offset to fix the 
    // calculation of baselines in some browsers (for example, IE and Safari).
    SpanNode baselineFix = makeSpan( classes: [ 'baseline-fix' ],
                                     children: [ fontSizer,
                                                 new SymbolNode( value: '\u200b' ) ] );
    realChildren.add( baselineFix );

    SpanNode verticalListSpan = makeSpan( classes: [ 'vlist' ],
                                          children: realChildren );

    // Fix the final height and depth, in the case that there were kerns at
    // the either of the ends. The makeSpan function will not take this into
    // account so the adjustment is computed here.
    verticalListSpan.height = 
        Math.max( currentPosition, verticalListSpan.height );

    verticalListSpan.depth =
        Math.max( -depth, verticalListSpan.depth );

    return verticalListSpan;

}