# Linux System Monitoring and Alerting System

A lightweight, local system monitoring tool built using Bash and Linux `procfs`. The system collects real-time metrics (CPU, RAM, Disk), stores historical data, and triggers alerts based on configurable thresholds.

## Project Architecture
```text
linux-monitor/
├── config/      # Configuration files
├── data/        # Historical CSV data
├── docs/        # Documentation
├── logs/        # System logs
├── src/         # Source code
│   ├── alerts/
│   ├── analyzers/
│   ├── collectors/
│   ├── dashboard/
│   └── reports/
└── tests/       # Unit tests