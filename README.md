# Linux System Monitoring

A lightweight Linux system monitoring tool built with **Bash** that collects and displays real-time system metrics using the Linux `/proc` filesystem.

The project provides a live terminal dashboard, configurable resource alerts, historical metrics logging, performance reporting, and optional email notifications.

---

## Preview

### Normal Case — Live Dashboard

![Terminal dashboard displaying CPU memory disk usage network traffic and load averages with colored bars and status panels](./docs/normal%20case%20screen.png)

### Stress Test — Live Dashboard

![Terminal dashboard during stress test showing elevated CPU and memory usage warnings and system metrics in colored blocks](./docs/stress%20Screen%20dashboard.png)

### Demo

![Animated walkthrough of the monitoring dashboard updating system metrics in the terminal with changing charts and alerts](./docs/dashboard%20record.gif)

---

# Features

* Real-time CPU monitoring
* Memory usage monitoring
* Disk usage monitoring
* System uptime and load average
* Network traffic monitoring
* Top CPU-consuming processes
* Top memory-consuming processes
* Configurable resource thresholds
* Terminal-based dashboard
* Alert system with cooldown support
* Historical metrics logging (CSV)
* Performance report generation
* Optional email notifications for resource alerts
* Centralized configuration loading

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
│   ├── normal case screen.png
│   ├── stress Screen dashboard.png
│   └── dashboard record.gif
│
├── logs/
│   └── app.log
│
├── reports/
│   └── performance_report.txt
│
├── src/
│   ├── collectors/
│   ├── analyzers/
│   ├── alerts/
│   ├── dashboard/
│   ├── notifications/
│   │   └── email.sh
│   ├── reports/
│   └── utils/
│       ├── config_loader.sh
│       ├── logger.sh
│       └── storage.sh
│
├── .gitignore
└── main.sh

```

---

# How It Works

Each monitoring cycle consists of four steps:

1. Collect system metrics from `/proc` and standard Linux utilities.
2. Store collected data in a CSV file.
3. Compare current values with configured thresholds.
4. Update the dashboard and trigger alerts when thresholds are exceeded.

When email notifications are enabled, critical or warning alerts can also be sent through the configured email provider.

---

# Metrics Collected

* CPU Usage
* Memory Usage
* Disk Usage
* System Uptime
* Load Average
* Network RX/TX
* Top CPU Processes
* Top Memory Processes

---

# Configuration

Application settings are stored in:

```text
config/config.conf

```

Current configuration options include:

```bash
CPU_THRESHOLD=90
RAM_THRESHOLD=85
DISK_THRESHOLD=90
REFRESH_INTERVAL=3

EMAIL_NOTIFICATIONS_ENABLED=false
EMAIL_RECIPIENT="your email"
EMAIL_FROM="onboarding@resend.dev"

```

### Email Notifications & Security

Email notifications are **disabled by default**.

To enable them, set the required variables in your environment or configuration file:

```bash
export EMAIL_NOTIFICATIONS_ENABLED="true"
export EMAIL_RECIPIENT=""
export EMAIL_FROM=""

```

#### API Key Protection

The Resend API key must **NEVER** be stored in `config/config.conf` or committed to Git version control. Sensitive files like `.env` and local configuration files containing credentials are excluded via `.gitignore`.

Set your API key securely as an environment variable:

```bash
export RESEND_API_KEY="re_your_actual_api_key_here"

```

The email notification module interacts directly with the Resend REST API via `curl` and safely encodes payloads using `perl`.

> For development/testing, Resend's default sender (`onboarding@resend.dev`) can be used. For production use, configure a verified sending domain in Resend.

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

* Bash
* Linux `/proc` filesystem
* awk
* grep
* sed
* cut
* tr
* df
* ps
* tput
* bc
* curl
* Perl (JSON generation)
* ANSI escape sequences

---

# Getting Started

## 1. Clone the Repository

```bash
git clone [https://github.com/mazendiaa/Linux_monitoring_system.git](https://github.com/mazendiaa/Linux_monitoring_system.git)
cd Linux_monitoring_system

```

## 2. Configure Environment Variables

Export your secrets securely before launching:

```bash
export EMAIL_NOTIFICATIONS_ENABLED="true"
export EMAIL_RECIPIENT="your-email@gmail.com"
export EMAIL_FROM="onboarding@resend.dev"
export RESEND_API_KEY="re_your_actual_api_key_here"

```

## 3. Make the Main Script Executable

```bash
chmod +x main.sh

```

If necessary, make the component scripts executable as well:

```bash
find src -type f -name "*.sh" -exec chmod +x {} \;

```

## 4. Run the Application

```bash
./main.sh

```

The monitoring dashboard will start in the terminal.

---

# Email Notification Test

Email notifications are optional and disabled by default.

After configuring the required email settings and exporting your Resend API key, you can test the notification module directly:

```bash
source src/notifications/email.sh
send_email_alert "CPU" "95" "CRITICAL"

```

A successful request should return:

```text
[EMAIL] Alert sent successfully: CPU CRITICAL (95%)

```

The monitoring engine continues running even if an email notification fails.

---

# Learning Objectives

This project was built to practice:

* Bash scripting
* Linux system administration
* Reading kernel information from `/proc`
* Process monitoring
* System resource analysis
* Log management
* Modular shell scripting
* Configuration management
* Linux alerting and automation
* API integration using Bash and curl
* Secure handling of environment variables and secrets

---

# Future Improvements

* Export metrics in JSON format
* Docker support
* systemd service integration
* Web-based dashboard
* Scheduled monitoring and email reports

---

## Author

**Mazen Diaa**

Computer Science Student | Linux & DevOps Enthusiast

```
