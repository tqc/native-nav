(function() {
    "use strict";
    var NativeNav = function() {
        var nn = this;

        var argscheck = require('cordova/argscheck'),
            utils = require('cordova/utils'),
            exec = require('cordova/exec');


        // status will be:
        // unlinked
        // firstSync
        // syncing
        // synced

        nn.showPopupMenu = function(route, x, y, w, h, items) {
            exec(null, null, "NativeNav", "showPopupMenu", [route, x, y, w, h, items]);
        };

        nn.showNavbar = function(route, active, leftButtons, title, rightButtons, titleChanged) {
            exec(null, null, "NativeNav", "showNavbar", [route, active, leftButtons, title, rightButtons, titleChanged]);
        };

        nn.handleAction = function(route, action) {
            console.log("Got message from native nav: " + route + " => " + action);
        };


        nn.startNativeTransition = function(transitionType, callback) {
            exec(callback, null, "NativeNav", "startNativeTransition", [transitionType]);
        };


        nn.setKeyboardAccessory = function(buttons) {
            exec(null, null, "NativeNav", "setKeyboardAccessory", [buttons]);
        };

        nn.handleKeyboardAcessoryClick = function(keycode) {
            console.log("Got message from keyboard accessory: " + keycode);
        };

        return nn;
    };

    module.exports = window.NativeNav = new NativeNav();
})();