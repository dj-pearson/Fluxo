**Product Requirement Document (PRD)**

**Product Name:** Fluxo (Working Title)
**Goal:** Build a next-gen plugin sync and publishing tool that improves upon Argon by adding real-world publishing support, validation, team features, and a polished developer workflow.

---

## 1. **Overview**

Fluxo is a CLI + Roblox Studio plugin combo that allows developers to:

* Sync and publish plugins with minimal manual steps.
* Validate code and metadata before submission.
* Work in teams with clear role permissions and submission history.
* Avoid getting flagged by Roblox moderation.

The core improvement over Argon is actual in-Studio publishing automation, usable CI/CD pipelines, and guardrails for safe plugin publishing.

---

## 2. **Target Users**

* Solo plugin developers
* Roblox development studios
* Open-source plugin authors
* Educational and internal teams building plugins

---

## 3. **Key Features**

### 3.1 CLI Tool

* `fluxo init` – Generate project with proper structure
* `fluxo build` – Package plugin into a `.rbxmx` or `.rbxmx.json`
* `fluxo validate` – Lint, test metadata, and simulate publishing to catch errors
* `fluxo sync` – Sync local code to Studio Companion Plugin via RPC or file sync
* `fluxo publish` – Trigger Studio-side publishing flow (requires Studio open and plugin loaded)

### 3.2 Studio Companion Plugin

* Auto-detect synced plugin projects
* Show diff between last sync and current
* Button to manually trigger safe publishing
* UI for editing plugin metadata (name, description, tags, icon)
* Publish confirmation modal with versioning and notes
* Flag check: warn user if plugin may violate rules

### 3.3 Safe Publishing Flow

* Uses Roblox Studio's `Plugin:PublishAsPluginAsync()`
* User confirms in GUI before publish
* No automation triggers actual upload — avoids moderation issues

---

## 4. **Team & Collaboration**

* Config file (`fluxo.config.json`) supports multiple users
* Teams can share projects via Git
* Each team member's publish actions are logged
* Optional token-auth sync with shared cloud account for deployment history

---

## 5. **Validation System**

* Check for banned APIs (e.g., `loadstring`, `getfenv`)
* Warn if missing metadata or description
* Check for plugin folder structure compliance
* Optional custom rules via `fluxo.rules.json`

---

## 6. **Premium Features (Paid Tier)**

### 6.1 Dashboard (Web UI)

* Track plugin version history
* View who published what/when
* Download old versions

### 6.2 Plugin Template Manager

* Prebuilt plugin templates with linting rules and folder structure
* Shared internal templates

### 6.3 CI/CD Support

* GitHub Action: `uses: fluxo/action@latest`
* GitLab & Bitbucket runners
* Pushes plugin to Studio Companion queue for publishing

### 6.4 Secure Cloud Vault

* Store API tokens and settings securely
* Used for team sync, metadata sharing

### 6.5 Private Plugin Hosting

* Host internal-only plugins (zip + metadata)
* QR code support for Studio-side install

---

## 7. **File/Folder Layout**

```
my-plugin/
├── src/
│   ├── MainScript.lua
│   ├── ToolbarUI.lua
├── plugin.icon.png
├── plugin.meta.json
├── fluxo.config.json
```

---

## 8. **Security Considerations**

* All uploads require user confirmation in Studio
* CLI tool does not directly log in to Roblox
* Flag-detection helps prevent moderation blocks
* No obfuscation tools bundled

---

## 9. **Roadmap (First 90 Days)**

### Week 1–3

* Create CLI structure
* Create Studio Plugin base
* Sync local files into Studio UI

### Week 4–6

* Metadata UI and validation
* Publish flow with versioning support

### Week 7–9

* Build dashboard MVP (web)
* Add CI/CD basic action

### Week 10–12

* Launch paid tier with hosting + vault
* Begin onboarding pilot teams

---

## 10. **Stretch Goals**

* Plugin rating sync from Creator Marketplace
* Install button from Dashboard -> auto-sync to Studio
* Encrypted changelog chain for plugin verification
