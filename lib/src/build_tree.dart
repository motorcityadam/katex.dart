// TODO(adamjcook): Add library description.
library katex.build_tree;

import 'build_common.dart' as buildCommon;
import 'dom_node.dart';
import 'options.dart';
import 'parse_error.dart';
import 'parse_node.dart';
import 'tex_group.dart';
import 'styles.dart' as styles;


/**
 * Take a list of nodes, build them in order, and return a list of the built
 * nodes. This function handles the `prev` node correctly, and passes the
 * previous element from the list as the prev of the next element.
 */
List<DomNode> buildExpression ( { List<ParseNode> expression,
                                  Options options,
                                  ParseNode prev } ) {

    List<DomNode> groups = [];

    for ( num i = 0; i < expression.length; i++ ) {

        ParseNode group = expression[ i ];

        groups.add( buildGroup( group: group,
                                options: options,
                                prev: prev ) );

        prev = group;

    }

    return groups;

}

// List of types used by getTypeOfGroup.
Map<String, String> groupToType = {

    'mathord': 'mord',
    'textord': 'mord',
    'bin': 'mbin',
    'rel': 'mrel',
    'text': 'mord',
    'open': 'mopen',
    'close': 'mclose',
    'inner': 'minner',
    'frac': 'minner',
    'spacing': 'mord',
    'punct': 'mpunct',
    'ordgroup': 'mord',
    'op': 'mop',
    'katex': 'mord',
    'overline': 'mord',
    'rule': 'mord',
    'leftright': 'minner',
    'sqrt': 'mord',
    'accent': 'mord'

};

/**
 * Gets the final math type of an expression, given its group type. This type is
 * used to determine spacing between elements, and affects bin elements by
 * causing them to change depending on what types are around them. This type
 * must be attached to the outermost node of an element as a CSS class so that
 * spacing with its surrounding elements works correctly.
 *
 * Some elements can be mapped one-to-one from group type to math type, and
 * those are listed in the `groupToType` table.
 *
 * Others (usually elements that wrap around other elements) often have
 * recursive definitions, and thus call `getTypeOfGroup` on their inner
 * elements.
 */
String getTypeOfGroup ( { ParseNode group } ) {

    String returnValue;

    if ( group == null ) {

        // Like when typesetting $^3$
        returnValue = groupToType[ 'mathord' ];

    } else if ( group.type == 'supsub' ) {

        returnValue = getTypeOfGroup( group: group.value[ 'base' ] );

    } else if ( group.type == 'llap' || group.type == 'rlap' ) {

        returnValue = getTypeOfGroup( group: group.value );

    } else if ( group.type == 'color' ) {

        returnValue = getTypeOfGroup( group: group.value.value );

    } else if ( group.type == 'sizing' ) {

        returnValue = getTypeOfGroup( group: group.value.value );

    } else if ( group.type == 'styling' ) {

        returnValue = getTypeOfGroup( group: group.value.value );

    } else if ( group.type == 'delimsizing' ) {

        returnValue = groupToType[ group.value.delimType ];

    } else {

        returnValue = groupToType[ group.type ];

    }

    return returnValue;

}

/**
 * Sometimes we want to pull out the innermost element of a group. In most
 * cases, this will just be the group itself, but when ordgroups and colors have
 * a single element, we want to pull that out.
 */
ParseNode getBaseElem ( { ParseNode group } ) {

    if ( group == null ) {

        return null;

    } else if ( group.type == 'ordgroup' ) {

        if ( group.value.length == 1 ) {

            return getBaseElem( group: group.value[ 0 ] );

        } else {

            return group;

        }

    } else if ( group.type == 'color' ) {

        if ( group.value.value.length == 1 ) {

            return getBaseElem( group: group.value.value[ 0 ] );

        } else {

            return group;

        }

    } else {

        return group;

    }

}

Map<String, num> sizingMultiplier = {

    'size1': 0.5,
    'size2': 0.7,
    'size3': 0.8,
    'size4': 0.9,
    'size5': 1.0,
    'size6': 1.2,
    'size7': 1.44,
    'size8': 1.73,
    'size9': 2.07,
    'size10': 2.49

};

/**
 * buildGroup is the function that takes a group and calls the correct groupType
 * function for it. It also handles the interaction of size and style changes
 * between parents and children.
 */
DomNode buildGroup ( { ParseNode group, Options options, ParseNode prev } ) {

    if ( group == null ) {

        return buildCommon.makeSpan();

    }

    if ( groupToType.containsKey( group.type ) != null ) {

        // Call the groupTypes function
        TexGroup groupNode = new TexGroup(
                                    type: group.type,
                                    group: group,
                                    options: options,
                                    prev: prev );

        // If the style changed between the parent and the current group,
        // account for the size difference
        if ( options.style != options.parentStyle ) {
            num multiplier = options.style.sizeMultiplier /
                    options.parentStyle.sizeMultiplier;

            groupNode.value.height *= multiplier;
            groupNode.value.depth *= multiplier;

        }

        // If the size changed between the parent and the current group, account
        // for that size difference.
        if ( options.size != options.parentSize ) {
            num multiplier = sizingMultiplier[ options.size ] /
                    sizingMultiplier[ options.parentSize ];

            groupNode.value.height *= multiplier;
            groupNode.value.depth *= multiplier;

        }

        return groupNode.value; // DomNode

    } else {

        throw new ParseError(
                    message: 'Recieved group of unknown type: ' + group.type );

    }
}

/**
 * Take an entire parse tree, and build it into an appropriate set of nodes.
 */
SpanNode buildTree ( { List<ParseNode> tree } ) {

    // Setup the default options
    Options options = new Options( style: styles.TEXT,
                                   color: '',
                                   size: 'size5' );

    // Build the expression contained in the tree
    List<DomNode> expression = buildExpression( expression: tree,
                                                options: options );

    SpanNode body = buildCommon.makeSpan(
        classes: [ 'base', options.style.HtmlClassName() ],
        children: expression );

    // Add struts, which ensure that the top of the HTML element falls at the
    // height of the expression, and the bottom of the HTML element falls at the
    // depth of the expression.
    SpanNode topStrut = buildCommon.makeSpan( classes: [ 'strut' ] );
    SpanNode bottomStrut = buildCommon.makeSpan( classes: [ 'strut', 'bottom' ] );

    topStrut.styles[ 'height' ] = body.height.toString() + 'em';
    bottomStrut.styles[ 'height' ] =
        ( body.height + body.depth ).toString() + 'em';

    // We'd like to use `vertical-align: top` but in IE 9 this lowers the
    // baseline of the box to the bottom of this strut (instead staying in the
    // normal place) so we use an absolute value for vertical-align instead
    bottomStrut.styles[ 'vertical-align' ] = ( -body.depth ).toString() + 'em';

    // Wrap the struts and body together
    SpanNode katexNode = buildCommon.makeSpan(
        classes: [ 'katex' ],
        children: [ buildCommon.makeSpan( classes: [ 'katex-inner' ],
                                          children: [ topStrut,
                                                      bottomStrut,
                                                      body ] ) ]
        );

    return katexNode;

}