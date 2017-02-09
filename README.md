ESP32 LED Control App for iOS
=============================

[I created an app](https://github.com/oneam/esp32_led_ring) for ESP32 DevKitC that allows controlling a WS2812B powered LED ring via [CoAP](http://coap.technology)

This app implements the CoAP client to control the LEDs and displays some simple debug information.

Building
--------

### Method A
If you haven't already cloned the repo. Clone the repo in `--recursive` mode
```
git clone --recursive https://github.com/oneam/Esp32LedControl.git
```

### Method B
If you've already cloned the repo without using `--recursive` you need to initialize the remote [SwiftCoAP](https://github.com/stuffrabbit/SwiftCoAP) repo:

```
git submodule init
git submodule update --remote
```

Then open the project in XCode and enjoy.
