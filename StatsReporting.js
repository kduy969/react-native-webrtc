"use strict";

import { NativeModules } from "react-native";
import EventTarget from "event-target-shim";
import EventEmitter from "./EventEmitter";

const { WebRTCModule } = NativeModules;

const STATS_REPORT_EVENTS = ["statsreportchanged"];

class StatsReporting extends EventTarget<STATS_REPORT_EVENTS> {
  startStatsReporting(duration: number) {
    WebRTCModule.startStatsReporting(duration);
    this._registerEvents();
  }

  stopStatsReporting() {
    WebRTCModule.stopStatsReporting();
    this._unregisterEvents();
  }

  _unregisterEvents() {
    this._subscriptions.forEach((e) => e.remove());
    this._subscriptions = [];
  }

  _registerEvents() {
    this._subscriptions = [
      EventEmitter.addListener("statsReportChanged", (ev) => {
        // Stats changed
        this.dispatchEvent({
          type: "statsreportchanged",
          ...ev,
        });
      }),
    ];
  }
}

export default new StatsReporting();
