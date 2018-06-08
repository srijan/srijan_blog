+++
date = "2018-06-09T00:26:00+05:30"
title = "Riemann and Zabbix: Sending data from riemann to zabbix"
tags = ["riemann", "zabbix", "monitoring", "clojure"]
+++

### Background

At [my work][1], we use [Riemann][2] and [Zabbix][3] as part of our monitoring stack.

Riemann is a stream processing engine (written in Clojure) which can be used to
monitor distributed systems. Although it can be used for defining alerts and
sending notifications for those alerts, we currently use it like this:

1. As a receiving point for metrics / data from a group of systems in an
   installation
2. Applying some filtering and aggregation at the installation level.
3. Sending the filtered / aggregated data to a central Zabbix system.

The actual alerting mechanism is handled by Zabbix. Things like trigger
definitions, sending notifications, handling acks and escalations, etc.

This might seem like Riemann is redundant (and there is definitely some overlap
in functionality), but keeping Riemann in the data pipeline allows us to be more
flexible operationally. This is specially in cases when the metrics data we need
is coming from application code, and we need to apply some transformations to
the data but cannot update the code.

### The Problem

The first problem we faced when trying to do this is: sending data from Riemann
to Zabbix is not that straightforward.

Surprisingly, the [Zabbix API][4] is not actually meant for sending data points
to Zabbix - only for managing it's configuration and accessing historical data.

### Solutions

The recommended way to send data to Zabbix is to use a command line application
called [zabbix_sender][5].

Another way would be to write a custom zabbix client in Clojure which follows
the [Zabbix Agent protocol][6], which uses JSON over TCP sockets.

The current solution we have taken for this is using `zabbix_sender` itself.

For this, we write filtered values to a predefined text file from Riemann in a
format that `zabbix_sender` can understand.

```clojure
(def zabbix-logger
  (io (zabbix-logger-init
       "zabbix" "/var/log/riemann/to_zabbix.txt")))
       
(streams
  (where (tagged "zabbix")
    (smap
     (fn [event]
       {:zhost  (:host event)
        :zkey   (:service event)
        :zvalue (:value event)})
     zabbix-sender)))

(defn zabbix-sender
  "Sends events to zabbix via log file.
  Assumes that three keys are present in the incoming data:
    :zhost   -> hostname for sending to zabbix
    :zkey    -> item key for zabbix
    :zvalue  -> value to send for the item key
  Requires zabbix_sender service running and tailing the log file"
  [data]
  (io (zabbix-log-to-file
       zabbix-logger (str (:zhost data) " " (:zkey data) " " (:zvalue data)))))

;; Modified version of:
;; https://github.com/riemann/riemann/blob/68f126ff39819afc3296bb645243f888dab0943e/src/riemann/logging.clj
(defn zabbix-logger-init
  [log_key log_file]
  (let [logger (org.slf4j.LoggerFactory/getLogger log_key)]
    (.detachAndStopAllAppenders logger)
    (riemann.logging/configure-from-opts
     logger
     (org.slf4j.LoggerFactory/getILoggerFactory)
     {:file log_file})
    logger))

(defn zabbix-log-to-file
  [logger string]
  "Log to file using `logger`"
  (.info logger string))
```

The above code writes data into the file `/var/log/riemann/to_zabbix.txt` in the
following format:
```
INFO [2018-06-09 05:02:03,600] defaultEventExecutorGroup-2-7 - zabbix - host123 api.req-rate 200
```

Then, the following script can be run to sending data from this file to Zabbix via `zabbix_sender`:

```
tail -F /var/log/riemann/to_zabbix.txt | grep --line-buffered -oP "(?<=zabbix - ).*" | zabbix_sender -z $ZABBIX_IP --real-time -i - -vv
```

### Further Thoughts

- There should probably be a check on Riemann whether data is correctly being
  delivered to Zabbix or not. If not, Riemann can send out alerts as well.
- The current solution is a little fragile because it's first writing the data
  to a file and is dependent on an external service running to ship the data to
  Zabbix. A better solution would be to integrate directly as a Zabbix agent.
  

[1]: https://www.greyorange.com/
[2]: http://riemann.io/
[3]: https://www.zabbix.com/
[4]: https://www.zabbix.com/documentation/3.4/manual/api
[5]: https://www.zabbix.com/documentation/3.4/manpages/zabbix_sender
[6]: https://www.zabbix.com/documentation/3.4/manual/appendix/items/activepassive
