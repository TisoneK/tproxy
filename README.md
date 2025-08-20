# TProxy

TProxy is a lightweight **Proxy Manager** for Linux that lets you easily manage proxies for:

- 🌐 **Terminal session**
- 📦 **APT package manager**
- 🖥 **System-wide environment**
- 🛠 **Git**
- 🔄 **One-key Toggle (ON/OFF)**

No more manual editing of configs — set, disable, show, and toggle proxies with a simple menu.

---

## 🚀 Installation

Clone the repo and run the installer:

```bash
git clone https://github.com/TisoneK/tproxy.git
cd tproxy
chmod +x install.sh
./install.sh
````

This will install `tproxy` globally so you can call it from anywhere.

---

## 🛠 Usage

Run:

```bash
tproxy
```

### Main Menu

```
===== TProxy Manager =====
1) Set Proxy
2) Disable Proxy
3) Show Current Proxy
4) Toggle Proxy
5) Exit
==========================
```

---

## 🔑 Features

### 1. Set Proxy

Choose where to set the proxy:

* **Terminal** → temporary for current shell
* **APT** → `/etc/apt/apt.conf.d/proxy.conf`
* **System** → `/etc/environment`
* **Git** → `git config --global`
* **All** → apply everywhere at once

Example:

```bash
Enter proxy URL: http://127.0.0.1:8080
```

### 2. Disable Proxy

Removes proxy settings from:

* Terminal
* APT
* System
* Git
* Or all at once

### 3. Show Current Proxy

Displays the active proxy settings for **all managed components**.

### 4. 🔄 Toggle Proxy

One keypress to switch between:

* **Proxy ON** → applies last saved proxy everywhere
* **Proxy OFF** → disables proxy everywhere

The last proxy you set is saved in:

```
~/.tproxy.conf
```

---

## ⚡ Non-Interactive Usage

You can also run commands directly:

```bash
tproxy set all http://127.0.0.1:8080   # Set proxy everywhere
tproxy disable all                     # Disable proxy everywhere
tproxy toggle                          # Toggle proxy ON/OFF
tproxy show                            # Show current proxy status
```

---

## 🔒 Notes

* `APT` and `System-wide` changes require **sudo privileges**.
* `System proxy` changes require **logout/login** to take effect.
* Proxies are stored in `~/.tproxy.conf` for toggle functionality.

---

## 🧑‍💻 Author

**Tisone Kironget**
📧 [tisonkironget@gmail.com](mailto:tisonkironget@gmail.com)
🌍 [GitHub Profile](https://github.com/TisoneK)

---

## 📜 License

MIT License – feel free to use, modify, and share.

```

---

