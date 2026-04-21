# Cyber ZSH Theme

## Features Summary:
*   **Security Indicators:** Tracks privilege levels (Root/User) and detects connection type (SSH vs. Local).
*   **Safety Features:** Includes detection warnings for dangerous commands and displays real-time security status indicators.
*   **Visual Warnings:** Provides visual alerts for root access usage.

## Logging Capabilities:
*   **Auditing:** Logs every command executed with timestamps.
*   **Full Audit Trail:** Records detailed information including user, host, PID, the command run, and exit code.
*   **Logging Management:** Maintains separate error logs and audit logs.
*   **Maintenance:** Features automatic log rotation and compression utilities.
*   **Utility:** Includes search functions for reviewing logged history and supports automated history backups.

## History Management:
*   **Detail Tracking:** Stores timestamps for every command executed.
*   **Capacity:** Supports a large command history capacity (e.g., 1,000,000 commands).
*   **Backup:** Implements automatic daily backups of the command history.
*   **Analysis:** Provides statistics and analysis tools for usage patterns.
*   **Maintenance:** Includes utilities for sanitizing historical data and generating timeline views.

## Plugin Support:
*   **Architecture:** Uses a modular plugin architecture for extensibility.
*   **Organization:** Maintains clearly organized directories (core/custom/security) for plugins.
*   **Loading System:** Features an easy-to-use plugin loading system.
*   **Design:** Designed to be highly extensible and maintainable.

## User Interface:
*   **Status Display:** Provides color-coded security status indicators.
*   **Performance:** Tracks command execution time.
*   **Feedback:** Displays clear success or failure indicators for commands.
*   **Integration:** Integrates Git branch and status information into the prompt.
*   **Context:** Always displays the current working directory location.
