Native Navigation
======
A plugin for using some native components in a cordova app. Work in progress.

Some examples paired with an html implementation can be found in https://github.com/tqc/ChondricJS/tree/master/src/sharedui


## handleAction

The calling component needs to implement the handleAction callback, which will be called by any component with button-like behavior:

        window.NativeNav.handleAction = function(route, action) {
            console.log("Got message from native nav: " + route + " => " + action);
        };

The route and action parameters are both arbitrary strings defined by the app.An example from https://github.com/tqc/ChondricJS/blob/master/src/core.js that uses route to look up a scope and action as a statement which is valid on that scope:

    window.NativeNav.handleAction = function(route, action) {
        var routeScope = app.scopesForRoutes[route];
        if (routeScope) {
            routeScope.$apply(action);
        }
    };

## Action Sheet / Popup menu

    NativeNav.showPopupMenu(route, x, y, w, h, items);

Displays a simple popup menu.

x/y/w/h define where the popup will appear (iPad only). They can be obtained from button.getBoundingClientRect().

items is an array in the form

    [{
        title: "Item 1",
        action: "action1()"
    }]

See https://github.com/tqc/chondric-example/blob/master/apphtml/actionsheet.js for example.

## Navigation bar

    NativeNav.showNavbar(route, active, leftButtons, title, rightButtons, titleChanged)

active - true/false. Should show/hide the navbar, but doesn't do anything yet.
titleChanged - string naming a function. if the value is "titleChanged", handleAction will be called with action set to "titleChanged(\"New Title\")";

For an example of button formats see https://github.com/tqc/chondric-example/blob/master/apphtml/sharednavbar.js


## Native transitions

    NativeNav.startNativeTransition(transitionType, callback)

Current valid transition types are "popup" and "closepopup";

## Keyboard accessory

Partially implemented. Replaces the default form accessory bar with a UIToolbar

        NativeNav.setKeyboardAccessory(buttons)

        NativeNav.handleKeyboardAcessoryClick = function(keycode) {
            console.log("Got message from keyboard accessory: " + keycode);
        };