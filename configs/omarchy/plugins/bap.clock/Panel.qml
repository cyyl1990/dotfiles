import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Ui
import "scripts/event_store.js" as EventStore
import "scripts/lunar_converter.js" as LunarConverter

// The clock's popup, showing the Lunar Calendar (Lịch Âm) instead of the
// plain Gregorian grid. The logic and visuals are drawn from the
// omarchy-lunar-calendar plugin; this panel keeps the clock's identity so
// the bar still treats it as the clock's own popup (same barIdentity,
// anchor and left-click open/close).
Panel {
    id: root

    property var anchorItem: null
    // The bar tracks the widget mounted in its slot — BarWidget.qml — not this
    // nested panel. Everything the bar identifies a panel by has to be that
    // widget: the popout coordinator (and with it the open-panel dot under the
    // pill) compares against `slot.activeItem`, and switchPanelFrom looks the
    // slot up the same way.
    property var hostWidget: null
    readonly property var barIdentity: hostWidget || root
    // ---- Lunar calendar state.
    property date today: new Date()
    property int selectedDay: today.getDate()
    property int viewYear: today.getFullYear()
    property int viewMonth: today.getMonth()
    property real timeZoneOffset: 7
    property var userEvents: []
    property var dayEvents: []
    property var selectedLunarInfo: ({
    })
    property var selectedMoonInfo: ({
    })
    readonly property color contentForeground: bar ? bar.foreground : Color.foreground
    readonly property string contentFontFamily: bar ? bar.fontFamily : Style.font.family
    readonly property bool popoutSwitchClosing: false

    // Guarded so the widget renders before the bar is injected (the bar-widget
    // contract instantiates it bare).
    function open() {
        refresh();
        root.controller.show();
        // Set after showing, not before: showing hands the popout coordinator
        // over, which closes whichever panel was open, and that close clears the
        // shared flag. Deferring means the panel taking over always wins.
        Qt.callLater(function() {
            if (root.opened)
                setCenterHoverRevealSuppressed(true);

        });
    }

    function close() {
        setCenterHoverRevealSuppressed(false);
        root.controller.hide();
    }

    function toggle() {
        if (root.opened)
            root.close();
        else
            root.open();
    }

    function switchPanel(direction) {
        if (root.bar && typeof root.bar.switchPanelFrom === "function")
            return root.bar.switchPanelFrom(root.barIdentity, direction);

        return false;
    }

    // Summoning by hotkey moves no pointer, so a hover the bar was still
    // holding must not keep the center indicators revealed behind the panel.
    function setCenterHoverRevealSuppressed(value) {
        if (root.bar && "centerHoverRevealSuppressed" in root.bar)
            root.bar.centerHoverRevealSuppressed = value;

    }

    function refresh() {
        root.today = new Date();
        root.viewMonth = root.today.getMonth();
        root.viewYear = root.today.getFullYear();
        root.selectedDay = root.today.getDate();
        updateSelectedDayInfo();
    }

    function updateSelectedDayInfo() {
        selectedLunarInfo = LunarConverter.convertSolarToLunar(root.selectedDay, root.viewMonth + 1, root.viewYear, timeZoneOffset);
        selectedMoonInfo = LunarConverter.getMoonPhase(root.selectedDay, root.viewMonth + 1, root.viewYear);
        dayEvents = EventStore.getEventsForDay(userEvents, root.selectedDay, root.viewMonth + 1, root.viewYear, selectedLunarInfo.lunarDay, selectedLunarInfo.lunarMonth);
    }

    function moveMonth(delta) {
        var m = root.viewMonth + delta;
        var y = root.viewYear;
        if (m < 0) {
            m = 11;
            y--;
        } else if (m > 11) {
            m = 0;
            y++;
        }
        root.viewMonth = m;
        root.viewYear = y;
        var maxDays = new Date(y, m + 1, 0).getDate();
        if (root.selectedDay > maxDays)
            root.selectedDay = maxDays;

        updateSelectedDayInfo();
    }

    function goToToday() {
        root.today = new Date();
        root.viewMonth = root.today.getMonth();
        root.viewYear = root.today.getFullYear();
        root.selectedDay = root.today.getDate();
        updateSelectedDayInfo();
    }

    // Kept as no-ops for IPC compatibility with the original clock panel
    // (the BarWidget may invoke these through the shell IPC handler).
    function toggleWeekStart() {
    }

    function closeForPopoutSwitch() {
        root.close();
    }

    moduleName: "bap.clock"
    ipcTarget: "bap.clock"
    manageIpc: false
    onSelectedDayChanged: root.updateSelectedDayInfo()
    Component.onCompleted: updateSelectedDayInfo()

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
        onDateChanged: {
            var followToday = root.viewMonth === root.today.getMonth() && root.viewYear === root.today.getFullYear();
            root.today = clock.date;
            if (followToday)
                root.goToToday();

        }
    }

    KeyboardPanel {
        id: panel

        anchorItem: root.anchorItem
        owner: root.barIdentity
        bar: root.bar
        open: root.opened
        centerOnBar: true
        focusTarget: keyCatcher
        contentWidth: panel.fittedContentWidth(Style.space(440))
        contentHeight: panel.fittedContentHeight(calendarColumn.implicitHeight)

        PanelKeyCatcher {
            id: keyCatcher

            anchors.fill: parent
            onMoveRequested: function(dx, dy) {
                if (dx !== 0)
                    root.moveMonth(dx);

            }
            onActivateRequested: root.goToToday()
            onCloseRequested: root.close()
            onTabRequested: function(direction) {
                root.switchPanel(direction);
            }
            onTextKey: function(t) {
                if (t === "[")
                    root.moveMonth(-1);
                else if (t === "]")
                    root.moveMonth(1);
                else if (t === "t" || t === "T")
                    root.goToToday();
            }

            Flickable {
                id: calendarScroll

                anchors.fill: parent
                contentWidth: calendarColumn.width
                contentHeight: calendarColumn.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: calendarColumn

                    width: Math.max(calendarScroll.width, 360)
                    spacing: Style.space(8)

                    // ---- Hero: today's lunar date.
                    Item {
                        width: parent.width
                        height: heroRow.height

                        Row {
                            id: heroRow

                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: Style.space(16)

                            Text {
                                anchors.baseline: heroDate.baseline
                                text: root.selectedMoonInfo.phaseIcon || "🌕"
                                font.pixelSize: 36
                            }

                            Text {
                                id: heroDate

                                anchors.verticalCenter: parent.verticalCenter
                                text: {
                                    var months = ["Tháng 1", "Tháng 2", "Tháng 3", "Tháng 4", "Tháng 5", "Tháng 6", "Tháng 7", "Tháng 8", "Tháng 9", "Tháng 10", "Tháng 11", "Tháng 12"];
                                    return months[root.viewMonth] + " " + root.viewYear;
                                }
                                color: root.contentForeground
                                font.family: root.contentFontFamily
                                font.pixelSize: 28
                                font.bold: true
                            }

                        }

                    }

                    // ---- Can Chi & Solar Term.
                    Item {
                        width: parent.width
                        height: canChiRow.height + Style.space(8)

                        Row {
                            id: canChiRow

                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: Style.space(10)

                            Text {
                                text: "Năm " + (root.selectedLunarInfo.canChiYear || "")
                                font.family: root.contentFontFamily
                                font.pixelSize: Style.font.bodySmall
                                font.bold: true
                                color: Style.selectedStateColor(root.contentForeground, Color.accent)
                            }

                            Text {
                                text: "·"
                                color: Qt.darker(root.contentForeground, 1.8)
                                font.pixelSize: Style.font.bodySmall
                            }

                            Text {
                                text: "Tháng " + (root.selectedLunarInfo.canChiMonth || "")
                                font.family: root.contentFontFamily
                                font.pixelSize: Style.font.bodySmall
                                color: root.contentForeground
                            }

                            Text {
                                text: "·"
                                color: Qt.darker(root.contentForeground, 1.8)
                                font.pixelSize: Style.font.bodySmall
                            }

                            Text {
                                text: root.selectedLunarInfo.solarTerm || ""
                                font.family: root.contentFontFamily
                                font.pixelSize: Style.font.caption
                                font.italic: true
                                color: "#fbbf24"
                            }

                        }

                    }

                    // ---- Day-of-week header.
                    Row {
                        spacing: Style.space(2)

                        Repeater {
                            model: ["T2", "T3", "T4", "T5", "T6", "T7", "CN"]

                            Text {
                                width: Math.floor((calendarColumn.width - Style.space(12)) / 7)
                                horizontalAlignment: Text.AlignHCenter
                                text: modelData
                                font.family: root.contentFontFamily
                                font.pixelSize: Style.font.caption
                                font.letterSpacing: 1
                                font.bold: true
                                color: index === 6 ? "#f43f5e" : Qt.darker(root.contentForeground, 1.5)
                            }

                        }

                    }

                    // ---- Month grid with dual Gregorian + Lunar dates.
                    Grid {
                        columns: 7
                        rowSpacing: Style.space(3)
                        columnSpacing: Style.space(2)

                        Repeater {
                            model: {
                                var list = [];
                                var firstDay = new Date(root.viewYear, root.viewMonth, 1).getDay();
                                var offset = (firstDay === 0) ? 6 : firstDay - 1;
                                var totalDays = new Date(root.viewYear, root.viewMonth + 1, 0).getDate();
                                for (var b = 0; b < offset; b++) {
                                    list.push({
                                        "day": 0,
                                        "inMonth": false,
                                        "lunarText": "",
                                        "isSel": false,
                                        "isTod": false,
                                        "isSpec": false
                                    });
                                }
                                for (var d = 1; d <= totalDays; d++) {
                                    var lInfo = LunarConverter.convertSolarToLunar(d, root.viewMonth + 1, root.viewYear, root.timeZoneOffset);
                                    var isTod = (d === root.today.getDate() && root.viewMonth === root.today.getMonth() && root.viewYear === root.today.getFullYear());
                                    var isSel = (d === root.selectedDay);
                                    var isSpec = (lInfo.lunarDay === 1 || lInfo.lunarDay === 15);
                                    var dayEvents = EventStore.getEventsForDay([], d, root.viewMonth + 1, root.viewYear, lInfo.lunarDay, lInfo.lunarMonth);
                                    var eventText = EventStore.getEventPreview(dayEvents);
                                    var lText = lInfo.lunarDay === 1 ? (lInfo.lunarDay + "/" + lInfo.lunarMonth) : String(lInfo.lunarDay);
                                    list.push({
                                        "day": d,
                                        "inMonth": true,
                                        "lunarText": lText,
                                        "eventText": eventText,
                                        "isSel": isSel,
                                        "isTod": isTod,
                                        "isSpec": isSpec
                                    });
                                }
                                return list;
                            }

                            delegate: Rectangle {
                                width: Math.floor((calendarColumn.width - Style.space(12)) / 7)
                                height: Style.space(54)
                                radius: Style.cornerRadius
                                visible: true
                                color: modelData.isSel ? Style.selectedStateColor(root.contentForeground, Color.accent) : (gridMouse.containsMouse ? Style.hoverFillFor(root.contentForeground, Color.accent) : "transparent")
                                border.width: modelData.isTod ? Style.spacing.hairline : (modelData.isSpec ? 1 : 0)
                                border.color: modelData.isTod ? Style.normalBorderFor(root.contentForeground, Color.accent) : (modelData.isSpec ? "#f59e0b" : "transparent")

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 1

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: modelData.day > 0 ? String(modelData.day) : ""
                                        font.family: root.contentFontFamily
                                        font.pixelSize: Style.font.body
                                        font.bold: Boolean(modelData.isTod || modelData.isSel)
                                        color: modelData.isSel ? Color.popups.background : root.contentForeground
                                    }

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: modelData.lunarText || ""
                                        font.family: root.contentFontFamily
                                        font.pixelSize: Style.font.caption
                                        font.bold: Boolean(modelData.isSpec)
                                        color: modelData.isSpec ? "#fbbf24" : Qt.darker(root.contentForeground, 1.5)
                                    }

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: parent.width - Style.space(4)
                                        text: modelData.eventText || ""
                                        visible: Boolean(modelData.eventText)
                                        horizontalAlignment: Text.AlignHCenter
                                        font.family: root.contentFontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        color: modelData.isSel ? "#fde68a" : "#f97316"
                                        elide: Text.ElideRight
                                    }

                                }

                                MouseArea {
                                    id: gridMouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    acceptedButtons: Qt.LeftButton
                                    preventStealing: true
                                    onPressed: {
                                        if (modelData.day > 0)
                                            root.selectedDay = modelData.day;

                                    }
                                }

                            }

                        }

                    }

                    // ---- Month nav.
                    Item {
                        width: parent.width
                        height: monthNav.height

                        Item {
                            id: monthNav

                            anchors.horizontalCenter: parent.horizontalCenter
                            width: calendarColumn.width
                            height: monthLabel.implicitHeight + Style.space(10)

                            Text {
                                id: monthLabel

                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter
                                width: Style.space(200)
                                horizontalAlignment: Text.AlignHCenter
                                text: Qt.formatDate(new Date(root.viewYear, root.viewMonth, 1), "MMMM yyyy").toUpperCase()
                                color: Qt.darker(root.contentForeground, 1.4)
                                font.family: root.contentFontFamily
                                font.pixelSize: Style.font.body
                                font.letterSpacing: 1
                            }

                            PanelActionButton {
                                anchors.left: parent.left
                                anchors.leftMargin: -Style.space(8)
                                anchors.verticalCenter: parent.verticalCenter
                                iconText: "󰅁"
                                tooltipText: "Tháng trước"
                                foreground: root.contentForeground
                                fontFamily: root.contentFontFamily
                                onClicked: root.moveMonth(-1)
                            }

                            PanelActionButton {
                                anchors.right: parent.right
                                anchors.rightMargin: -Style.space(8)
                                anchors.verticalCenter: parent.verticalCenter
                                iconText: "󰅂"
                                tooltipText: "Tháng sau"
                                foreground: root.contentForeground
                                fontFamily: root.contentFontFamily
                                onClicked: root.moveMonth(1)
                            }

                        }

                    }

                    PanelSeparator {
                        foreground: root.contentForeground
                    }

                    // ---- Selected day details.
                    Item {
                        width: parent.width
                        height: detailRow.height

                        Row {
                            id: detailRow

                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: Style.space(10)

                            Text {
                                text: root.selectedMoonInfo.phaseIcon || "🌕"
                                font.pixelSize: 22
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                spacing: 2

                                Text {
                                    text: root.selectedDay + "/" + (root.viewMonth + 1) + "/" + root.viewYear + " — Âm: " + root.selectedLunarInfo.lunarDay + "/" + root.selectedLunarInfo.lunarMonth + "/" + root.selectedLunarInfo.lunarYear
                                    font.family: root.contentFontFamily
                                    font.pixelSize: Style.font.body
                                    font.bold: true
                                    color: root.contentForeground
                                }

                                Text {
                                    text: "Ngày " + (root.selectedLunarInfo.canChiDay || "") + " · " + (root.selectedMoonInfo.phaseName || "") + " (" + (root.selectedMoonInfo.illumination || 0) + "%)"
                                    font.family: root.contentFontFamily
                                    font.pixelSize: Style.font.caption
                                    color: Qt.darker(root.contentForeground, 1.4)
                                }

                            }

                        }

                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: eventBannerText.implicitHeight + Style.space(12)
                        radius: Style.cornerRadius
                        color: root.dayEvents.length ? "#2b1b0f" : "#111827"
                        border.color: root.dayEvents.length ? "#f97316" : "#334155"
                        border.width: 1

                        Text {
                            id: eventBannerText

                            anchors.fill: parent
                            anchors.margins: Style.space(6)
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            wrapMode: Text.WordWrap
                            font.family: root.contentFontFamily
                            font.pixelSize: Style.font.bodySmall
                            font.bold: true
                            color: root.dayEvents.length ? "#fdba74" : "#94a3b8"
                            text: root.dayEvents.length ? ("Sự kiện: " + EventStore.getEventSummary(root.dayEvents)) : "Không có sự kiện cho ngày này"
                        }

                    }

                    // ---- Activities section.
                    PanelSectionHeader {
                        text: "SỰ KIỆN (" + root.dayEvents.length + ")"
                        foreground: root.contentForeground
                        fontFamily: root.contentFontFamily
                    }

                    Column {
                        width: parent.width
                        spacing: Style.space(4)

                        Repeater {
                            model: root.dayEvents

                            delegate: CursorSurface {
                                width: parent.width
                                implicitHeight: Style.space(36)
                                foreground: root.contentForeground

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: Style.spacing.rowPaddingX
                                    anchors.rightMargin: Style.spacing.rowPaddingX
                                    spacing: Style.space(8)

                                    Rectangle {
                                        width: 8
                                        height: 8
                                        radius: 4
                                        color: modelData.type === "lunar" ? "#e11d48" : "#3b82f6"
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.title
                                        font.family: root.contentFontFamily
                                        font.pixelSize: Style.font.bodySmall
                                        color: root.contentForeground
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: modelData.time || ""
                                        font.family: root.contentFontFamily
                                        font.pixelSize: Style.font.caption
                                        color: Qt.darker(root.contentForeground, 1.5)
                                    }

                                }

                            }

                        }

                    }

                }

            }

        }

    }

}
