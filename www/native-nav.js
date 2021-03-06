(function() {
    "use strict";
    var NativeNav = function() {
        var nn = this;

        var argscheck = require('cordova/argscheck'),
            utils = require('cordova/utils'),
            exec = require('cordova/exec');

        var _closeCallback = null;

        nn.showPopupMenu = function(route, x, y, w, h, items) {
            exec(null, null, "NativeNav", "showPopupMenu", [route, x, y, w, h, items]);
        };

        nn.showNavbar = function(route, active, leftButtons, title, rightButtons, titleChanged) {
            exec(null, null, "NativeNav", "showNavbar", [route, active, leftButtons, title, rightButtons, titleChanged]);
        };

        nn.showTabbar = function(route, active, buttons, selectedTab) {
            exec(null, null, "NativeNav", "showTabbar", [route, active, buttons, selectedTab]);
        };


        nn.handleAction = function(route, action) {
            console.log("Got message from native nav: " + route + " => " + action);
        };


        nn.closeModal = function() {
            console.log("Got modal close message from native nav");
            if (_closeCallback) _closeCallback();
        };

        nn.setCloseModalCallback = function(closeCallback) {
            _closeCallback = closeCallback;
        };

        nn.startNativeTransition = function(transitionType, originRect, callback, closeCallback) {
            _closeCallback = closeCallback;
            exec(
                function() {
                    console.log("during callback");
                    callback();
                }, null, "NativeNav", "startNativeTransition", [transitionType, originRect]);
        };

        nn.finishNativeTransition = function() {
            exec(null, null, "NativeNav", "finishNativeTransition", []);
        };

        nn.enablePagination = function() {
            exec(null, null, "NativeNav", "enablePagination", []);
        };

        nn.disablePagination = function() {
            exec(null, null, "NativeNav", "disablePagination", []);
        };

        nn.testTiming = function(msg) {
            console.log(msg);
        };


        nn.setValidGestures = function(gestures) {
            exec(null, null, "NativeNav", "setValidGestures", [gestures]);
        };

        nn.updateViewWithComponent = function(componentId) {
            // fill the frame with a side panel
            console.log("NativeNav requested component " + componentId);
        };

        nn.updateViewWithRoute = function(newRoute) {
            // move to the next route
            console.log("NativeNav requested route " + newRoute);
        };

        nn.cancelGesture = function() {
            console.log("Gesture canceled");
        };


        nn.setKeyboardAccessory = function(buttons) {
            exec(null, null, "NativeNav", "setKeyboardAccessory", [buttons]);
        };

        nn.setKeyboardAccessoryButtonState = function(buttonStates) {
            exec(null, null, "NativeNav", "setKeyboardAccessoryButtonState", [buttonStates]);
        };

        nn.handleKeyboardAcessoryClick = function(keycode) {
            console.log("Got message from keyboard accessory: " + keycode);
        };

        return nn;
    };

    module.exports = window.NativeNav = new NativeNav();
})();