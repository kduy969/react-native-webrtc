"use strict";

import { NativeModules } from "react-native";
import EventTarget from "event-target-shim";
import EventEmitter from "./EventEmitter";

const { WebRTCModule } = NativeModules;

const STATS_REPORT_EVENTS = ["speaking", "stopspeaking"];

class StatsReporting extends EventTarget(STATS_REPORT_EVENTS) {
  startStatsReporting() {
    WebRTCModule.startStatsReporting();
    this._registerEvents();
  }

  stopStatsReporting() {
    WebRTCModule.stopStatsReporting();
    this._unregisterEvents();
  }

  _unregisterEvents() {
    if (!this._subscriptions) {
      return;
    }
    this._subscriptions.forEach((e) => e.remove());
    this._subscriptions = [];
  }

  _registerEvents() {
    this._subscriptions = [
      EventEmitter.addListener("speaking", (ev) => {
        // Stats changed
        this.dispatchEvent({ type: "speaking" });
      }),
      EventEmitter.addListener("stopSpeaking", (ev) => {
        // Stats changed
        this.dispatchEvent({ type: "stopspeaking" });
      }),
    ];
  }
}

export default new StatsReporting();
