---
title: From YAML automation to an ESPHome component
description: Moving the behaviour of an ESP32 watering system from YAML packages into an ESPHome component, and what still needs work.
category_label: ESPHome
date: 2025-05-25 00:00:00 Z
tags:
- esphome
- esp32
- cpp
- home automation
layout: post
---

A watering system sounds like a small automation. Read the soil moisture, turn on a pump, wait a few seconds, and turn it off again. Then come the other conditions: how often should it run? Is it too cold? Is there enough light? What happens if I disable it while the pump is running?

In my [ESP32 watering system](https://github.com/manoamaro/esp32_watering_system), these decisions started in ESPHome YAML. As the configuration grew, I started moving the pump behaviour into a component.

This is still an experiment. The component has the outline of the controller, but it doesn't yet replace everything in the YAML version. I think that makes it a useful example: moving code is the easy part; deciding what the component should own takes more thought.

### Starting with a YAML package

The original configuration uses a package for each pump. Substitutions such as `${id}` and `${pin}` let me include the same package with different identifiers and hardware pins.

So reuse was already possible. I didn't need a component just to add another pump.

The package brings together the output, a valve, settings, sensor checks, scripts, and LVGL display controls. For example, this is the expression deciding whether automatic watering should be active:

{% highlight cpp %}
return id(pump_${id}_enabled_switch).state &&
       !id(pump_${id}_is_soil_wet).state &&
       id(pump_${id}_has_light).state &&
       !id(pump_${id}_is_cold).state &&
       id(pump_${id}_is_time).state;
{% endhighlight %}

Each condition has a fairly simple meaning. The pump must be enabled, the soil must need water, the light and temperature must be suitable, and the watering window must be open.

The harder part is following what happens around that expression. A setting changes a display widget. A binary sensor opens a valve. A script handles a manual run. Another expression calculates the countdown until the next run.

YAML is still describing the system, but understanding the pump now means following several entities and callbacks through a large file.

### Choosing the component boundary

What I want is a pump controller that knows when to start and stop. The display should show its state and change its settings, without also being responsible for the watering rules.

There are three different concerns here:

- Hardware configuration: which output drives the pump and where sensor readings come from.
- Pump behaviour: whether watering is allowed, when it starts, and when it ends.
- Presentation: switches, labels, countdowns, and controls on the display.

The component is where I want the second part to live. YAML still connects the pieces, and ESPHome entities still expose the controls.

### Loading the component locally

ESPHome supports [external components](https://esphome.io/components/external_components/) from local directories as well as Git repositories. For this experiment, the component lives next to the node configuration:

```text
esphome/
  watering_system_v2.yaml
  components/
    pump/
      __init__.py
      pump.h
      pump.cpp
```

The configuration loads that directory with:

{% highlight yaml %}
external_components:
  - source:
      type: local
      path: components
{% endhighlight %}

This lets me work on the YAML and component together. It doesn't mean that the component is part of ESPHome itself, or that another device will have it available without the same source files.

### Why there is Python in an ESP32 component

The Python file doesn't run on the ESP32. It describes the configuration and generates the C++ wiring during the build. The C++ class contains the runtime behaviour. ESPHome's [component architecture documentation](https://developers.esphome.io/architecture/components/) explains this split through `CONFIG_SCHEMA` and `to_code`.

For example, the pump needs an existing floating-point output. Its schema declares that relationship:

{% highlight python %}
cv.Required(CONF_PUMP_OUTPUT): cv.use_id(output.FloatOutput),
{% endhighlight %}

Then `to_code` resolves the configured ID and passes the output to the pump:

{% highlight python %}
pump_output = await cg.get_variable(pump_config[CONF_PUMP_OUTPUT])
cg.add(var.set_pump_output(pump_output))
{% endhighlight %}

The component doesn't need to know the GPIO pin or how that output was configured. It receives an output that it can control.

The same file creates number entities for settings such as duration, frequency, and maximum soil moisture. For example, the duration is exposed in seconds:

{% highlight python %}
duration_number_var = await number.new_number(
    pump_config[CONF_RUN_DURATION],
    min_value=0,
    max_value=60 * 10,
    step=5,
)
cg.add(var.set_duration_number(duration_number_var))
{% endhighlight %}

These are excerpts from the prototype, rather than a complete component definition. There is still a mismatch to fix: several settings are optional in the schema but are accessed unconditionally in `to_code`. Either they need to be required, or the implementation needs to handle their absence.

### Moving the decisions into C++

The current `Pump::loop()` checks whether the pump is enabled and automatic mode is active. It then checks the schedule and reads the soil, light, and temperature values.

The central condition is recognisable from the YAML version:

{% highlight cpp %}
if (curr_soil < max_moisture && curr_light > min_light &&
    curr_temperature > min_temperature && now <= end_run) {
  // Start the output if the pump isn't already running.
} else {
  // Stop the output and update the running state.
}
{% endhighlight %}

This is an abbreviated excerpt. The useful change is that the watering decision and its resulting state now have a home in one class.

The controller uses `millis()` to check time as the loop runs, instead of waiting inside the function for an entire watering cycle. But that introduces a scheduling decision too. The YAML version uses wall-clock timestamps; the prototype uses device uptime. A restart changes the meaning of the schedule, so I still need to decide what should happen after boot.

### The migration isn't finished

Putting the logic in C++ doesn't automatically make it correct. Looking at the prototype makes a few problems quite visible.

For example, the duration and frequency are converted to milliseconds and stored in `int16_t`. A signed 16-bit integer only holds values up to 32,767. One minute is already 60,000 milliseconds, so it cannot represent even that interval correctly. The allowed settings go much further than one minute.

The timing needs an appropriate unsigned type, explicit initial state, and elapsed-time comparisons that account for the counter wrapping. Changing the type alone wouldn't settle the scheduling behaviour.

Stopping also needs to be an explicit operation. At the moment, disabling the pump makes the loop return early. That doesn't turn off an output which was already running. Turning automatic mode off has a similar gap.

I want those transitions to go through the same stop operation, so the hardware output and the reported running state stay together.

There are also differences from the original package. The YAML checks an upper light limit, controls pump power, and provides a manual-run script. The new loop doesn't reproduce all of that yet. The example node also supplies fixed sensor values, which are useful scaffolding but don't demonstrate watering from live readings.

Before treating this as a replacement, I would check the behaviour with controlled inputs: dry and wet soil, unsuitable temperature, a completed watering interval, disabling during a run, invalid sensor readings, and restarting the device. Then the output and timing need to be verified on hardware.

### What I want to keep in YAML

I still want YAML to describe the device: its pins, sensors, display, and the connections between them. Packages remain useful for sharing that configuration.

The reason for introducing a component is more specific. When I change a watering rule, I want to find it in the pump controller. When I change a label or rearrange the screen, I want that to stay a display change.

The prototype hasn't reached that point completely, but it gives the remaining work a clearer shape. I can review the pump's behaviour as a controller, then connect it to the rest of the device.
