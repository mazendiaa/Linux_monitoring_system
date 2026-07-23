# Linux System Monitoring

A lightweight Linux system monitoring tool built with **Bash** that collects and displays real-time system metrics using the Linux `/proc` filesystem.

The project provides a live terminal dashboard, configurable resource alerts, historical metrics logging, and performance reporting while relying only on standard Linux utilities.

---

## Preview

### Live Dashboard

![Dashboard](docs/normal case screen.png)
![Dashboard](docs/stress Screen dashboard.png)

### Demo

![Demo](docs/dashboard record.gif)

---

# Features

- Real-time CPU monitoring
- Memory usage monitoring
- Disk usage monitoring
- System uptime and load average
- Network traffic monitoring
- Top CPU-consuming processes
- Top memory-consuming processes
- Configurable resource thresholds
- Terminal-based dashboard
- Alert system with cooldown support
- Historical metrics logging (CSV)
- Performance report generation

---

# Project Structure

```text
linux_monitoring_system/
│
├── config/
│   └── config.conf
│
├── data/
│   └── metrics.csv
│
├── docs/
│   ├── dashboard_snapshot.png
│   └── demo_GIF.gif
│
├── logs/
│   └── app.log
│
├── reports/
│   └── performance_report.txt
│
└── src/
    ├── collectors/
    ├── analyzers/
    ├── alerts/
    ├── dashboard/
    └── reports/
```

---

# How It Works

Each monitoring cycle consists of four steps:

1. Collect system metrics from `/proc` and standard Linux utilities.
2. Store collected data in a CSV file.
3. Compare current values with configured thresholds.
4. Update the dashboard and display alerts when thresholds are exceeded.

---

# Metrics Collected

- CPU Usage
- Memory Usage
- Disk Usage
- System Uptime
- Load Average
- Network RX/TX
- Top CPU Processes
- Top Memory Processes

---

# Configuration

Application settings are stored in:

```text
config/config.conf
```

You can configure:

- CPU usage threshold
- Memory usage threshold
- Disk usage threshold
- Dashboard refresh interval
- Alert cooldown period

---

# Logs and Reports

Runtime logs:

```text
logs/app.log
```

Historical metrics:

```text
data/metrics.csv
```

Generated reports:

```text
reports/performance_report.txt
```

---

# Technologies

- Bash
- Linux `/proc` filesystem
- awk
- grep
- sed
- df
- tput
- ANSI escape sequences

---

# Getting Started

Clone the repository:

```bash
git clone https://github.com/mazendiaa/Linux_monitoring_system.git
cd Linux_monitoring_system
```

Make the scripts executable:

```bash
chmod +x *.sh
```

Run the application:

```bash
./main.sh
```

---

# Learning Objectives

This project was built to practice:

- Bash scripting
- Linux system administration
- Reading kernel information from `/proc`
- Process monitoring
- System resource analysis
- Log management
- Writing modular shell scripts

---

# Future Improvements

- Email notifications
- Export metrics in JSON format
- Docker support
- systemd service integration
- Web-based dashboard

---

## Author

**Mazen Diaa**

Computer Science Student | Linux & DevOps Enthusiast
