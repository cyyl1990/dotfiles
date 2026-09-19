import QtQuick 2.15

Item {
    Component.onCompleted: {
        console.log("Tokens: " + JSON.stringify(Object.keys(root.tokens)))
    }
}
