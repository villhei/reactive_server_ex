import {Socket} from "phoenix"
import Rx from 'rx';

function PhoenixChannel(outgoing$) {
    return Rx.Observable.create(observer => {
        const socket = new Socket('/socket', {
            params: {
                guardian_token: window.userToken
            }
        });
        socket.connect();
        let channel = socket.channel('room:lobby', {guardian_token: window.userToken});
        channel.join()
            .receive('ok', resp => {
                let history = resp.history.reverse();
                history.forEach(msg => observer.onNext(msg));
            })
            .receive('error', resp => {
                observer.onError(resp);
            });

        channel.on('new_msg', msg => {
            observer.onNext(msg);
        });

        outgoing$.subscribe(msg =>
            channel.push('new_msg', {body: msg})
        );
    }).share();
}

export default PhoenixChannel