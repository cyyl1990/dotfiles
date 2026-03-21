/*
 * Menu inspried by select.lua (utilising mp.input.select), leveraging configuration and
 * approach from mpvcontextmenu (https://gitlab.com/carmanaught/mpvcontextmenu).
 * Thomas Carmichael (carmanaught) https://gitlab.com/carmanaught
 *
 * Credit to Guido Cella (guidocella) https://github.com/guidocella for the select.lua
 * that inspired this rewritten script from mpvcontextmenu.
 *
 * A key difference is that there is no seperate "menu engine", and other menu builders
 * as this is only intended to be used with the built-in input/console scripts.
 *
 * Features:
 * - Comprehensive menu and sub-menus providing access to various mpv functionality.
 * - Very well integrated as it's using the built-in scripts without subprocesses.
 * - Not dependent on external software for displaying the menu itself.
 * - Dynamic menu items and commands, disabled items, separators.
 * - Configurable options for keybindings.
 *
 * Setup/Requirements:
 * - Check https://gitlab.com/carmanaught/mpvselectmenu for further setup instructions
 *
 * 2025-04-19 - Version 0.1 - Initial version
 */

require("./gui-dialogs");
var langcodes = require("./langcodes");

var options = mp.options;
var input = mp.input;

/**
 * Get property using the best type for the property (using mpv built-in mpv.get_property_native()).
 */
var propNative = mp.get_property_native;

var verbose = false  // true -> Dump console messages also without -v
/**
 * Debug output helper that works based on state of verbose variable. Used if desired
 * to allow debugging related output functions to be left in place but be toggled on.
 * @param {any} x Value to return, which could be anything (values, objects, etc.)
 */
function info(x) { verbose ? mp.msg.info(x) : mp.msg.verbose(x); }

/**
 * Debug output helper using mp.msg.info()
 * @param {any} x Value to return, which could be anything (values, objects, etc.)
 */
function mpdebug(x) { mp.msg.info(x); }

// NOTE: Use the following to output the bindings as an array to a file if needed.
// This will output to the current directory.
//utils.write_file("file://bindings.txt", mp.get_property('input-bindings', []))

// NOTE: Use the following to output the bindings as an array via mpv debug output.
//mpdebug(mp.get_property('input-bindings'))

/**
 * OSD message helper using mp.osd_message() but including the script name.
 * @param {*} msg Text of message to output to OSD.
 * @param {*} duration Duration of OSD to show message for in seconds.
 */
function osd(msg, duration) {
    duration = duration && typeof duration === "number" ? duration : propNative("osd-duration")/1000;
    mp.osd_message(mp.get_script_name() + ": " + msg, duration);
}

// NOTE: For the forced bindings, MBTN_MID won't work as that's already used by the
// console.lua script for pasting text. Also, we're using a comma (,) to split on
// to allow for multiple bindings, so that can't be used as a binding unless the code
// here is modified.
var opt = {
    forcedBindings: "MBTN_RIGHT,MENU",
}
options.read_options(opt);
var binds = opt.forcedBindings.split(",");

// Set some constant values
var SEP = "separator";
var CSD = "cascade";
var CMD = "command";
var CHK = "checkbox";
var RAD = "radiobutton";
var ABC = "ab-check";

// In case we need to fail loading the menu
var failMenu = false;
var failError = "";

/**
 * Round a number to a count of decimal places.
 * @param {number} num Number to round.
 * @param {number} decimalPlaces Number of decimal places to round the number to.
 * @returns Returns a number rounded to the number of decimal places specified.
 */
function round(num, decimalPlaces) {
    return Number(Math.round(num + 'e' + decimalPlaces) + 'e-' + decimalPlaces);
}

/**
 * Get the length of an object.
 * @param {object} object The object to get the length of.
 * @returns Returns a value with the length of the object.
 */
function len(object) {
    return Object.keys(object).length;
}

/**
 * Get a useful indicator of an objects type.
 * @param {object} val The object to check the type for and return the object type.
 * @returns Returns the object type, e.g. [object Array], [object Object], etc.
 */
function objType(val) {
    return Object.prototype.toString.call(val);
}

/**
 * Table object to hold insert and remove functions to mimic LUA table.x functions
 */
var table = {
    /**
     * Adds a value (as a numeric property) to an object at the end of the current count of objects.
     * @param {object} object The object to add the value to.
     * @param {any} value The value to add to the object.
     */
    insert: function(object, value) {
        object[(len(object) + 1)] = value;
    },

    /**
     * Removes a property from an object. This can be a named property or a value. If it's a value it tries to resequence (assuming sequential numbers).
     * @param {object} object The object to remove the property from.
     * @param {any} property The property to remove from the object.
     */
    remove: function(object, property) {
        if (typeof property === "number") {
            var currentLen = len(object);
            for (var i = property; i < currentLen; i++) {
                object[i] = object[(i + 1)];
            }
            delete object[currentLen];
        } else {
            delete object[property];
        }
    }
}

/**
 * Check if there are editions and therefore whether to enable the edition menu.
 * @returns Returns boolean to indicate if the edition menu should be enabled.
 */
function enableEdition() {
    var editionState = false;

    if (propNative("edition-list/count") < 1) { editionState = true; }

    return editionState;
}

/**
 * Check that state of an edition.
 * @param {number} editionNum Edition number to check the state of.
 * @returns Returns boolean to indicate the state of the edition.
 */
function checkEdition(editionNum) {
    var editionEnable = false;
    var editionCur = propNative("current-edition");

    if (editionNum === editionCur) { editionEnable = true; }

    return editionEnable;
}

/**
 * Build the edition menu structure.
 * @returns Returns the edition menu structure.
 */
function editionMenu() {
    var editionCount = propNative("edition-list/count");
    var editionMenuVal = {};

    if (editionCount !== 0) {
        for (var editionNum = 0; editionNum < editionCount; editionNum++ ) {
            var editionTitle = propNative("edition-list/" + editionNum + "/title");
            if (!editionTitle) { editionTitle = "Edition " + (editionNum + 1); }

            var editionCommand = "set edition " + editionNum;
            editionMenuVal[(editionNum + 1)] = new menuItem(RAD, [editionTitle, "", editionCommand], function(editionNum) { return checkEdition(editionNum); }(editionNum), false, true);
        }
    } else {
        table.insert(editionMenuVal, new menuItem(CMD, ["No Editions", "", ""], "", true));
    }

    return editionMenuVal;
}

/**
 * Check if there are chapters and therefore whether to enable the chapter menu.
 * @returns Returns boolean to indicate if the chapter menu should be enabled.
 */
function enableChapter() {
    var chapterEnable = false;

    if (propNative("chapter-list/count") < 1) { chapterEnable = true; }

    return chapterEnable;
}

/**
 * Check that state of a chapter.
 * @param {number} chapterNum Chapter number to check the state of.
 * @returns Returns boolean to indicate the state of the chapter.
 */
function checkChapter(chapterNum) {
    var chapterState = false;
    var chapterCur = propNative("chapter");

    if (chapterNum === chapterCur) { chapterState = true; }

    return chapterState;
}

/**
 * Build the chapter menu structure.
 * @returns Returns the chapter menu structure.
 */
function chapterMenu() {
    var chapterCount = propNative("chapter-list/count");
    var chapterMenuVal = {};

    table.insert(chapterMenuVal, new menuItem(CMD, "chapterprev", "", false, true));
    table.insert(chapterMenuVal, new menuItem(CMD, "chapternext", "", false, true));
    table.insert(chapterMenuVal, new menuItem(SEP));

    if (chapterCount !== 0) {
        for (var chapterNum = 0; chapterNum < chapterCount; chapterNum++) {
            var chapterTitle = propNative("chapter-list/" + chapterNum + "/title");
            if (!chapterTitle) { chapterTitle = "Chapter " + (chapterNum + 1); }

            var chapterCommand = "set chapter " + chapterNum;
            table.insert(chapterMenuVal, new menuItem(RAD, [chapterTitle, "", chapterCommand], function(chapterNum) { return checkChapter(chapterNum); }(chapterNum), false, true));
        }
    }

    return chapterMenuVal;
}

/**
 * Track type count to iterate through the tracklist and get the number of tracks of the type specified.
 * @param {string} checkType Track type (video / audio / sub) to check the count.
 * @returns Returns a table of track numbers of the given type so that the track-list/N/ properties can be obtained.
 */
