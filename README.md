---

# tproxy

A lightweight **Proxy Manager** for Linux that helps you quickly **set, disable, toggle, and view** proxy settings for:

* 🌐 **Terminal (session environment variables)**
* 📦 **APT (package manager)**
* 🖥️ **System-wide (/etc/environment)**

Supports **interactive menu** and **non-interactive commands**.

---

## 🚀 Installation

Clone the repo and install:

```bash
git clone https://github.com/TisoneK/tproxy.git
cd tproxy
chmod +x install.sh
./install.sh
```

This installs `tproxy` into `/usr/local/bin/` so you can run it globally.

---

## 🎮 Usage

### Interactive Mode

Run:

```bash
tproxy
```

You’ll get a simple menu:

```
===== Proxy Manager =====
1) Set Proxy
2) Disable Proxy
3) Toggle Proxy
4) Show Current Proxy
5) Exit
=========================
```

---

### Non-Interactive Mode

You can also run direct commands without menus.

#### Set Proxy

```bash
tproxy set terminal http://192.168.145.154:44355
tproxy set apt http://192.168.145.154:44355
tproxy set system http://192.168.145.154:44355
tproxy set all http://192.168.145.154:44355
```

#### Disable Proxy

```bash
tproxy disable terminal
tproxy disable apt
tproxy disable system
tproxy disable all
```

#### Toggle Proxy

```bash
tproxy toggle
```

* If a proxy is active → disables it.
* If no proxy is active → re-applies last saved config from `~/.proxy_manager.conf`.

#### Show Current Proxy

```bash
tproxy show
```

---

## ⚙️ Requirements

* Linux system
* `bash` shell
* `sudo` privileges (for APT and system-wide proxy changes)

---

## 📂 Files

* `tproxy.sh` → Main script
* `install.sh` → Installer (copies script to `/usr/local/bin/tproxy`)
* `~/.proxy_manager.conf` → Stores last used proxy for toggle functionality

---

## 📝 License

MIT License – free to use, modify, and distribute.

---

🔥 With **tproxy**, switching proxies is now as easy as **one command**.

---

