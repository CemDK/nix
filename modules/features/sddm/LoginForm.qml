// Replaces the sddm-astronaut LoginForm (see default.nix) with the layout of the
// hyprlock lock screen (dotfiles/hypr/hyprlock.conf): date and time at the top,
// user, password and fingerprint status at the bottom.
// The astronaut Main.qml still draws the background and blur.

import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: formContainer

    // Positions and sizes come from hyprlock.conf at 1080p and scale with the screen
    readonly property real s: root.height / 1080
    readonly property string fingerprintIcon: "<font face=\"MesloLGS Nerd Font\">󰈷</font>"
    readonly property string readyStatus: fingerprintIcon + "&nbsp;&nbsp;Enter for fingerprint"

    property string status: readyStatus
    property bool failed: false

    function login() {
        failed = false;
        sddm.login(users.currentText, password.text, sessionSelect.selectedSession);
    }

    Label {
        id: date

        anchors.horizontalCenter: parent.horizontalCenter
        y: 210 * s - height / 2

        font.family: "DejaVu Sans"
        font.pointSize: 18 * s
        font.bold: true
        color: "#b3ffffff"
        text: Qt.formatDate(clock.now, "ddd MMM d")
    }

    Label {
        id: time

        anchors.horizontalCenter: parent.horizontalCenter
        y: 280 * s - height / 2

        font.family: "DejaVu Sans"
        font.pointSize: 72 * s
        font.bold: true
        color: "#b3ffffff"
        text: Qt.formatTime(clock.now, "HH:mm")
    }

    Timer {
        id: clock

        property date now: new Date()

        interval: 1000
        repeat: true
        running: true
        onTriggered: now = new Date()
    }

    // Only used to pick the user, shown as plain text below
    ComboBox {
        id: users

        visible: false
        model: userModel
        textRole: "name"
        currentIndex: userModel.lastIndex
    }

    Label {
        id: user

        anchors.horizontalCenter: parent.horizontalCenter
        y: 920 * s - height / 2

        font.family: "DejaVu Sans"
        font.pointSize: 16 * s
        font.bold: true
        color: "#ffffff"
        text: users.currentText
    }

    TextField {
        id: password

        anchors.horizontalCenter: parent.horizontalCenter
        y: 968 * s - height / 2
        width: 240 * s
        height: 36 * s

        focus: true
        echoMode: TextInput.Password
        passwordCharacter: "●"
        horizontalAlignment: TextInput.AlignHCenter
        font.family: "DejaVu Sans"
        font.pointSize: 11 * s
        color: "#ffffff"

        background: Rectangle {
            radius: height / 2
            color: "#66062027"
            border.width: formContainer.failed ? 2 : 0
            border.color: "#f78104"
        }

        onAccepted: formContainer.login()
        onTextEdited: formContainer.failed = false

        // placeholderText doesn't render with a custom background
        Label {
            anchors.centerIn: parent
            visible: password.text === ""
            font: password.font
            color: "#93a1a1"
            text: "Password"
        }
    }

    Label {
        id: statusLabel

        anchors.horizontalCenter: parent.horizontalCenter
        y: 1012 * s - height / 2

        font.family: "DejaVu Sans"
        font.pointSize: 11 * s
        font.bold: true
        textFormat: Text.StyledText
        color: formContainer.failed ? "#f78104" : "#ffffff"
        text: formContainer.failed ? "Login failed" : formContainer.status
    }

    Connections {
        target: sddm

        // pam_fprintd: "Place your right index finger on the fingerprint reader"
        function onInformationMessage(message) {
            formContainer.status = message.indexOf("fingerprint reader") >= 0
                ? formContainer.fingerprintIcon + "&nbsp;&nbsp;Touch the fingerprint reader"
                : message;
        }

        function onLoginFailed() {
            formContainer.failed = true;
            formContainer.status = formContainer.readyStatus;
            password.text = "";
            password.forceActiveFocus();
        }
    }

    // Session picker from the astronaut theme, under the status line
    SessionButton {
        id: sessionSelect

        anchors.horizontalCenter: parent.horizontalCenter
        y: 1050 * s - height / 2
        width: parent.width / 2
        height: root.font.pointSize * 2
    }
}
