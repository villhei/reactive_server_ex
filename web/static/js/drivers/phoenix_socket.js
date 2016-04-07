import {Socket} from "phoenix"
import Rx from 'rx';

export function makePhoenixChannelDriver(channelName) {
    return function(outgoing$, driverName) {
        return PhoenixChannel(outgoing$, channelName);
    };
}

export function PhoenixChannel(outgoing$, channelName) {
    const defaultChannel = 'lobby';
    return Rx.Observable.create(observer => {
        // Init socket
        const socket = new Socket('/socket', {
            params: {
                guardian_token: window.userToken
            }
        });
        socket.connect();
        
        // Init and join a channel
        let channel = socket.channel('room:' + channelName || defaultChannel , {guardian_token: window.userToken});
        channel.join()
            .receive('ok', resp => {
                let history = resp.history.reverse();
                history.forEach(msg => observer.onNext(msg));
            })
            .receive('error', resp => {
                observer.onError(resp);
            });
            
        // Interface with the surrounding world

        channel.on('new_msg', msg => {
            observer.onNext(msg);
        });

        outgoing$.subscribe(msg =>
            channel.push('new_msg', {body: msg})
        );
    }).share();
}