function trackCount(checkType) {
    var tracksCount = propNative("track-list/count");
    var trackCountVal = {};

    if (tracksCount > 0) {
        for (var i = 0; i < tracksCount; i++) {
            var trackType = propNative("track-list/" + i + "/type")
            if (trackType === checkType) { table.insert(trackCountVal, i); }
        }
    }

    return trackCountVal
}

/**
 * Check if a track is selected based on the track-list so isn't specific ta a track type.
 * @param {boolean} trackNum Track number to check the state of.
 * @returns Returns boolean to indicate the state of the track.
 */
function checkTrack(trackNum) {
    var trackState = false;
    var trackCur = propNative("track-list/" + trackNum + "/selected");

    if (trackCur === true) { trackState = true; }

    return trackState;
}

/**
 * Check if there are video tracks and therefore whether to enable the video track menu.
 * @returns Returns boolean to indicate if the video track menu should be enabled.
 */
function enableVidTrack() {
    var vidTrackEnable = false;
    var vidTracks = trackCount("video");
    var vidTracksLen = len(vidTracks);

    if (vidTracksLen < 1) { vidTrackEnable = true; }

    return vidTrackEnable;
}

/**
 * Build the video menu structure.
 * @returns Returns the video menu structure.
 */
function vidTrackMenu() {
    var vidTrackMenuVal = {};
    var vidTrackCount = trackCount("video");
    var vidTrackCountLen = len(vidTrackCount);

    if (vidTrackCountLen !== 0) {
        for (var i = 1; i <= vidTrackCountLen; i++) {
            var vidTrackNum = vidTrackCount[i];
            var vidTrackID = propNative("track-list/" + vidTrackNum + "/id");
            var vidTrackTitle = propNative("track-list/" + vidTrackNum + "/title");
            if (!vidTrackTitle) { vidTrackTitle = "Video Track " + i; }

            var vidTrackCommand = "set vid " + vidTrackID;
            table.insert(vidTrackMenuVal, new menuItem(RAD, [vidTrackTitle, "", vidTrackCommand], function(trackNum) { return checkTrack(trackNum); }(vidTrackNum), false, true));
        }
    } else {
        table.insert(vidTrackMenuVal, new menuItem (RAD, ["No Video Tracks", "", ""], "", true));
    }

    return vidTrackMenuVal;
}

/**
 * Convert ISO 639-1/639-2 codes to be full length language names. The full length names are obtained by using the property accessor with the iso639_1/_2 tables stored in the langcodes.js file (require("./langcodes") above).
 * @param {string} trackLang The 2 or 3 character language code.
 * @returns Returns the full length language names.
 */
function getLang(trackLang) {
    trackLang = trackLang.toUpperCase();

    if (trackLang.length === 2) { trackLang = langcodes.iso639_1(trackLang); }
    else if (trackLang.length === 3) { trackLang = langcodes.iso639_2(trackLang); }

    return trackLang;
}

/**
 * Checks if a type of track is disabled. The track check will return a track number if not disabled and "no/false" if disabled.
 * @param {(boolean|any)} checkType Check the type (values are vid/sid/aid).
 * @returns Returns boolean to indicate if the track type provided is disabled.
 */
function noneCheck(checkType) {
    var checkVal = false;
    var trackID = propNative(checkType);

    if (typeof trackID === "boolean") {
        if (trackID === false) { checkVal = true; }
    }

    return checkVal
}

/**
 * Build the audio menu structure.
 * @returns Returns the audio menu structure.
 */
function audTrackMenu() {
    var audTrackMenuVal = {};
    var audTrackCount = trackCount("audio");
    var audTrackCountLen = len(audTrackCount);

    table.insert(audTrackMenuVal, new menuItem(CMD, ["Open File", "", "script-binding mpvselectmenu/add_audio_dialog"], "", false));
    table.insert(audTrackMenuVal, new menuItem(CMD, ["Reload File", "", "audio-reload"], "", false));
    table.insert(audTrackMenuVal, new menuItem(CMD, ["Remove", "", "audio-remove"], "", false));
    table.insert(audTrackMenuVal, new menuItem(SEP));
    table.insert(audTrackMenuVal, new menuItem(CMD, "audtracknext", "", false, true));

    if (audTrackCountLen !== 0) {
        for (var i = 1; i <= audTrackCountLen; i++) {
            var audTrackNum = audTrackCount[i];
            var audTrackID = propNative("track-list/" + audTrackNum + "/id");
            var audTrackTitle = propNative("track-list/" + audTrackNum + "/title");
            var audTrackLang = propNative("track-list/" + audTrackNum + "/lang");
            // Convert ISO 639-1/2 codes
            if (audTrackLang !== undefined) { audTrackLang = getLang(audTrackLang) ? getLang(audTrackLang) : audTrackLang; }

            if (audTrackTitle) { audTrackTitle = audTrackTitle + ((audTrackLang !== undefined) ? " (" + audTrackLang + ")" : ""); }
            else if (audTrackLang) { audTrackTitle = audTrackLang; }
            else { audTrackTitle = "Audio Track " + i; }

            var audTrackCommand = "set aid " + audTrackID;
            if (i === 1) {
                table.insert(audTrackMenuVal, new menuItem(SEP));
                table.insert(audTrackMenuVal, new menuItem(RAD, ["Select None", "", "set aid 0"], function() { return noneCheck("aid"); }, false, true));
                table.insert(audTrackMenuVal, new menuItem(SEP));
            }
            table.insert(audTrackMenuVal, new menuItem(RAD, [audTrackTitle, "", audTrackCommand], function(trackNum) { return checkTrack(trackNum); }(audTrackNum), false, true));
        }
    }

    return audTrackMenuVal;
}

/**
 * Subtitle menu item label to indicate what the clicking on the menu this is associated with will do (hide if visible, un-hide if hidden).
 * @returns Returns string to indicate what the menu will do.
 */
function subVisLabel() { return propNative("sub-visibility") ? "Hide" : "Un-hide" }

/**
 * Build the subtitle menu structure.
 * @returns Returns the subtitle menu structure.
 */
function subTrackMenu() {
    var subTrackMenuVal = {};
    var subTrackCount = trackCount("sub");
    var subTrackCountLen = len(subTrackCount);

    table.insert(subTrackMenuVal, new menuItem(CMD, "addsub", "", false));
    table.insert(subTrackMenuVal, new menuItem(CMD, ["Reload File", "", "sub-reload"], "", false));
    table.insert(subTrackMenuVal, new menuItem(CMD, ["Clear File", "", "sub-remove"], "", false));
    table.insert(subTrackMenuVal, new menuItem(SEP));
    table.insert(subTrackMenuVal, new menuItem(CMD, "subnext", "", false, true));
    table.insert(subTrackMenuVal, new menuItem(CMD, "subprev", "", false, true));
    table.insert(subTrackMenuVal, new menuItem(CHK, [function() { return subVisLabel(); }, "subvis"], function() { return !propNative("sub-visibility"); }, false, true));

    if (subTrackCountLen !== 0) {
        for (var i = 1; i <= subTrackCountLen; i++) {
            var subTrackNum = subTrackCount[i];
            var subTrackID = propNative("track-list/" + subTrackNum + "/id");
            var subTrackTitle = propNative("track-list/" + subTrackNum + "/title");
            var subTrackLang = propNative("track-list/" + subTrackNum + "/lang");
            // Convert ISO 639-1/2 codes
            if (subTrackLang !== undefined) { subTrackLang = getLang(subTrackLang) ? getLang(subTrackLang) : subTrackLang; }

            if (subTrackTitle) { subTrackTitle = subTrackTitle + ((subTrackLang !== undefined) ? " (" + subTrackLang + ")" : ""); }
            else if (subTrackLang) { subTrackTitle = subTrackLang; }
            else { subTrackTitle = "Subtitle Track " + i; }

            var subTrackCommand = "set sid " + subTrackID;
            if (i === 1) {
                table.insert(subTrackMenuVal, new menuItem(SEP));
                table.insert(subTrackMenuVal, new menuItem(RAD, ["Select None", "", "set sid 0"], function() { return noneCheck("sid"); }, false, true));
                table.insert(subTrackMenuVal, new menuItem(SEP));
            }
            table.insert(subTrackMenuVal, new menuItem(RAD, [subTrackTitle, "", subTrackCommand], function(subTrackNum) { return checkTrack(subTrackNum); }(subTrackNum), false, true));
        }
    }

    return subTrackMenuVal;
}

