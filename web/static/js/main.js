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

import {socket} from './socket.js'

import Cycle from '@cycle/core';
import {div, label, input, hr, h1, makeDOMDriver} from '@cycle/dom';

function main(sources) {
  const sinks = {
    DOM: sources.DOM.select('.field').events('input')
        .map(ev => ev.target.value)
        .startWith('')
        .map(name =>
            div([
              label('Name:'),
              input('.field', {attributes: {type: 'text'}}),
              hr(),
              h1('Hello ' + name),
            ])
        )
  };
  return sinks;
}

Cycle.run(main, { DOM: makeDOMDriver('#app-container') });
App.run();
