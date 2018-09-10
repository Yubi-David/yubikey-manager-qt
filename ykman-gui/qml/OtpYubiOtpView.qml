import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils
import QtQuick.Controls.Material 2.3

ColumnLayout {

    function useSerial() {
        if (useSerialCb.checked) {
            yubiKey.serial_modhex(function (res) {
                publicIdInput.text = res
            })
        }
    }

    function generatePrivateId() {
        yubiKey.random_uid(function (res) {
            privateIdInput.text = res
        })
    }

    function generateKey() {
        yubiKey.random_key(16, function (res) {
            secretKeyInput.text = res
        })
    }

    function finish() {
        if (views.selectedSlotConfigured()) {
            otpSlotAlreadyConfiguredPopup.open()
        } else {
            programYubiOtp()
        }
    }

    function programYubiOtp() {
        yubiKey.program_otp(views.selectedSlot, publicIdInput.text,
                            privateIdInput.text, secretKeyInput.text,
                            function (resp) {
                                if (resp.success) {
                                    views.otpSuccess()
                                } else {
                                    if (resp.error === 'write error') {
                                        views.otpWriteError()
                                    } else {
                                        views.otpFailedToConfigureErrorPopup(
                                                    resp.error)
                                    }
                                }
                            })
    }

    OtpSlotAlreadyConfiguredPopup {
        id: otpSlotAlreadyConfiguredPopup
        onAccepted: programYubiOtp()
    }

    ColumnLayout {
        Layout.margins: 20
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: app.height
        Heading1 {
            text: qsTr("Yubico OTP")
        }

        BreadCrumbRow {
            BreadCrumb {
                text: qsTr("Home")
                action: views.home
            }

            BreadCrumbSeparator {
            }
            BreadCrumb {
                text: qsTr("OTP")
                action: views.otp
            }

            BreadCrumbSeparator {
            }
            BreadCrumb {
                text: qsTr(SlotUtils.slotNameCapitalized(views.selectedSlot))
                action: views.otp
            }

            BreadCrumbSeparator {
            }

            BreadCrumb {
                text: qsTr("Select Credential Type")
                action: views.pop
            }

            BreadCrumbSeparator {
            }

            BreadCrumb {
                text: qsTr("Yubico OTP")
                active: true
            }
        }

        GridLayout {
            columns: 3
            Layout.fillWidth: true
            Label {
                text: qsTr("Public ID")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                font.pointSize: constants.h3
                color: yubicoBlue
            }
            TextField {
                id: publicIdInput
                Layout.fillWidth: true
                enabled: !useSerialCb.checked
                validator: RegExpValidator {
                    regExp: /[cbdefghijklnrtuv]{12}$/
                }
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Public ID must be a 12 characters (6 bytes) modhex value.")
                selectByMouse: true
                selectionColor: yubicoGreen
            }
            CheckBox {
                id: useSerialCb
                enabled: yubiKey.serial
                text: qsTr("Use serial")
                onCheckedChanged: useSerial()
                ToolTip.delay: 1000
                font.pointSize: constants.h3
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Use the encoded serial number of the YubiKey as Public ID.")
                Material.foreground: yubicoBlue
            }

            Label {
                text: qsTr("Private ID")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                font.pointSize: constants.h3
                color: yubicoBlue
            }
            TextField {
                id: privateIdInput
                Layout.fillWidth: true
                validator: RegExpValidator {
                    regExp: /[0-9a-fA-F]{12}$/
                }
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Private ID must be a 12 characters (6 bytes) hex value.")
                selectByMouse: true
                selectionColor: yubicoGreen
            }
            Button {
                id: generatePrivateIdBtn
                text: qsTr("Generate")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                onClicked: generatePrivateId()
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Generate a random Private ID.")
                font.capitalization: Font.MixedCase
                font.family: constants.fontFamily
                Material.foreground: yubicoBlue
            }

            Label {
                text: qsTr("Secret key")
                font.pointSize: constants.h3
                color: yubicoBlue
            }
            TextField {
                id: secretKeyInput
                Layout.fillWidth: true
                validator: RegExpValidator {
                    regExp: /[0-9a-fA-F]{32}$/
                }
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Secret key must be a 32 characters (16 bytes) hex value.")
                selectByMouse: true
                selectionColor: yubicoGreen
            }
            Button {
                id: generateSecretKeyBtn
                text: qsTr("Generate")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                onClicked: generateKey()
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Generate a random Secret Key.")
                font.capitalization: Font.MixedCase
                font.family: constants.fontFamily
                Material.foreground: yubicoBlue
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom

            Button {
                id: backBtn
                text: qsTr("Back")
                onClicked: views.pop()
                icon.source: "../images/back.svg"
                icon.width: 16
                icon.height: 16
                font.capitalization: Font.MixedCase
                font.family: constants.fontFamily
                Material.foreground: yubicoBlue
            }
            Button {
                id: finnishBtn
                text: qsTr("Finish")
                highlighted: true
                onClicked: finish()
                enabled: publicIdInput.acceptableInput
                         && privateIdInput.acceptableInput
                         && secretKeyInput.acceptableInput
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Finish and write the configuration to the YubiKey.")
                icon.source: "../images/finish.svg"
                icon.width: 16
                icon.height: 16
                font.capitalization: Font.MixedCase
                font.family: constants.fontFamily
            }
        }
    }
}
