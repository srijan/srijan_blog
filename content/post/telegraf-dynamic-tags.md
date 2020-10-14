---
title: "Telegraf dynamic tags"
date: 2020-10-14T00:00:00+05:30
description: "Adding pacemaker cluster status as custom tags to telegraf input data"
draft: false
tags: ["telegraf", "influxdata", "influxdb", "pacemaker", "corosync", "linux", "devops"]
---

### Background

For a recent project, I wanted to add a custom tag to data coming in from a built-in input plugin for [telegraf](https://www.influxdata.com/time-series-platform/telegraf/).

The input plugin was the [procstat plugin](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/procstat), and the custom data was information from [pacemaker](https://clusterlabs.org/pacemaker/doc/) (a clustering solution for linux). I wanted to add a tag indicating if the current host was the "active" host in my active/passive setup.

For this, the best solution I came up with was to use a [recently released](https://www.influxdata.com/blog/telegraf-1-15-starlark-nginx-go-redfish-new-relic-mongodb/) [execd processor](https://github.com/influxdata/telegraf/tree/master/plugins/processors/execd) plugin for telegraf.


### How it works

The execd processor plugin runs an external program as a separate process and pipes metrics in to the process's STDIN and reads processed metrics from its STDOUT.

{{< figure src="/images/telegraf-plugins-interaction.svg" caption="Telegraf plugins interaction. [View Source](https://www.planttext.com/?text=TP9RRu8m5CVV-oawdp2PCfCzBTkY8d4cA0OmcqzD1nqsmPRqacc6ttr5A7Etyz2UzlpE_vnUnb9XeVI-05UKfONEY1O5t2bLoZlN5VXzc5ErqwzQ4f5ofWXJmvJltOYcM6HyHKb92jUx7QmBpDHc6RY250HBueu6DsOVUIO9KqR4iAoh19Djk4dGyo9vGe4_zrSpfm_0b6kMON5qkBo6lJ3kzU47WCRYerHaZ_o3SfJHpGL-Cq3IkXtsXJgKbLePPb7FS5tedB9U_oT53YJD3ENNCrmBdX8fkVYNvrerik7P-SrrJaGADBDTs3BmWco0DjBfMk84EhMBiwVbo32UbehlRRTjGYqNMRc6go2KAgCCmke22XeLsr9b45FT4k04WBbKmZ8eQBvJe7g0tyoiasD9O0Mg-tWR9_uIJUV82uCmUgp3q3vAUpTdq7z9_6Wr2T0V6UUaCBR7CRmfthG0ncOml-KJ)" >}}

Telegraf's [filtering parameters](https://github.com/influxdata/telegraf/blob/master/docs/CONFIGURATION.md#metric-filtering) can be used to select or limit data from which input plugins will go to this processor.


### The external program

The external program I wrote does the following:

1. Get pacemaker status and cache it for 10 seconds
2. Read a line from stdin
3. Append the required information as a tag in the data
4. Write it to stdout

The caching is just an optimization - it was more to do with decreasing polluting the logs than actual speed improvements.

```python:pacemaker_status.py
#!/usr/bin/python

from __future__ import print_function
from sys import stderr
import fileinput
import subprocess
import time

cache_value = None
cache_time = 0
resource_name = "VIP"

def get_crm_status():
    global cache_value, cache_time, resource_name
    ctime = time.time()
    if ctime - cache_time > 10:
        # print("Cache busted", file=stderr)
        try:
            crm_node = subprocess.check_output(["sudo", "/usr/sbin/crm_node", "-n"]).rstrip()
            crm_resource = subprocess.check_output(["sudo", "/usr/sbin/crm_resource", "-r", resource_name, "-W"]).rstrip()
            active_node = crm_resource.split(" ")[-1]
            if active_node == crm_node:
                cache_value = "active"
            else:
                cache_value = "inactive"
        except (OSError, IOError) as e:
            print("Exception: %s" % e, file=stderr)
            # Don't report active/inactive if crm commands are not found
            cache_value = None
        except Exception as e:
            print("Exception: %s" % e, file=stderr)
            # Report as inactive in other cases by default
            cache_value = "inactive"
        cache_time = ctime
    return cache_value

def lineprotocol_add_tag(line, key, value):
    first_comma = line.find(",")
    first_space = line.find(" ")
    if first_comma >= 0 and first_comma <= first_space:
        split_str = ","
    else:
        split_str = " "
    parts = line.split(split_str)
    first, rest = parts[0], parts[1:]
    first_new = first + "," + key + "=" + value
    return split_str.join([first_new] + rest)

for line in fileinput.input():
    line = line.rstrip()
    crm_status = get_crm_status()
    if crm_status:
        try:
            new_line = lineprotocol_add_tag(line, "crm_status", crm_status)
        except Exception as e:
            print("Exception: %s, Input: %s" % (e, line), file=stderr)
            new_line = line
    else:
        new_line = line

    print(new_line)

```

### Telegraf configuration

Here's a sample telegraf configuration that routes data from "system" plugin to execd processor plugin, and finally outputs to influxdb.

```toml:telegraf.conf.toml
[agent]
  interval = "30s"

[[inputs.cpu]]

[[inputs.system]]

[[processors.execd]]
  command = ["/usr/bin/python", "/etc/telegraf/scripts/pacemaker_status.py"]
  namepass = ["system"]

[[outputs.influxdb]]
  urls = ["http://127.0.0.1:8086"]
  database = "telegraf"
```

### Other types of dynamic tags

In this example, we wanted to get the value of the tag from an external program. If the tag can be calculated from the incoming data itself, then things are much simpler. There are [a lot of processor plugins](https://github.com/influxdata/telegraf/tree/release-1.15/plugins/processors), and many things can be achieved using just those.
