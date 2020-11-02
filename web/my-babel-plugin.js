module.exports = function ({ types: t }) {
    return {
        visitor: {
            ExpressionStatement(path) {
                expression = path.node.expression;
                if (t.isJSXElement(expression)) {

                    open_elem = expression.openingElement
                    if (open_elem.name.name !== "Declaration") {
                        return;
                    }
                    attributes = expression.openingElement.attributes
                    if (attributes.length !== 2) {
                        return;
                    }
                    ident = attributes[0].name.name //var
                    var_name = attributes[0].value.value //test
                    value = t.nullLiteral() //42
                    if (attributes[1].value.value !== undefined) {
                        value = t.stringLiteral(attributes[1].value.value)
                    }
                    
                    else if (attributes[1].value.expression.value !== undefined) {
                        value = t.numericLiteral(attributes[1].value.expression.value)
                    }

                    console.log("final value is", value)
                    path.replaceWith(t.variableDeclaration(ident, [t.variableDeclarator(t.identifier(var_name), value)]));
                }
            },
        }
    };
}