/**
 * Subtitle menu item label to indicate what the clicking on the menu this is associated with will do (hide if visible, un-hide if hidden).
 * @returns Returns string to indicate what the menu will do.
 */
function abLoopLabel() {
    var loopState = stateABLoop();
    var loopLabel;

    // var loopLabel = {
    //     off: "Loop - Set Start (A)",
    //     a: "Loop - Set End (B)",
    //     b: "Loop - Clear Loop",
    // }[loopState]
    switch (loopState) {
        case "off":
            loopLabel = "Loop - Set Start (A)"
            break;
        case "a":
            loopLabel = "Loop - Set End (B)"
            break;
        case "b":
            loopLabel = "Loop - Clear Loop"
            break;
    }

    return loopLabel;
}

/**
 * Get the A/B loop state.
 * @returns Returns the A/B loop state.
 */
function stateABLoop() {
    var abLoopState = "";
    var abLoopA = propNative("ab-loop-a");
    var abLoopB = propNative("ab-loop-b");

    if ((abLoopA === "no") && (abLoopB === "no")) { abLoopState = "off"; }
    else if ((abLoopA !== "no") && (abLoopB === "no")) { abLoopState = "a"; }
    else if ((abLoopA !== "no") && (abLoopB !== "no")) { abLoopState = "b"; }

    return abLoopState;
}

/**
 * Check the file infinite loop state.
 * @returns Return the file infinite loop state.
 */
function stateFileLoop() {
    var loopState = false;
    var loopval = propNative("loop-file");

    if (loopval === "inf") { loopState = true;}

    return loopState;
}

/**
 * Check the video aspect ratio for the video aspect radio menu items.
 * @param {any} ratioVal The video ratio value to check the state of.
 * @returns Returns boolean to indicate the video ratio is active/selected.
 */
function stateRatio(ratioVal) {
    // Ratios and Decimal equivalents
    // Ratios:    "4:3" "16:10"  "16:9" "1.85:1" "2.35:1"
    // Decimal: "1.333" "1.600" "1.778"  "1.850"  "2.350"
    var ratioState = false;
    var ratioCur = round(propNative("video-aspect-override"), 3);

    if ((ratioVal === "-2") && (ratioCur === -2)) { ratioState = true; }
    else if ((ratioVal === "4:3") && (ratioCur === round(4/3, 3))) { ratioState = true; }
    else if ((ratioVal === "16:10") && (ratioCur === round(16/10, 3))) { ratioState = true; }
    else if ((ratioVal === "16:9") && (ratioCur === round(16/9, 3))) { ratioState = true; }
    else if ((ratioVal === "1.85:1") && (ratioCur === round(1.85/1, 3))) { ratioState = true; }
    else if ((ratioVal === "2.35:1") && (ratioCur === round(2.35/1, 3))) { ratioState = true; }

    return ratioState;
}

/**
 * Check the video rotate angle for the video rotate radio menu items.
 * @param {number} rotateVal The rotation angle number to check the state of.
 * @returns Returns boolean to indicate the video rotate angle is active/selected.
 */
function stateRotate(rotateVal) {
    var rotateState = false;
    var rotateCur = propNative("video-rotate");

    if (rotateVal === rotateCur) { rotateState = true; }

    return rotateState;
}

/**
 * Check the video alignment for the video alignment radio menu items.
 * @param {string} alignAxis The alignment axis ("x" or "y").
 * @param {number} alignPos The alignment position (-1 = X: Left, Y: Top, 0 = Center, 1 = X: Right, Y: Bottom ).
 * @returns Returns boolean to indicate the alignment is active/selected.
 */
function stateAlign(alignAxis, alignPos) {
    var alignState = false;
    var alignValX = propNative("video-align-x");
    var alignValY = propNative("video-align-y");

    if ((alignAxis === "y") && (alignPos === alignValY)) { alignState = true; }
    else if ((alignAxis === "x") && (alignPos === alignValX)) { alignState = true; }

    return alignState;
}

/**
 * Check the deinterlace state for the deinterlace radio menu items.
 * @param {boolean} deIntVal The deinterlace state to check for.
 * @returns Returns the deinterlace state.
 */
function stateDeInt(deIntVal) {
    var deIntState = false;
    var deIntCur = propNative("deinterlace");

    if (deIntVal === deIntCur) { deIntState = true };

    return deIntState;
}

/**
 * Check the video filter name to get the state of the video flip filter.
 * @param {string} flipVal String to check the video flip filter names for.
 * @returns Returns the state of the video flip filter name.
 */
function stateFlip(flipVal) {
    var vfState = false;
    var vfVals = propNative("vf");

    for (i in vfVals) {
        if (vfVals[i].hasOwnProperty("name") && vfVals[i].hasOwnProperty("enabled")) {
            if (vfVals[i]["name"] === flipVal && vfVals[i]["enabled"] === true) {
                vfState = true;
            }
        }
    }

    return vfState;
}

/**
 * Mute menu item label to indicate what the clicking on the menu this is associated with will do (mute if un-muted, un-mute if muted).
 * @returns Returns string to indicate what the menu will do.
 */
function muteLabel() { return propNative("mute") ? "Un-mute" : "Mute"; }

// Based on "mpv --audio-channels=help", reordered/renamed in part as per Bomi
var audioChannels = { 1: { 1: "Auto", 2: "auto"}, 2: { 1: "Auto (Safe)", 2: "auto-safe"}, 3: { 1: "Empty", 2: "empty"}, 4: { 1: "Mono", 2: "mono"}, 5: { 1: "Stereo", 2: "stereo"}, 6: { 1: "2.1ch", 2: "2.1"}, 7: { 1: "3.0ch", 2: "3.0"}, 8: { 1: "3.0ch (Back)", 2: "3.0(back)"}, 9: { 1: "3.1ch", 2: "3.1"}, 10: { 1: "3.1ch (Back)", 2: "3.1(back)"}, 11: { 1: "4.0ch", 2: "quad"}, 12: { 1: "4.0ch (Side)", 2: "quad(side)"}, 13: { 1: "4.0ch (Diamond)", 2: "4.0"}, 14: { 1: "4.1ch", 2: "4.1(alsa)"}, 15: { 1: "4.1ch (Diamond)", 2: "4.1"}, 16: { 1: "5.0ch", 2: "5.0(alsa)"}, 17: { 1: "5.0ch (Alt.)", 2: "5.0"}, 18: { 1: "5.0ch (Side)", 2: "5.0(side)"}, 19: { 1: "5.1ch", 2: "5.1(alsa)"}, 20: { 1: "5.1ch (Alt.)", 2: "5.1"}, 21: { 1: "5.1ch (Side)", 2: "5.1(side)"}, 22: { 1: "6.0ch", 2: "6.0"}, 23: { 1: "6.0ch (Front)", 2: "6.0(front)"}, 24: { 1: "6.0ch (Hexagonal)", 2: "hexagonal"}, 25: { 1: "6.1ch", 2: "6.1"}, 26: { 1: "6.1ch (Top)", 2: "6.1(top)"}, 27: { 1: "6.1ch (Back)", 2: "6.1(back)"}, 28: { 1: "6.1ch (Front)", 2: "6.1(front)"}, 29: { 1: "7.0ch", 2: "7.0"}, 30: { 1: "7.0ch (Back)", 2: "7.0(rear)"}, 31: { 1: "7.0ch (Front)", 2: "7.0(front)"}, 32: { 1: "7.1ch", 2: "7.1(alsa)"}, 33: { 1: "7.1ch (Alt.)", 2: "7.1"}, 34: { 1: "7.1ch (Wide)", 2: "7.1(wide)"}, 35: { 1: "7.1ch (Side)", 2: "7.1(wide-side)"}, 36: { 1: "7.1ch (Back)", 2: "7.1(rear)"}, 37: { 1: "8.0ch (Octagonal)", 2: "octagonal"} }

// Create audio key/value pairs to check against the native property
// e.g. audioPair["2.1"] = "2.1", etc.
var audioPair = {}
for (var i = 1; i <= len(audioChannels); i++) {
    audioPair[audioChannels[i][2]] = audioChannels[i][2]
}

/**
 * Check the audio channel state for the audio channel layout radio menu items.
 * @param {string} audVal The audioPair value (derived from "mpv --audio-channels=help") to check against audio-channels for.
 * @returns Returns boolean to indicate that the audio channel is active/selected.
 */
function stateAudChannel(audVal) {
    var audState = false;
    var audLayout = propNative("audio-channels");

    audState = (audioPair[audVal] === audLayout) ? true : false;

    return audState;
}

