# **Xwayland** startup scripts with international keyboard and clipboard support

Details: <https://green-green-avk.github.io/AnotherTerm-docs/graphical-sessions.html#how-to-use>

## Usage

Minimal Another&nbsp;Term version: [<kbd>MkIV-dev16</kbd>](https://github.com/green-green-avk/AnotherTerm/releases/tag/MkIV_dev16_release)

Under your prooted environment:

* Make sure that you have installed:

  * `python3`
  * `Xlib` module for `python3`
  * `xdotool`

* Make sure that you have installed [**libwrapdroid**](https://github.com/green-green-avk/libwrapdroid);
  <br/>*See description [here](https://green-green-avk.github.io/AnotherTerm-docs/installing-linux-apis-emulation-for-nonrooted-android.html#main_content)
  and let these scripts to take care of the **libwrapdroid** environment and server startup*

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

Just replace the `linuxcontainers-debian-buster` with your installation directory.
