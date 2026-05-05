# Lab Maintenance

Automation-focused repository for safe Linux host maintenance workflows.

Last reviewed: April 13, 2026

Social preview asset:
- [assets/social-preview.png](assets/social-preview.png)

## Objective

Document sanitized automation patterns for routine Linux host maintenance in the home lab without exposing real inventories, secrets, or environment-specific operational data.

## What This Repo Shows

- Ansible-based maintenance workflow organization
- Public-safe separation between reusable automation and private runtime data
- Security-conscious handling of inventories and host-specific maintenance context

## Hiring Manager Quick View

| Review area | Evidence |
|---|---|
| Linux operations | Ansible playbooks for update, health, reboot-if-needed, and baseline validation |
| Safety mindset | Check mode support, canary rollout scripts, disabled-by-default enforcement toggles |
| Public-safe handling | Example inventory committed; real inventory and reports remain ignored |
| Practical automation | Wrapper scripts make routine maintenance repeatable from one control host |

## Repository Role

This repo is supporting infrastructure evidence, not the first project a recruiter should open. It is best read alongside:

- [Home Lab Overview](https://github.com/dallasm92/home-lab-overview)
- [AI-Assisted Home Lab Operations](https://github.com/dallasm92/ai-assisted-home-lab-operations)

## Contents
- `ansible/playbooks/`: update, health, reboot-if-needed, and baseline validation playbooks
- `ansible/scripts/`: wrapper scripts for safer repeatable runs
- `ansible/inventory.example.ini`: sanitized inventory pattern for public review
- `ansible/group_vars/` and `ansible/host_vars/`: sanitized defaults and host-role examples
- `SECURITY.md`: publication and handling requirements for sensitive data

## Security Notes
This repository is designed for public-safe sharing of automation techniques.
Real host inventories and runtime reports remain local-only.

## Outcome

The repo provides a clean public wrapper around maintenance automation patterns without treating the private operational environment itself as publishable evidence.