/**
 * Build the audio channel layout menu structure.
 * @returns Returns the audio channel layout menu structure.
 */
function audLayoutMenu() {
    var audLayoutMenuVal = {};

    for (var i = 1; i <= len(audioChannels); i++) {
        if (i === 3) { table.insert(audLayoutMenuVal, new menuItem(SEP)); }

        table.insert(audLayoutMenuVal, new menuItem(RAD, [audioChannels[i][1], "", "set audio-channels \"" + audioChannels[i][2] + "\""], function(ind) { return stateAudChannel(audioChannels[ind][2]); }(i), false, true));
    }

    return audLayoutMenuVal;
}

/**
 * Check the subtitle alignment location for the subtitle alignment radio menu items.
 * @param {string} subAlignVal The subtitle alignment location to check for ("top" or "bottom").
 * @returns Returns boolean to indicate that the subtitle alignment location is active/selected.
 */
function stateSubAlign(subAlignVal) {
    var subAlignState = false;
    var subAlignCur = propNative("sub-align-y");

    subAlignState = (subAlignVal === subAlignCur) ? true : false;

    return subAlignState;
}

/**
 * Checks if the subitles are displayed on letterbox (false) or video (true) for the radio menu items.
 * @param {boolean} subPosVal The subtitle position location to check for.
 * @returns Returns boolean to indicate that the subtitles position is active/selected.
 */
function stateSubPos(subPosVal) {
    var subPosState = false;
    var subPosCur = propNative("image-subs-video-resolution");

    subPosState = (subPosVal === subPosCur) ? true : false;

    return subPosState;
}

/**
 * Move the current playlist item in a nominated direction.
 * @param {string} direction Direction to move the playlist item ("up" or "down").
 */
function movePlaylist(direction) {
    var playlistPos = propNative("playlist-pos");
    var newPos = 0;
    // We'll remove 1 here to "0 index" the value since we're using it with playlist-pos
    var playlistCount = propNative("playlist-count") - 1;

    if (direction === "up") {
        newPos = playlistPos - 1
        if (playlistPos !== 0) {
            mp.commandv("plalist-move", playlistPos, newPos);
        } else {
            mp.osd_message("Can't move item up any further");
        }
    } else if (direction === "down") {
        if (playlistPos !== playlistCount) {
            newPos = playlistPos + 2;
            mp.commandv("plalist-move", playlistPos, newPos);
        } else {
            mp.osd_message("Can't move item down any further");
        }
    }
}

/**
 * Check the state of the playlist loop.
 * @returns Returns boolean to indicate if the playlist is set to loop.
 */
function statePlayLoop() {
    var loopState = false;
    var loopVal = propNative("loop-playlist");

    if (String(loopVal) !== "false") { loopState = true; }

    return loopState;
}

/**
 * Checks if the video is set to on top (true) or not (false).
 * @param {boolean} onTopVal The on top state to check for.
 * @returns Returns boolean to indicate that the on top state is active/selected.
 */
function stateOnTop(onTopVal) {
    var onTopState = false;
    var onTopCur = propNative("ontop");

    onTopState = (onTopVal === onTopCur) ? true : false;

    return onTopState;
}

/**
 * Check if a value passed is null or an empty string.
 * @param {any} itemVal The value to check.
 * @returns Returns boolean to indicate if the value is null or an empty string.
 */
function notEmpty(itemVal) {
    if (typeof(itemVal) === "boolean") { return true; }
    if (itemVal === null || itemVal === "") { return false; }
    return true;
}

/**
 * Tidy a keybinding key string against a defined list of keys.
 * @param {string} strKey The keybding key string to tidy
 * @returns Returns the key tidied up, e.g. changing case, expanding.
 */
function tidyKeys(strKey) {
    var key = strKey;

    switch(strKey) {
        case "SPACE": key = "Space"; break;
        case "SHARP": key = "#"; break;
        case "ENTER": key = "Enter"; break;
        case "TAB": key = "Tab"; break;
        case "BS": key = "Backspace"; break;
        case "DEL": key = "Delete"; break;
        case "INS": key = "Insert"; break;
        case "HOME": key = "Home"; break;
        case "END": key = "End"; break;
        case "PGUP": key = "PgUp"; break;
        case "PGDWN": key = "PgDown"; break;
        case "ESC": key = "Escape"; break;
        case "PRINT": key = "PrintScreen"; break;
        case "LEFT": key = "Left"; break;
        case "RIGHT": key = "Right"; break;
        case "UP": key = "Up"; break;
        case "DOWN": key = "Down"; break;
    }

    return key;
}

/**
 * @typedef {Object} Binding
 * @property {string} keybind - This is the textual representation of the keybind.
 * @property {string} label - This is the label to show on the menu.
 * @property {function|string} cmd - This is the command to run when the menu item is selected.
 */

/**
 * @type {Object<string, Binding>}
 */
var bindings = {}

/**
 * Get the list of input bindings, storing values defined in the input.conf
 */
function getBindings() {
    var inputBindings = propNative("input-bindings", []);
    for (var i = 0; i < len(inputBindings); i++) {
        var binding = inputBindings[i]
        var comment = binding.comment;
        var keybind = binding.key;
        var cmd = binding.cmd;

        var bindname = ""
        var label = ""

        if (comment && comment.split("|").length > 1) {
            bindprops = comment.split("|").map(function(el) { return el.trim(); });

            // If the MENU value is present it should only be one of the first two values
            if (bindprops.indexOf("MENU") !== -1) {
                bindprops.splice(0, (bindprops[1] === "MENU" ? 2 : 1));
            } else { continue }

            bindname = bindprops[0];
            label = bindprops[1];
        } else { continue }

        bindings[bindname] = {
            keybind: keybind,
            label: label,
            cmd: cmd
        }
    }
}

/**
 * Process the keybinds that should have already been retrieved. We also tidy up key bind text.
 */
