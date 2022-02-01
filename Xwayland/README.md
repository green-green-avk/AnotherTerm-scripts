# **Xwayland** startup scripts with international keyboard and clipboard support

## Usage

Minimal Another&nbsp;Term version: <kbd>MkIV-dev16</kbd>

Under your prooted environment:

* Make sure that you have installed:

  * `python3`
  * `Xlib` module for `python3`
  * `xdotool`

* Put scripts from `root` into `/root`;

* Put scripts from `user` into `/home/<your_acct>`;

* Put content of `opt` into `/opt`;

* Create a session profile to run this:

```sh
/system/bin/sh \
"$DATA_DIR/proots/linuxcontainers-debian-buster/run" \
0:0 ./wlstart-X \
| \
/system/bin/sh \
"$DATA_DIR/proots/linuxcontainers-debian-buster/run" \
'' ./wlstart-WM
```
