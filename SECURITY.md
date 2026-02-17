# Security Policy

## Scope
This repository contains automation code and sanitized examples for host maintenance.

## Hard Requirements
- Keep `ansible/inventory.ini` private and untracked.
- Use `inventory.example.ini` for public examples only.
- Never commit credentials, private keys, tokens, or real private addressing.

## Safe Publication Rules
- Use documentation/test-only addresses (`192.0.2.0/24`, `198.51.100.0/24`, `203.0.113.0/24`).
- Keep hostnames generic in public examples.
- Exclude generated reports and host-specific runtime data.

## Reporting
If sensitive material is discovered, report privately and remove it immediately.
