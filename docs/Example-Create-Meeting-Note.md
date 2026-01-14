# Example: Create Meeting Note

A detailed breakdown of fetching and inspecting a shared shortcut.

## Source URL

```
https://www.icloud.com/shortcuts/f00836becd2845109809720d2a70e32f
```

## Step 1: Extract Shortcut ID

From the URL path:
```
f00836becd2845109809720d2a70e32f
```

## Step 2: Fetch Metadata

**Request:**
```
GET https://www.icloud.com/shortcuts/api/records/f00836becd2845109809720d2a70e32f
```

**Response:**
```json
{
  "recordName": "F00836BE-CD28-4510-9809-720D2A70E32F",
  "recordType": "SharedShortcut",
  "recordChangeTag": "mi3vqvoa",
  "deleted": false,
  "created": {
    "timestamp": 1763428412893,
    "userRecordName": "_c76a45b8559feb56e53f7bb1b7a03025",
    "deviceID": "3600A879-BFFF-48B1-B4C6-90E224066A2B"
  },
  "modified": {
    "timestamp": 1763428582657,
    "userRecordName": "_a702d02db102341342355d5ae64b8e07",
    "deviceID": "2"
  },
  "pluginFields": {},
  "fields": {
    "name": {
      "value": "Create Meeting Note",
      "type": "STRING"
    },
    "icon_color": {
      "value": 4274264319,
      "type": "NUMBER_INT64"
    },
    "icon_glyph": {
      "value": 59446,
      "type": "NUMBER_INT64"
    },
    "icon": {
      "type": "ASSETID",
      "value": {
        "downloadURL": "https://cvws.icloud-content.com/B/AS-awyMxWh4FNhzQwxBaAncQhV3b/${f}?o=AsOIOt5MmtCPm5hENSLqCfpSOLAX3M_QQGTH7jgq7OvIkTYi8smuLh3ckvFMn7mthg&v=1&x=3&a=CAogqissn-MG5nikedJfDXWPdVKhchkH2xWBUljDhAEBCswSexDjofXMuzMY4_7QzrszIgEAUgQQhV3bajCanFm5UVL3bIdEM1vpXhDp0talqsYlKUU_v_AWHFVH19YAF-pMHOFV_EMNwvA9yJxyMJCQHFuZaPdRWtZ031W64VVFtzQ3n9urAtiYnHur6cZieiMEtfaLUWHUn9gaHdPecg&e=1768349253&fl=&r=4ff80b54-1420-4dd9-95f8-074bcfd6b320-1&k=_&ckc=com.apple.shortcuts&ckz=_defaultZone&p=33&s=f86r3V1ETIB_8QxlvLdo_wkEFuw",
        "size": 21999,
        "fileChecksum": "AS+awyMxWh4FNhzQwxBaAncQhV3b"
      }
    },
    "shortcut": {
      "type": "ASSETID",
      "value": {
        "downloadURL": "https://cvws.icloud-content.com/B/AS5UVGE3xtLimCUuxcLQ7eRs8tZl/${f}?o=AiC5o2aUbGhjLm6YVn63uUjjrd6VUL7is6bKO-FxW6_avWfwveE_tdmibUXyH5V0Ig&v=1&x=3&a=CAogye4MiQMuVIqIJ2H0m6Z6msKjnLSs8KkE6HzGbFMESN0SexDjofXMuzMY4_7QzrszIgEAUgRs8tZlajA2YnaEFPvIr5wWGumwVfl_aEhZBxZV5HZVqKhwQSK5iVlpFcjJOnGcZIDZppsba1pyMN5b10veHGYjJ-kb0q6XW5PRAL_Fb-QWg2ihMQlYA2-M9L7qwEq0vD7OrK7V5mzXrw&e=1768349253&fl=&r=4ff80b54-1420-4dd9-95f8-074bcfd6b320-1&k=_&ckc=com.apple.shortcuts&ckz=_defaultZone&p=33&s=BYyR0w1qsyQq8MN3K9weWJJwIj4",
        "size": 3555,
        "fileChecksum": "AS5UVGE3xtLimCUuxcLQ7eRs8tZl"
      }
    },
    "signedShortcut": {
      "type": "ASSETID",
      "value": {
        "downloadURL": "https://cvws.icloud-content.com/B/ASSEIE6NlOo_udmJScBp0qmS1II6/${f}?o=AjEMnAys1kxzOa2XCvphgVActF-oNV2DwhOj5MpKwMOF4ELoHkPkTYFZm3TqszkZ-w&v=1&x=3&a=CAogEHfcqPBRccCMs9C5G9tbQnfwJ8zJIUupJztUXdG8r28SexDjofXMuzMY4_7QzrszIgEAUgSS1II6ajD5Q4EsiJudKqSUWj2bmGFUT5qBgwSneCKRf4NLCorItM1LVcvLJ8iGL9QaNrfrxsVyMEdRzxfknzlywaPYrK8vvwjLlbAvMC_FEQ1i6w0_XI5zd7pkcExMcoNf6Vlb3YdY1A&e=1768349253&fl=&r=4ff80b54-1420-4dd9-95f8-074bcfd6b320-1&k=_&ckc=com.apple.shortcuts&ckz=_defaultZone&p=33&s=0-7IbOZCyM4eSyrzS96nqLzsp2U",
        "size": 23590,
        "fileChecksum": "ASSEIE6NlOo/udmJScBp0qmS1II6"
      }
    },
    "signingStatus": {
      "value": "APPROVED",
      "type": "STRING"
    },
    "signingCertificateExpirationDate": {
      "type": "TIMESTAMP",
      "value": 1797533441000
    },
    "maliciousScanningContentVersion": {
      "type": "NUMBER_INT64",
      "value": 1
    }
  }
}
```

