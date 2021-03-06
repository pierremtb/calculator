import QtQuick 2.7

Item {
    Shortcut {
        sequence: "Ctrl+D"
        onActivated: toogleAdvanced()
    }

    Shortcut {
        sequence: "Ctrl+S"
        onActivated: saveDialog.open()
    }

    Shortcut {
        sequence: "Ctrl+O"
        onActivated: openDialog.open()
    }

    Shortcut {
        sequence: "Ctrl+H"
        onActivated: toogleHistory()
        enabled: !advanced
    }

    Shortcut {
        sequence: "Ctrl+E"
        onActivated: toogleExpanded()
        enabled: !advanced
    }
}
