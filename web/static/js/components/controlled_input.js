import Rx from 'rx';
import {h} from '@cycle/dom';

function Input(sources) {
    function ControlledInputHook(injectedText) {
        this.injectedText = injectedText
    }

    ControlledInputHook.prototype.hook = function hook(element) {
        if (this.injectedText !== null) {
            element.value = this.injectedText
        }
    };

    const props$ = sources.Props;
    const assignValue$ = sources.Assign;
    const vtree$ = assignValue$
        .flatMap(value => Rx.Observable.of(value, null))
        .startWith(null)
        .withLatestFrom(props$, (value, props) =>
            h('input.' + props.className, {
                    type: 'text',
                    style: props.style,
                    placeholder: props.placeholder,
                    'data-hook': new ControlledInputHook(value)
                }
            )
        );
    return {
        DOM: vtree$
    };
}

export default Input