## Step 3: Parse Metadata

### Basic Info

| Property | Value |
|----------|-------|
| **Name** | Create Meeting Note |
| **ID** | F00836BE-CD28-4510-9809-720D2A70E32F |
| **Color** | Yellow (code: 4274264319) |
| **Glyph** | 59446 (unverified - possibly SF Symbol codepoint) |
| **Signing Status** | APPROVED |
| **Has Custom Icon** | Yes (21,999 bytes) |

### Timestamps

| Event | Timestamp | Human Readable |
|-------|-----------|----------------|
| Created | 1763428412893 | ~2025 |
| Modified | 1763428582657 | ~2025 |
| Signing Cert Expires | 1797533441000 | ~2026 |

## Step 4: Download Workflow

The `shortcut` asset URL (with `${f}` replaced):
```
https://cvws.icloud-content.com/B/AS5UVGE3xtLimCUuxcLQ7eRs8tZl/shortcut.plist?...
```

**Format:** Binary plist (3,555 bytes)

## Step 5: Workflow Actions

The workflow contains the following actions in order:

### Action 1: Get Upcoming Calendar Events
```
Identifier: is.workflow.actions.getupcomingcalendarevents
```
Fetches upcoming events from the user's calendar.

### Action 2: Filter Notes
```
Identifier: is.workflow.actions.filter.notes
```
Filters notes, likely looking for notes with attachments or specific criteria.

### Action 3: Conditional (If/Else)
```
Identifier: is.workflow.actions.conditional
```
Branches based on whether meetings were found.

### Action 4: Create Note
```
Identifier: is.workflow.actions.createnote
```
Creates a new note (in the "meetings found" branch).

### Action 5: Show Note
```
Identifier: is.workflow.actions.shownote
```
Opens/displays the created note.

### Action 6: Show Alert
```
Identifier: is.workflow.actions.alert
Message: "You have no meetings today"
```
Displays an alert (in the "no meetings" branch).

## Visual Flow

```
┌─────────────────────────────────┐
│  Get Upcoming Calendar Events   │
└────────────────┬────────────────┘
                 │
                 ▼
┌─────────────────────────────────┐
│         Filter Notes            │
└────────────────┬────────────────┘
                 │
                 ▼
         ┌──────┴──────┐
         │ Has Events? │
         └──────┬──────┘
                │
       ┌────────┴────────┐
       │                 │
       ▼                 ▼
   ┌───────┐        ┌─────────┐
   │  Yes  │        │   No    │
   └───┬───┘        └────┬────┘
       │                 │
       ▼                 ▼
┌─────────────┐   ┌──────────────────┐
│ Create Note │   │ Alert: "You have │
└──────┬──────┘   │ no meetings"     │
       │          └──────────────────┘
       ▼
┌─────────────┐
│  Show Note  │
└─────────────┘
```

## What SwiftShortcuts Uses

From all this data, SwiftShortcuts extracts:

| Field | Used For |
|-------|----------|
| `name` | Display on card |
| `icon_color` | Background gradient |
| `icon` (downloadURL) | Card icon image |
| `recordName` | Opening in Shortcuts app via `shortcuts://open-shortcut?id=...` |

Fields like `icon_glyph`, `shortcut`, `signedShortcut`, and the signing/scanning metadata are fetched but not currently used.

## Potential Future Uses

The workflow data could enable:

- **Preview actions** before importing a shortcut
- **Security audit** - see exactly what a shortcut does
- **Search by action type** - find shortcuts that use specific apps
- **Dependency detection** - identify which apps a shortcut requires
