pragma Singleton
import Quickshell
import Quickshell.Io

// A sudo-backed password prompt for the handful of commands that need root
// but can't go through polkit (see Polkit.qml) -- pkexec refuses to elevate
// a script sitting in a user-writable directory, which is exactly where
// bind_and_boot lives. Same request/error/submit/cancel shape AuthFlow
// (Quickshell.Services.Polkit) exposes, so AuthPrompt.qml can treat both
// sources uniformly.
Singleton {
    id: root

    property var pendingCommand: null
    property string message: ""
    property string errorMessage: ""

    function request(command: var, msg: string) {
        root.pendingCommand = command;
        root.message = msg;
        root.errorMessage = "";
    }

    function cancel() {
        if (proc.running)
            proc.running = false;
        root.pendingCommand = null;
        root.errorMessage = "";
    }

    function submit(password: string) {
        root.errorMessage = "";
        proc.pendingPassword = password;
        proc.command = ["sudo", "-S", "-p", ""].concat(root.pendingCommand);
        proc.running = true;
    }

    Process {
        id: proc

        property string pendingPassword: ""

        stdinEnabled: true

        // sudo -S reads the password from stdin the moment it starts; write
        // it as soon as the process is actually running rather than at
        // submit() time, since command/running haven't taken effect yet
        // there. Closing stdin right after (toggling stdinEnabled off sends
        // EOF) matters just as much as writing it: sudo -S otherwise just
        // sits there hoping for a second attempt on the same fd once a
        // wrong password fails, forever, instead of exiting nonzero the way
        // a closed input stream makes it.
        onRunningChanged: {
            if (running) {
                stdinEnabled = true;
                write(pendingPassword + "\n");
                pendingPassword = "";
                stdinEnabled = false;
            }
        }

        onExited: exitCode => {
            if (exitCode === 0)
                root.pendingCommand = null;
            else
                root.errorMessage = "Incorrect password, try again.";
        }
    }
}
