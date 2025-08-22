# UCLA Cyber Setup

Scripts and package lists to quickly rebuild my Python **virtual environment** and **pipx apps** for the UCLA Cybersecurity Certificate.

## Contents
- `requirements.txt` — pinned Python libs for the class venv  
- `pipx-packages.txt` — CLI apps managed by pipx (`pipx list --short`)  
- `restore_venv.sh` — recreate venv and install from `requirements.txt` (supports `--dry-run`)  
- `restore_pipx.sh` — reinstall pipx apps from `pipx-packages.txt` (supports `--dry-run`)  

---

## Quick start

```bash
git clone https://github.com/BrianMWright/ucla-cyber-setup.git
cd ucla-cyber-setup
bash restore_venv.sh       # builds ~/cyber-env and installs libs
bash restore_pipx.sh       # reinstalls pipx apps
source ~/cyber-env/bin/activate
```

> Use `--dry-run` on either script to preview actions without changing anything:
> ```
> ./restore_venv.sh --dry-run
> ./restore_pipx.sh --dry-run
> ```

---

## Prerequisites

- Ubuntu 24.04+ (or 22.04 with updates)
- Python venv tools:
  ```bash
  sudo apt update
  sudo apt install -y python3-venv
  ```
- pipx (for CLI apps):
  ```bash
  sudo apt install -y pipx
  pipx ensurepath
  # then reopen terminal or: source ~/.bashrc
  ```

---

## Workflow

### Activate the venv for class work
```bash
source ~/cyber-env/bin/activate
# ... do your labs ...
deactivate
```

### Update the saved lists when you add packages/apps

- **Libraries (inside venv):**
  ```bash
  source ~/cyber-env/bin/activate
  pip install <new-lib>
  pip freeze > requirements.txt
  deactivate
  ```

- **pipx apps (global):**
  ```bash
  pipx install <new-app>
  pipx list --short > pipx-packages.txt
  ```

Commit and push:
```bash
git add requirements.txt pipx-packages.txt
git commit -m "Update env/app lists"
git push
```

---

## Verify after restore

```bash
# venv libs
source ~/cyber-env/bin/activate
python -c "import scapy, requests, cryptography; print('venv OK')"
deactivate

# pipx apps
which bandit && bandit --version
```

---

## Notes & conventions

- **Separation of concerns**
  - *Libraries* live in `~/cyber-env` (managed by `restore_venv.sh`)
  - *CLI apps* are installed via **pipx** (managed by `restore_pipx.sh`)
- **Security**
  - Avoid `sudo pip install` and system-wide pip; use venv + pipx (PEP 668 friendly)
- **Dry runs**
  - Both restore scripts accept `--dry-run` and show package/app counts

---

## Troubleshooting

- `pipx apps not found` → run `pipx ensurepath` then `source ~/.bashrc` or reopen terminal.  
- `venv missing` → run `bash restore_venv.sh` again.  
- `requirements.txt` empty/missing` → script will error; re-export with `pip freeze > requirements.txt`.  
- `Permission denied` when running scripts → make executable:
  ```bash
  chmod +x restore_venv.sh restore_pipx.sh
  ```

---

## Optional: Git over SSH (no more token prompts)

```bash
# Create key (press Enter for defaults; optional passphrase)
ssh-keygen -t ed25519 -C "you@example.com"
eval "$(ssh-agent -s)"; ssh-add ~/.ssh/id_ed25519

# Add key to GitHub (with GitHub CLI)
gh auth login
gh ssh-key add ~/.ssh/id_ed25519.pub --title "ubuntu-pc"

# Ensure SSH is used
git remote set-url origin git@github.com:BrianMWright/ucla-cyber-setup.git
```
