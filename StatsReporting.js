'use strict';

import { NativeModules } from 'react-native';

const { WebRTCModule } = NativeModules;

class StatsReporting {
    startStatsReporting(duration: number) {
        WebRTCModule.startStatsReporting(duration);
    }

    stopStatsReporting() {
        WebRTCModule.stopStatsReporting();
    }
}

export default new StatsReporting();
