# Awesome

Test config with Xephyr:

```
Xephyr -ac -br -noreset -screen 1024x600 :1 &
DISPLAY=:1.0 awesome -c ~/.config/awesome/rc.lua
```