function processKeybinds() {
    // No point processing keybindings if there's nothing to process
    if (len(bindings) === 0) { return }

    var keys = []

    // We want to match against capital letters and other Shift+Key combinations (US key layout)
    var shiftChars = /[A-Z~!@#$%\^&*\(\)_+\{\}|:"<>?]/

    for (var key in bindings) {
        keys = bindings[key].keybind.split("+");
        keyLen = keys.length;

        // Add "Shift" - Handle single character keybindings
        if (keyLen === 1 && keys[0].length === 1) {
            if (keys[0].match(shiftChars) !== null) {
                keys.unshift("Shift");
            } else {
                keys[0] = keys[0].toUpperCase();
            }
        }

        // Add "Shift" - Handle single characters that are the last part of a keybinding
        if (keyLen > 1 && keys[keyLen - 1].length === 1) {
            if (keys[keyLen - 1].match(shiftChars) !== null) {
                keys.splice(keyLen - 1, 0, "Shift");
            } else {
                keys[keyLen - 1] = keys[keyLen - 1].toUpperCase();
            }
        }

        // Tidy up keybinding text
        keys = keys.map(tidyKeys);

        // Join the keybinding text back together
        bindings[key].keybind = keys.join("+");
    }
}

/**
 * Rudimentary check to see if the menu name provided relates to a valid menu in the menuList object.
 * @param {string|function} menuName The menu name to check for.
 * @returns Returns boolean to indicate if the menu being accessed under menuName is valid.
 */
function checkMenu(menuName){
    if (typeof menuList[menuName] === "function") {
        osd("Menu name \"" + menuName + "\" is a function. Generate the menu and point to "
            + "the generated menu first.", 5);
        return false;
    }
    if (menuList.hasOwnProperty(menuName) && typeof menuList[menuName] !== "object") {
        osd("Menu name \"" + menuName + "\" isn't a valid menu name.", 5);
        return false;
    }
    return true;
}

/**
 * Resolve properties in a menu by menu name, creating new properties with the suffix "V". Will not resolve "itemType" or "command" properties.
 * @param {*} menuName Menu name to resolve properties for.
  */
function resolveProperties(menuName) {
    if (!checkMenu(menuName)) { return; }

    var menu = menuList[menuName];

    for (i = 1; i <= len(menu); i++) {
        if (menu[i].itemType === SEP) { continue; }

        for (var propKey in menu[i]) {
            // We won't resolve itemType or command items, but also don't want to resolve
            // property keys ending in V ("value" items)
            if (propKey === "itemTYpe" ||
                propKey === "command" ||
                propKey[propKey.length - 1] === "V") { continue; }
            menu[i][propKey + "V"] = typeof menu[i][propKey] === "function"
                ? menu[i][propKey]() : menu[i][propKey]
        }
    }
}

// NOTE: Global variables to be set in getMaxes and used elsewhere
var maxLabel = {}
var maxAccel = {}
var maxSep = {}

/**
 * Resolve the maximum lengths for various labels, accelerators, menu item lengths and seperator for the current menu.
 * @param {string} menuName Menu name to get resolve max lengths for.
 */
function getMaxes(menuName) {
    if (!checkMenu(menuName)) { return; }

    var menu = menuList[menuName];
    var maxItem = {};
    maxLabel[menuName] = 0;
    maxAccel[menuName] = 0;
    maxItem[menuName] = 0;

    // First we'll get the maximum label length for a menu item
    for (i = 1; i <= len(menu); i++) {
        if (SEP.indexOf(menu[i].itemType) === -1 && typeof menu[i].labelV !== "undefined") {
            if (menu[i].labelV.length > maxLabel[menuName]) { maxLabel[menuName] = menu[i].labelV.length; }
        }
    }

    // Now we'll get the maximum accelerator length for a menu item
    for (i = 1; i <= len(menu); i++) {
        if ([CSD, SEP].indexOf(menu[i].itemType) === -1 && typeof menu[i].acceleratorV !== "undefined") {
            if (menu[i].acceleratorV.length > maxAccel[menuName]) { maxAccel[menuName] = menu[i].acceleratorV.length; }
        }
    }

    // Based on the max label and max accelerator length for a menu item. add additional
    // values for pre-label (e.g checkbox) and label <-> accelerator seperation. Don't
    // include the extra for the accelerator cascade. We'll seperate the label and
    // accelerator by 4 spaces.
    maxItem[menuName] = 4 + maxLabel[menuName] + (maxAccel[menuName] === 0 ? 0 : 4) + maxAccel[menuName];

    // With the max length determined, we'll also set up the seperator for each menu so
    // it meets the length of label + space + accelerator but stop before the cascade.
    for (var seperator = ""; seperator.length < maxItem[menuName]; seperator += "-");
    maxSep[menuName] = seperator;
}

function makeLabel(menuName, label, accelerator, itemType) {
    if (typeof itemType !== "undefined" && itemType === SEP) { return }
    if (typeof accelerator === "undefined") { accelerator = ""; }
    var spacesCount = (maxLabel[menuName] - label.length) +
                        (maxAccel[menuName] === 0 ? 0 : 4) +
                        (maxAccel[menuName] - accelerator.length)
    for (var whiteSpace = ""; whiteSpace.length < spacesCount; whiteSpace += " ");
    return (label + whiteSpace + accelerator);
}

/**
 * Creates a menu item object.
 * @param {string} itemType The type of item, e.g. CSD, CMD, etc. If this is a SEP, leave all other values empty.
 * @param {string | [(function|string), string, (function|string)] | [function, string] | function} itemProps
 *  Can be various things, including either a string referencing a binding name to be accessed via the bindings object or an array of up to 3 values:
 *   - label: {function|string} The label for the item.
 *   - accelerator: {string} The text shortcut/accelerator for the item.
 *   - command: {function|string} This is the command to run when the item is clicked. Will be handled after the menu item is clicked on.
 *
 * Or an array of 2 values for bindings with a label function:
 *   - label: {function} The function to resolve the label.
 *   - binding: {string} A string representing the binding name to associate.
 *
 *  Or just a function:
 *   - itemDisable: {function} Used for seperators to determine if they should be visible.
 * @param {(boolean|string)} itemState The state of the item (selected/unselected). A/B Repeat is a special case.
 * @param {boolean} itemDisable Whether to disable.
 * @param {boolean} [reopenMenu] This is use to reopen/toggle the menu and is optional (only needed if desired for the menu item).
 */
function menuItem(itemType, itemProps, itemState, itemDisable, reopenMenu) {
    if (typeof itemType !== "undefined") { if (notEmpty(itemType)) { this.itemType = itemType; } }
    if (typeof itemProps !== "undefined") {
        if (typeof itemProps === "string" && bindings[itemProps]) {
            if (typeof bindings[itemProps].label !== "undefined") { if (notEmpty(bindings[itemProps].label)) { this.label = bindings[itemProps].label; }}
            if (typeof bindings[itemProps].keybind !== "undefined") { if (notEmpty(bindings[itemProps].keybind)) { this.accelerator = bindings[itemProps].keybind; }}
            if (typeof bindings[itemProps].cmd !== "undefined") { if (notEmpty(bindings[itemProps].cmd)) { this.command = bindings[itemProps].cmd; }}
        } else if (typeof itemProps === "string" && !bindings[itemProps]) {
            failMenu = true;
            failError = "No matching binding found for binding name: " + itemProps
        } else if (typeof itemProps === "object" && itemProps.length === 3) {
            if (typeof itemProps[0] !== "undefined") { if (notEmpty(itemProps[0])) { this.label = itemProps[0]; }}
            if (typeof itemProps[1] !== "undefined") { if (notEmpty(itemProps[1])) { this.accelerator = itemProps[1]; }}
            if (typeof itemProps[2] !== "undefined") { if (notEmpty(itemProps[2])) { this.command = itemProps[2]; }}
        } else if (typeof itemProps === "object" && itemProps.length === 2) {
            if (typeof itemProps[0] !== "undefined") { if (notEmpty(itemProps[0])) { this.label = itemProps[0]; }}
            if (typeof bindings[itemProps[1]].keybind !== "undefined") { if (notEmpty(bindings[itemProps[1]].keybind)) { this.accelerator = bindings[itemProps[1]].keybind; }}
            if (typeof bindings[itemProps[1]].cmd !== "undefined") { if (notEmpty(bindings[itemProps[1]].cmd)) { this.command = bindings[itemProps[1]].cmd; }}
        } else {
            this.label = ""
            this.accelerator = ""
            this.command = ""
        }
        if (typeof itemProps === "function") { itemDisable = itemProps; }
    }
    if (typeof itemState !== "undefined") { if (notEmpty(itemState)) { this.itemState = itemState; }}
    if (typeof itemDisable !== "undefined") { if (notEmpty(itemDisable)) { this.itemDisable = itemDisable; }}
    if (typeof reopenMenu !== "undefined") { if (notEmpty(reopenMenu)) { this.reopenMenu = reopenMenu; }}
}

/* ----------- Menu Structure Configuration Start ----------- */

// Set some initial objects, notably the menuList and a parentMap object and parentMenu string.
var menuList = {}
var parentMap = {};
var parentMenu = "";

// Get the bindings and then process them to add "Shift" and/or tidy them up when the
// script is loaded. We don't want to wait until the menu building function is called
// to run.
getBindings();
processKeybinds();
buildMenuMap();

/* The Menu Item structure is defined further above and the makeup should be viewed there due
 * to the complexity related with how menu items can be structured.
 */

// This is to be shown when nothing is open yet and is a small subset of the greater menu that
// will be overwritten when the full menu is created.
menuList = {
    context_menu: {
        1: new menuItem(CSD, ["Open", "open_menu", ""], "", false),
        2: new menuItem(SEP),
        3: new menuItem(CSD, ["Window", "window_menu", ""], "", false),
        4: new menuItem(SEP),
        5: new menuItem(CMD, ["Dismiss Menu", "", "ignore"], "", false),
        6: new menuItem(CMD, ["Quit", "", "quit"], "", false),
    },

    open_menu: {
        1: new menuItem(CMD, "openfile", "", false),
        2: new menuItem(CMD, "openfolder", "", false),
        3: new menuItem(CMD, ["URL", "", "script-binding mpvselectmenu/open_url_dialog"], "", false),
    },

    window_menu: {
        1: new menuItem(CSD, ["Stays on Top", "staysontop_menu", ""], "", false),
        2: new menuItem(CHK, ["Remove Frame", "", "cycle border"], function() { return !propNative("border"); }, false, true),
        3: new menuItem(SEP),
        4: new menuItem(CMD, "fstoggle", "", false, true),
        5: new menuItem(CMD, ["Enter Fullscreen", "", "set fullscreen \"yes\""], "", false, true),
        6: new menuItem(CMD, "fsexit", "", false, true),
        7: new menuItem(SEP),
        8: new menuItem(CMD, "close", "", false),
    },

    staysontop_menu: {
        1: new menuItem(CMD, ["Select Next", "", "cycle ontop"], "", false, true),
        2: new menuItem(SEP),
        3: new menuItem(RAD, ["Off", "", "set ontop \"yes\""], function() { return stateOnTop(false); }, false, true),
        4: new menuItem(RAD, ["On", "", "set ontop \"no\""], function() { return stateOnTop(true); }, false, true),
    },
}

// If mpv enters a stopped state, change the menu back to the "no file loaded" menu so that
// it will still popup.
menuListBase = menuList;
mp.register_event("end-file", function() {
    menuList = menuListBase;
})

// DO NOT create the "playing" menu tables until AFTER the file has loaded as we're unable to
// dynamically create some menus if it tries to build the table before the file is loaded.
// A prime example is the chapter-list or track-list values, which are unavailable until
// the file has been loaded.

mp.register_event("file-loaded", function() {
    menuList = {
        context_menu: {
            1: new menuItem(CSD, ["Open", "open_menu", ""], "", false),
            2: new menuItem(SEP),
            3: new menuItem(CSD, ["Play", "play_menu", ""], "", false),
            4: new menuItem(CSD, ["Video", "video_menu", ""], "", false),
            5: new menuItem(CSD, ["Audio", "audio_menu", ""], "", false),
            6: new menuItem(CSD, ["Subtitle", "subtitle_menu", ""], "", false),
            7: new menuItem(SEP),
            8: new menuItem(CSD, ["Tools", "tools_menu", ""], "", false),
            9: new menuItem(CSD, ["Window", "window_menu", ""], "", false),
            10: new menuItem(SEP),
            11: new menuItem(CMD, ["Dismiss Menu", "", "ignore"], "", false),
            12: new menuItem(CMD, ["Quit", "", "quit"], "", false),
        },

        open_menu: {
            1: new menuItem(CMD, "openfile", "", false),
            2: new menuItem(CMD, "openfolder", "", false),
            3: new menuItem(CMD, ["URL", "", "script-binding mpvselectmenu/open_url_dialog"], "", false),
        },

        play_menu: {
            1: new menuItem(CMD, "playpause", "", false, true),
            2: new menuItem(CMD, "stop", "", false),
            3: new menuItem(SEP),
            4: new menuItem(CMD, "playlistprev", "", false, true),
            5: new menuItem(CMD, "playlistnext", "", false, true),
            6: new menuItem(SEP),
            7: new menuItem(CSD, ["Speed", "speed_menu", ""], "", false),
            8: new menuItem(CSD, ["A-B Repeat", "abrepeat_menu", ""], "", false),
            9: new menuItem(SEP),
            10: new menuItem(CSD, ["Seek", "seek_menu", ""], "", false),
            11: new menuItem(CSD, ["Title/Edition", "edition_menu", ""], "", function() { return enableEdition() }),
            12: new menuItem(CSD, ["Chapter", "chapter_menu", ""], "", function() { return enableChapter() }),
        },

        speed_menu: {
            1: new menuItem(CMD, "resetspeed", "", false, true),
            2: new menuItem(SEP),
            3: new menuItem(CMD, "speedup", "", false, true),
            4: new menuItem(CMD, "speeddown", "", false, true),
        },

        abrepeat_menu: {
            1: new menuItem(ABC, [function () { return abLoopLabel(); }, "abloop"], function() { return stateABLoop(); }, false, true),
            2: new menuItem(CHK, ["Toggle Infinite Loop", "", "cycle-values loop-file \"inf\" \"no\""], function() { return stateFileLoop(); }, false, true),
        },

        seek_menu: {
            1: new menuItem(CMD, "seekbegin", "", false, true),
            2: new menuItem(CMD, "seekend", "", false, true),
            3: new menuItem(SEP),
            4: new menuItem(CMD, "seeksmlfwd", "", false, true),
            5: new menuItem(CMD, "seeksmlbck", "", false, true),
            6: new menuItem(CMD, "seekmedfwd", "", false, true),
            7: new menuItem(CMD, "seekmedbck", "", false, true),
            8: new menuItem(CMD, "seeklrgfwd", "", false, true),
            9: new menuItem(CMD, "seeklrgbck", "", false, true),
            10: new menuItem(SEP),
            11: new menuItem(CMD, "stepback", "", false, true),
            12: new menuItem(CMD, "stepforward", "", false, true),
            13: new menuItem(SEP),
            14: new menuItem(CMD, ["Previous Subtitle", "", "no-osd sub-seek -1"], "", false, true),
            15: new menuItem(CMD, ["Current Subtitle", "", "no-osd sub-seek 0"], "", false, true),
            16: new menuItem(CMD, ["Next Subtitle", "", "no-osd sub-seek 1"], "", false, true),
        },

        // Use functions returning tables, since we don't need these menus if there
        // aren't any editions or any chapters to seek through.
        edition_menu: function() { return editionMenu() },
        chapter_menu: function() { return chapterMenu() },

        video_menu: {
            1: new menuItem(CSD, ["Track", "vidtrack_menu", ""], "", function() { return enableVidTrack() }),
            2: new menuItem(SEP, function() { return enableVidTrack() }),
            3: new menuItem(CSD, ["Take Screenshot", "screenshot_menu", ""], "", false),
            4: new menuItem(SEP),
            5: new menuItem(CSD, ["Aspect Ratio", "aspect_menu", ""], "", false),
            6: new menuItem(CSD, ["Zoom", "zoom_menu", ""], "", false),
            7: new menuItem(CSD, ["Rotate", "rotate_menu", ""], "", false),
            8: new menuItem(CSD, ["Screen Position", "screenpos_menu", ""], "", false),
            9: new menuItem(CSD, ["Screen Alignment", "screenalign_menu", ""], "", false),
            10: new menuItem(SEP),
            11: new menuItem(CSD, ["Deinterlacing", "deint_menu", ""], "", false),
            12: new menuItem(CSD, ["Filter", "filter_menu", ""], "", false),
            13: new menuItem(CSD, ["Adjust Color", "color_menu", ""], "", false),
        },

        // Use function to return list of Video Tracks
        vidtrack_menu: function() { return vidTrackMenu() },

        screenshot_menu: {
            1: new menuItem(CMD, "screenshot", "", false),
            2: new menuItem(CMD, "screenshotvideo", "", false),
            3: new menuItem(CMD, "screenshotwindow", "", false),
        },

        aspect_menu: {
            1: new menuItem(CMD, "videoaspectreset", "", false, true),
            2: new menuItem(CMD, ["Select Next", "", "cycle-values video-aspect-override \"4:3\" \"16:10\" \"16:9\" \"1.85:1\" \"2.35:1\" \"-2\""], "", false, true),
            3: new menuItem(SEP),
            4: new menuItem(RAD, ["Original Aspect Ratio", "", "set video-aspect-override \"-2\""], function() { return stateRatio("-2"); }, false, true),
            5: new menuItem(SEP),
            6: new menuItem(RAD, ["4:3 (TV)", "", "set video-aspect-override \"4:3\""], function() { return stateRatio("4:3"); }, false, true),
            7: new menuItem(RAD, ["16:10 (Wide Monitor)", "", "set video-aspect-override \"16:10\""], function() { return stateRatio("16:10"); }, false, true),
            8: new menuItem(RAD, ["16:9 (HDTV)", "", "set video-aspect-override \"16:9\""], function() { return stateRatio("16:9"); }, false, true),
            9: new menuItem(RAD, ["1.85:1 (Wide Vision)", "", "set video-aspect-override \"1.85:1\""], function() { return stateRatio("1.85:1"); }, false, true),
            10: new menuItem(RAD, ["2.35:1 (CinemaScope)", "", "set video-aspect-override \"2.35:1\""], function() { return stateRatio("2.35:1"); }, false, true),
        },

        zoom_menu: {
            1: new menuItem(CMD, "zoomreset", "", false, true),
            2: new menuItem(SEP),
            3: new menuItem(CMD, "vidzoomin", "", false, true),
            4: new menuItem(CMD, "vidzoomout", "", false, true),
        },

        rotate_menu: {
            1: new menuItem(CMD, ["Reset", "", "set video-rotate \"0\""], "", false, true),
            2: new menuItem(CMD, ["Select Next", "", "cycle-values video-rotate \"0\" \"90\" \"180\" \"270\""], "", false, true),
            3: new menuItem(SEP),
            4: new menuItem(RAD, ["0°", "", "set video-rotate \"0\""], function() { return stateRotate(0); }, false, true),
            5: new menuItem(RAD, ["90°", "", "set video-rotate \"90\""], function() { return stateRotate(90); }, false, true),
            6: new menuItem(RAD, ["180°", "", "set video-rotate \"180\""], function() { return stateRotate(180); }, false, true),
            7: new menuItem(RAD, ["270°", "", "set video-rotate \"270\""], function() { return stateRotate(270); }, false, true),
        },

        screenpos_menu: {
            1: new menuItem(CMD, "panreset", "", false, true),
            2: new menuItem(SEP),
            3: new menuItem(CMD, "panleft", "", false, true),
            4: new menuItem(CMD, "panright", "", false, true),
            5: new menuItem(SEP),
            6: new menuItem(CMD, "panup", "", false, true),
            7: new menuItem(CMD, "pandown", "", false, true),
        },

        screenalign_menu: {
            // Y Values: -1 = Top, 0 = Vertical Center, 1 = Bottom
            // X Values: -1 = Left, 0 = Horizontal Center, 1 = Right
            1: new menuItem(RAD, ["Top", "", "no-osd set video-align-y -1"], function() { return stateAlign("y",-1); }, false, true),
            2: new menuItem(RAD, ["Vertical Center", "", "no-osd set video-align-y 0"], function() { return stateAlign("y",0); }, false, true),
            3: new menuItem(RAD, ["Bottom", "", "no-osd set video-align-y 1"], function() { return stateAlign("y",1); }, false, true),
            4: new menuItem(SEP),
            5: new menuItem(RAD, ["Left", "", "no-osd set video-align-x -1"], function() { return stateAlign("x",-1); }, false, true),
            6: new menuItem(RAD, ["Horizontal Center", "", "no-osd set video-align-x 0"], function() { return stateAlign("x",0); }, false, true),
            7: new menuItem(RAD, ["Right", "", "no-osd set video-align-x 1"], function() { return stateAlign("x",1); }, false, true),
        },

        deint_menu: {
            1: new menuItem(CMD, "deint", "", false, true),
            2: new menuItem(CMD, ["Auto", "", "set deinterlace \"auto\""], "", false, true),
            3: new menuItem(SEP),
            4: new menuItem(RAD, ["Off", "", "no-osd set deinterlace \"no\""], function() { return stateDeInt(false); }, false, true),
            5: new menuItem(RAD, ["On", "", "no-osd set deinterlace \"yes\""], function() { return stateDeInt(true); }, false, true),
        },

        filter_menu: {
            1: new menuItem(CHK, ["Flip Vertically", "", "no-osd vf toggle vflip"], function() { return stateFlip("vflip"); }, false, true),
            2: new menuItem(CHK, ["Flip Horizontally", "", "no-osd vf toggle hflip"], function() { return stateFlip("hflip"); }, false, true),
        },

        color_menu: {
            1: new menuItem(CMD, "colorreset", "", false, true),
            2: new menuItem(SEP),
            3: new menuItem(CMD, "colorbrightup", "", false, true),
            4: new menuItem(CMD, "colorbrightdown" , "", false, true),
            5: new menuItem(CMD, "colorconup", "", false, true),
            6: new menuItem(CMD, "colorcondown", "", false, true),
            7: new menuItem(CMD, "colorsatup", "", false, true),
            8: new menuItem(CMD, "colorsatdown", "", false, true),
            9: new menuItem(CMD, "colorhueup", "", false, true),
            10: new menuItem(CMD, "colorhuedown", "", false, true),
        },

        audio_menu: {
            1: new menuItem(CSD, ["Track", "audtrack_menu", ""], "", false),
            2: new menuItem(CSD, ["Sync", "audsync_menu", ""], "", false),
            3: new menuItem(SEP),
            4: new menuItem(CSD, ["Volume", "volume_menu", ""], "", false),
            5: new menuItem(CSD, ["Channel Layout", "channel_layout", ""], "", false),
        },

        // Use function to return list of Audio Tracks
        audtrack_menu: function() { return audTrackMenu() },

        audsync_menu: {
            1: new menuItem(CMD, "audsyncreset", "", false, true),
            2: new menuItem(SEP),
            3: new menuItem(CMD, "audsyncinc", "", false, true),
            4: new menuItem(CMD, "audsyncdec", "", false, true),
        },

        volume_menu: {
            1: new menuItem(CHK, [function() { return muteLabel(); }, "volmute"], function() { return propNative("mute"); }, false, true),
            2: new menuItem(SEP),
            3: new menuItem(CMD, "volup", "", false, true),
            4: new menuItem(CMD, "voldown", "", false, true),
        },

        // Use function to return audio channel layout menu
        channel_layout: function() { return audLayoutMenu() },

        subtitle_menu: {
            1: new menuItem(CSD, ["Track", "subtrack_menu", ""], "", false),
            2: new menuItem(SEP),
            3: new menuItem(CSD, ["Alightment", "subalign_menu", ""], "", false),
            4: new menuItem(CSD, ["Position", "subpos_menu", ""], "", false),
            5: new menuItem(CSD, ["Scale", "subscale_menu", ""], "", false),
            6: new menuItem(SEP),
            7: new menuItem(CSD, ["Sync", "subsync_menu", ""], "", false),
        },

        // Use function to return list of Subtitle Tracks
        subtrack_menu: function() { return subTrackMenu() },

        subalign_menu: {
            1: new menuItem(CMD, ["Select Next", "", "cycle-values sub-align-y \"top\" \"bottom\""], "", false, true),
            2: new menuItem(SEP),
            3: new menuItem(RAD, ["Top", "", "set sub-align-y \"top\""], function() { return stateSubAlign("top"); }, false, true),
            4: new menuItem(RAD, ["Bottom", "","set sub-align-y \"bottom\""], function() { return stateSubAlign("bottom"); }, false, true),
        },

        subpos_menu: {
            1: new menuItem(CMD, "subposreset", "", false, true),
            2: new menuItem(SEP),
            3: new menuItem(CMD, "subposup", "", false, true),
            4: new menuItem(CMD, "subposdown", "", false, true),
            5: new menuItem(SEP),
            6: new menuItem(RAD, ["Display on Letterbox", "", "set image-subs-video-resolution \"no\""], function() { return stateSubPos(false); }, false, true),
            7: new menuItem(RAD, ["Display in Video", "", "set image-subs-video-resolution \"yes\""], function() { return stateSubPos(true); }, false, true),
        },

        subscale_menu: {
            1: new menuItem(CMD, "subposreset", "", false, true),
            2: new menuItem(SEP),
            3: new menuItem(CMD, "subscaleinc", "", false, true),
            4: new menuItem(CMD, "subscaledec", "", false, true),
        },

        subsync_menu: {
            1: new menuItem(CMD, "subdelreset", "", false, true),
            2: new menuItem(SEP),
            3: new menuItem(CMD, "subdelinc", "", false, true),
            4: new menuItem(CMD, "subdeldec", "", false, true),
        },

        tools_menu: {
            1: new menuItem(CSD, ["Playlist", "playlist_menu", ""], "", false),
            2: new menuItem(CMD, ["Find Subtitle (Subit)", "", "script-binding subit/subit"], "", false),
            3: new menuItem(CMD, "stats", "", false),
            4: new menuItem(CMD, ["Open 'select' Menu", "", "script-binding select/menu"], "", false),
        },

        playlist_menu: {
            1: new menuItem(CMD, "playlistshow", "", false),
            2: new menuItem(SEP),
            3: new menuItem(CMD, ["Open", "", "script-binding mpvselectmenu/open_playlist_dialog"], "", false),
            4: new menuItem(CMD, ["Save", "", "script-binding playlistmanager/saveplaylist"], "", false),
            5: new menuItem(CMD, ["Regenerate", "", "script-binding playlistmanager/loadfiles"], "", false),
            6: new menuItem(CMD, "playlistclear", "", false),
            7: new menuItem(SEP),
            8: new menuItem(CMD, ["Append File", "", "script-binding mpvselectmenu/append_files_dialog"], "", false),
            9: new menuItem(CMD, ["Append URL", "", "script_binding mpvselectmenu/append_url_dialog"], "", false),
            10: new menuItem(CMD, ["Remove", "", "playlist-remove current"], "", false, true),
            11: new menuItem(SEP),
            12: new menuItem(CMD, ["Move Up", "", function() { movePlaylist("up"); }], "", function() { return (propNative("playlist-count") < 2) ? true : false; }, true),
            13: new menuItem(CMD, ["Move Down", "", function() { movePlaylist("down"); }], "", function() { return (propNative("playlist-count") < 2) ? true : false; }, true),
            14: new menuItem(SEP),
            15: new menuItem(CHK, ["Shuffle", "", "cycle shuffle"], function() { return propNative("shuffle"); }, false, true),
            16: new menuItem(CHK, ["Repeat", "", "cycle-values loop-playlist \"inf\" \"no\""], function() { return statePlayLoop(); }, false, true),
        },

        window_menu: {
            1: new menuItem(CSD, ["Stays on Top", "staysontop_menu", ""], "", false),
            2: new menuItem(CHK, ["Remove Frame", "", "cycle border"], function() { return !propNative("border"); }, false, true),
            3: new menuItem(SEP),
            4: new menuItem(CMD, "fstoggle", "", false, true),
            5: new menuItem(CMD, ["Enter Fullscreen", "", "set fullscreen \"yes\""], "", false, true),
            6: new menuItem(CMD, "fsexit", "", false, true),
            7: new menuItem(SEP),
            8: new menuItem(CMD, "close", "", false),
        },

        staysontop_menu: {
            1: new menuItem(CMD, ["Select Next", "", "cycle ontop"], "", false, true),
            2: new menuItem(SEP),
            3: new menuItem(RAD, ["Off", "", "set ontop \"yes\""], function() { return stateOnTop(false); }, false, true),
            4: new menuItem(RAD, ["On", "", "set ontop \"no\""], function() { return stateOnTop(true); }, false, true),
        },
    }

    // This check ensures that there are no "undefined objects"/missed menu item numbers.
    for (var key in menuList) {
        if (menuList.hasOwnProperty(key)) {
            // Check that the menu is an object (ignore functions/etc.) as the following for
            // loop will fail otherwise.
            if (typeof(menuList[key]) === "object") {
                for (var i = 1; i <= len(menuList[key]); i++) {
                    // Check that there are no undefined objects. This could happen if the objects
                    // are missing numbers, e.g. "1: menuItem, 3: menuItem", is missing "2: menuItem"
                    if (menuList[key][i] === undefined) {
                        mpdebug("Menu \"" + key + "\" with property/index \"" + i + "\" is undefined. Confirm that the property exists.")
                        mp.osd_message("Menu structure check failed!")
                        return;
                    }
                }
            }
        }
    }
})

function buildMenuMap() {
    var visited = {};
    var stack = ["context_menu"];

    while (stack.length > 0) {
        var currentMenu = stack.pop();
        visited[currentMenu] = true;

        var items = menuList[currentMenu];
        if (!items) { continue; }

        for (var key in items) {
            if (!items.hasOwnProperty(key)) { continue; }
            var item = items[key];

            // Only look at items that are cascading submenus
            if (item && item.itemType === CSD && typeof item.accelerator === "string") {
                var submenuName = item.accelerator;
                if (menuList.hasOwnProperty(submenuName) && !visited[submenuName]) {
                    parentMap[submenuName] = currentMenu;

                    // Menus that are functions need to have their +"V" menunames included.
                    if (typeof menuList[submenuName] === "function") {
                        parentMap[submenuName + "V"] = currentMenu;
                    }
                    stack.push(submenuName);
                }
            }
        }
    }

    return parentMap;
}

function createMenu(menuName) {
    // Fail if no menuName value is provided or if the failMenu variable is true with
    // output to the OSD to provide an idea of the problem.
    if (!menuList[menuName]) { osd("No menu name provided", 5); return; }
    if (failMenu === true) { osd(failError, 5); return; }

    // Let's check if the menu is a function and if so, generate the menu to a new menu
    // change where the menu then points to and then resolve properties and get max menu
    // item lengths for the current menu before we continue.
    if (typeof menuList[menuName] === "function") {
        menuList[menuName + "V"] = menuList[menuName]();
        menuName = menuName + "V";
    }

    // If we're reopening a generated menu ("value" menu), we need to regenerate it, since
    // the state of various menu items may have changed.
    if (menuName.slice(-1) === "V") {
        menuList[menuName] = menuList[menuName.slice(0, -1)]();
    }

    resolveProperties(menuName);
    getMaxes(menuName);

    // We need to rebuild the parentMap each time since we may have created more menus as
    // part of the createMenu function call.
    parentMap = {};
    buildMenuMap();

    // Checkbox / Radio Button / A/B Button text values here are to use for the respective
    // menu items since there don't appear to be good unicode characters options. For these
    // to work it's important that a monospace font is used for the menu items to appear
    // correctly and these are all 4 characters long.
    var boxCheck = "[X] "
    var boxEmpty = "[ ] "
    var boxA = "[A] "
    var boxB = "[B] "
    var radioSelect = "(X) "
    var radioEmpty = "( ) "
    // An empty prefix label that is only 4 spaces, the same length as check/radio/box labels.
    var emptyPre = "    "
    // Text to indicate a menu "cascade". FIXME: The extra spaces and text on the end is a fix
    // for menu items being cut off.
    var accelCascade = "  ❱  ?"

    // We need to resolve
    var menu = menuList[menuName]
    var items = []
    var commands = []

    for (var i = 1; i <= len(menu); i++) {
        var idx = i - 1;

        // Define the label prefix
        var labelPre = {
            separator: "",
            cascade: emptyPre,
            command: emptyPre,
            checkbox: menu[i].itemStateV === true ? boxCheck : boxEmpty,
            radiobutton: menu[i].itemStateV === true ? radioSelect : radioEmpty,
            "ab-check": menu[i].itemStateV !== "off" ? (menu[i].itemStateV === "a" ? boxA : boxB) : boxEmpty,
        }[menu[i].itemType] || emptyPre;

        // Add to the array of menu labels
        items[idx] = {
            // FIXME: The extra space is added to help in some menus to prevent menu item cut off.
            separator: maxSep[menuName] + " ",
            cascade: labelPre + makeLabel(menuName, menu[i].labelV, "", menu[i].itemType) + accelCascade,
        }[menu[i].itemType] || labelPre + makeLabel(menuName, menu[i].labelV, menu[i].acceleratorV)

        // Add to the array of commands
        if (menu[i].itemType !== CSD && menu[i].itemType !== SEP){
            // If the menu is to be reopened, we'll put the command in an array to check later.
            commands[idx] = menu[i].reopenMenuV === true ? [menu[i].command] : menu[i].command
        }

        if (menu[i].itemType === CSD) {
            commands[idx] = (function(index) {
                return function() { createMenu(menu[index].accelerator); };
            })(i);
        }

        if (menu[i].itemType === SEP) {
            commands[idx] = function() { createMenu(menuName) }
        }
    }

    // FIXME: These may be able to be removed in future, but are fixes to specific menus
    // that don't appear right, even accounting for other FIXME items used previously. The
    // fixes add spaces and/or text to the end of menu items to cause whatever width or
    // bounds checking to keep the text instead of cutting it off.
    items[0] += {
        screenshot_menu: "   ?",
        open_menu: "   ?",
    }[menuName] || "";

    items[1] += {
        filter_menu: " "
    }[menuName] || "";

    // FIXME: The "complete" argument is passed to ensure that the monospace_font is used in
    // mpv 0.41.0. Doesn't seem to cause issues currently, but it's unclear if this is the
    // correct way to do this, but it's left as such for now.
    input.select({
        keep_open: true,
        complete: true,
        prompt: "",
        items: items,
        opened:function() {
            parentMenu = parentMap.hasOwnProperty(menuName) ? parentMap[menuName] : "context_menu";
            for (var i = 0; i < binds.length; i++) {
                mp.add_forced_key_binding(binds[i], "menuback" + [i],
                    function () { createMenu(parentMenu) });
            }
        },
        submit: function(id) {
            var cmd = commands[id - 1]
            if (cmd !== null) {
                if (typeof cmd === "function") {
                    cmd();
                } else {
                    // As set earlier check if the command is an array to indicate
                    // reopening the menu.
                    if (typeof cmd !== "string") {
                        mp.command(cmd[0])
                        resolveProperties(menuName);
                        createMenu(menuName);
                    } else {
                        input.terminate();
                        mp.command(cmd)
                    }
                }
            }
        },
        closed: function() {
            for (var i = 0; i < binds.length; i++) {
                mp.remove_key_binding("menuback" + [i]);
            }
        },
    })
}

/**
 * This establishes a binding for the base menu only.
 */
mp.add_key_binding(null, "mpvselectmenu", function() {
    createMenu("context_menu");
})
