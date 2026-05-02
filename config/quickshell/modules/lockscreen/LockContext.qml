import QtQuick
import Quickshell
import Quickshell.Services.Pam

Scope {
    id: root

    signal unlocked
    signal failedUnlock

    property string currentText: ''
    property string maskedText: '•'.repeat(currentText.length)

    onCurrentTextChanged: showFailure = currentText !== '' ? false : showFailure

    property bool unlockInProgress: false
    property bool showFailure: false

    function tryUnlock() {
        if (currentText.length === 0 || unlockInProgress)
            return;

        unlockInProgress = true;
        pam.start();
    }

    PamContext {
        id: pam

        configDirectory: 'pam'
        config: 'password.conf'

        onPamMessage: {
            if (this.responseRequired)
                this.respond(root.currentText);
        }

        onCompleted: result => {
            if (result == PamResult.Success) {
                root.unlocked();
            } else {
                root.showFailure = true;
                root.failedUnlock();
            }

            root.currentText = '';
            root.unlockInProgress = false;
        }
    }
}
