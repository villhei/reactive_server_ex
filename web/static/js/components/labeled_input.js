import Rx from 'rx';
import {div, span} from '@cycle/dom';
import Input from './controlled_input.js';

function LabeledInput(sources) {
    const props$ = sources.props$;
    const inputValue$ = sources.DOM
        .select('.message-input')
        .events('keypress')
        .filter(event => event.keyCode === 13)
        .map(ev => ev.target.value)
        .share()
        .startWith('');

    const input = Input({
        Props: Rx.Observable.of({
            className: 'message-input',
            placeholder: '',
            style: {}
        }).combineLatest(props$, (defaults, props) => Object.assign(defaults, props)),
        Assign: inputValue$.map(() => '')
    });

    const vtree$ = props$.combineLatest(input.DOM,
        (props, inputDOM) =>
            div('.labeled-input', [
                span('.label',
                    props.label
                ),
                inputDOM
            ])
    );

    const messages$ = inputValue$.filter(val => val.length > 0);

    const sinks = {
        DOM: vtree$,
        value$: messages$
    };
    return sinks;
}

export default LabeledInput