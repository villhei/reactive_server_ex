// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

// import {socket} from './socket.js'

import Cycle from '@cycle/core';
import Rx from 'rx';
import {div, label, input, hr, h1, br, p, makeDOMDriver} from '@cycle/dom';
import {Socket} from "phoenix"

function channelDriver($input, driverName) {
    console.log('Call me?');
    return Rx.Observable.create(observer => {
        const socket = new Socket("/socket", {params: {guardian_token: window.userToken}});
        socket.connect();
        let channel = socket.channel("room:lobby", {guardian_token: window.userToken});

        channel.join()
            .receive("ok", resp => {
                console.log("Joined successfully", resp);
                let history = resp.history;
                history.forEach(msg => observer.onNext(msg));
            })
            .receive("error", resp => {
                console.log('error', resp);
                observer.onError(resp)
            });

        channel.on("new_msg", msg => {
            observer.onNext(msg)
        });

        $input.subscribe(function (msg) {
            console.log('sending', msg);
            channel.push("new_msg", {body: msg})
        });
    }).share();
}

function main(sources) {

    const channel$ = sources.Channel;

    channel$.subscribe(msg => console.log('Subs: ', msg));

    const DOMSink = sources.DOM.select('.message-field')
        .events('input')
        .map(ev => ev.target.value)
        .startWith('')
        .map(name =>
            div([
                div([
                    label('message:'),
                    input('.message-field', {attributes: {type: 'text'}}),
                    hr(),
                    h1('Message' + name)
                ])
            ])
        );

    const messagesOut = sources.DOM.select('.message-field')
        .events('keypress')
        .filter(ev => ev.keyCode === 13)
        .map(ev => ev.target.value);

    messagesOut.subscribe(msg => console.log('Subs: ', msg));

    console.log('not even')

    const redrawMsg$ = messagesOut.startWith('').map(msg => '');

    const messagesChat = channel$.scan((acc, msg) => acc.concat(msg), []).startWith([]);

    const state$ = Rx.Observable.combineLatest(messagesChat, redrawMsg$, function (mc, mo) {
        return {mc: mc, mo: mo};
    });

    const DOM = state$.map(function ({mc, mo}) {
        return div([
            div([
                mc.map(function (msg) {
                    return p(msg.sender + " : " + msg.message);
                })
            ]),
            div([
                label('message:'),
                input('.message-field', {attributes: {type: 'text'}})
            ])
        ]);
    });


    const sinks = {
        DOM: DOM,
        Channel: messagesOut
    };
    return sinks;
}

Cycle.run(main, {
    DOM: makeDOMDriver('#client-app-container'),
    Channel: channelDriver
});


