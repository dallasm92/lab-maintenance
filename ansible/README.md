# Debian-Family Host Maintenance with Ansible

Safe, repeatable Ansible playbooks for maintaining Debian-family hosts:
- Linux Mint workstation
- Ubuntu Server
- Raspberry Pi OS / Debian-based Pi hosts

This repository is designed to avoid destructive operations by default.

## Repository Layout

```text
ansible/
├── ansible.cfg
├── group_vars/
│   └── all.yml
├── inventory.example.ini
├── inventory.ini
├── playbooks/
│   ├── baseline.yml
│   ├── health.yml
│   ├── reboot_if_needed.yml
│   └── update.yml
├── host_vars/
│   ├── asus-server.yml
│   ├── macmint.yml
│   └── pi-core.yml
├── reports/
└── scripts/
    ├── run-baseline-enforce.sh
    ├── run-baseline-rollout.sh
    ├── run-baseline-validate.sh
    ├── run-health.sh
    ├── run-reboot-if-needed.sh
    └── run-update.sh
```

## Prerequisites

On the control machine:
1. Ansible installed (`ansible` and `ansible-playbook` available in PATH).
2. SSH access to all target hosts.
3. Sudo privileges on target hosts for the SSH user.
4. Python 3 installed on target hosts (already true for most Mint/Ubuntu/Pi installs).

Optional checks:

```bash
ansible --version
ssh -V
```

## SSH Key Setup

Generate a key if needed:

```bash
ssh-keygen -t ed25519 -C "ansible-maintenance"
```

Copy your key to each host:

```bash
ssh-copy-id your_ssh_user@mint-workstation
ssh-copy-id your_ssh_user@ubuntu-server
ssh-copy-id your_ssh_user@raspberry-pi
```

Quick connectivity test:

```bash
ansible -i inventory.ini debian_family -m ping
```

## Inventory Setup

Edit `inventory.ini`:
- Replace placeholder hostnames/IPs (`192.0.2.x`) with real values.
- Set `ansible_user` for each host.
- Keep Raspberry Pi `ansible_python_interpreter=/usr/bin/python3` unless you need something else.
- For new setups, start by copying `inventory.example.ini` to `inventory.ini`.

Example snippet:

```ini
[mint]
mint-workstation ansible_host=192.0.2.10 ansible_user=your_ssh_user
```

## Private vs Public

- `inventory.ini` is private and should contain your real hostnames/IPs/users.
- `inventory.example.ini` is safe to commit publicly (sanitized placeholders only).
- `ansible/reports/` is ignored because health reports can include host-specific operational details.
- This repo includes `.gitignore` rules for both `ansible/inventory.ini` and `ansible/reports/`.

## Common Variables

Edit `group_vars/all.yml` to tune behavior:
- `apt_use_dist_upgrade`: `false` by default for safer upgrades.
- `apt_update_cache_valid_time`: apt cache freshness window.
- `reboot_timeout_seconds`: reboot wait timeout.
- `health_report_dir`: where local reports are written on control machine.
- `rollout_serial_default`: default host rollout size (set to `1` for safest changes).
- `baseline_enforce_packages|timers|firewall`: optional enforcement toggles (all default `false`).

## Baseline Playbook (Safe Growth)

The baseline playbook validates your hardening and required service/timer state
across `macmint`, `asus-server`, and `pi-core`.

It supports two modes:
- validate-only (no changes)
- validate + enforce (only when explicitly enabled)

### Validate only (recommended first)

```bash
./scripts/run-baseline-validate.sh
```

Canary host first:

```bash
./scripts/run-baseline-validate.sh --limit macmint
```

### Canary rollout with optional enforcement

Start with one host, then expand:

```bash
./scripts/run-baseline-rollout.sh macmint --check
./scripts/run-baseline-rollout.sh ubuntu_servers -e baseline_enforce_timers=true
./scripts/run-baseline-rollout.sh raspberry_pi
```

### Full enforce run (only after canary)

```bash
./scripts/run-baseline-enforce.sh -e baseline_enforce_timers=true
```

Notes:
- `baseline_enforce_packages`, `baseline_enforce_timers`, and
  `baseline_enforce_firewall` are all disabled by default.
- Keep `rollout_serial_default: 1` to avoid mass changes.
- Use `--check` first for low-risk change previews.

## How to Run Playbooks

Run from `ansible/` directory.

### 1) Update Packages Safely

```bash
./scripts/run-update.sh
```

What it does:
- Refreshes apt cache.
- Runs safe package upgrades.
- Removes unused packages.
- Cleans apt cache.
- Prints per-host changed/not-changed summary.

Dry-run first:

```bash
./scripts/run-update.sh --check
```

### 2) Reboot Only If Required

```bash
./scripts/run-reboot-if-needed.sh
```

What it does:
- Checks for `/var/run/reboot-required`.
- Reboots only hosts where that file exists.
- Reports whether reboot happened.

Dry-run:

```bash
./scripts/run-reboot-if-needed.sh --check
```

### 3) Health Report

```bash
./scripts/run-health.sh
```

What it collects:
- Uptime
- Root disk usage %
- Memory usage summary
- Load average (1/5/15)
- Kernel version
- Docker service status (if present)

Output:
- Console summary per host
- Local file under `reports/` such as:
  - `reports/health-20260213-103015.txt`

## Safety Notes

- No playbook deletes user data.
- No forced reboot: reboot runs only when Debian/Ubuntu signal reboot-required.
- `apt_use_dist_upgrade` is disabled by default.
- Wrapper scripts support `--check` to preview changes.
- Host key checking is enabled in `ansible.cfg`.

## Example Output

Update playbook summary example:

```text
TASK [Report update summary] ***************************************************
ok: [mint-workstation] =>
  msg:
    cache_updated: true
    host: mint-workstation
    packages_removed: false
    packages_upgraded: true
    cache_cleaned: true
```

Reboot decision example:

```text
TASK [Report reboot decision] **************************************************
ok: [ubuntu-server] =>
  msg: Reboot not required on ubuntu-server.
```

Health report path example:

```text
TASK [Report local report path] ************************************************
ok: [mint-workstation -> localhost] =>
  msg: Local health report written to .../ansible/reports/health-20260213-103015.txt
```

## Screenshots to Take for GitHub

Capture these after your first successful run:
1. Terminal output of `ansible -i inventory.ini debian_family -m ping`.
2. Terminal output of `./scripts/run-update.sh --check`.
3. Terminal output of `./scripts/run-health.sh` showing per-host summary.
4. File listing of `reports/` with generated report file.
5. Opened `reports/health-*.txt` showing all hosts.

## Quick Start Order

1. Edit `inventory.ini` (host IP/hostnames + `ansible_user`).
2. Verify SSH key access to each host.
3. Run ping test.
4. Run `./scripts/run-update.sh --check`.
5. Run `./scripts/run-health.sh`.
6. Run reboot playbook when appropriate.
