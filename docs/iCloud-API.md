# iCloud Shortcuts API

This document describes the undocumented iCloud API used to fetch shortcut metadata.

> **Note on naming:** Apple Shortcuts was originally an app called "Workflow" before Apple acquired it in 2017. The internal format still uses `WFWorkflow*` prefixes throughout (WF = Workflow).

## Endpoint

```
GET https://www.icloud.com/shortcuts/api/records/{shortcut-id}
```

The `shortcut-id` is extracted from iCloud share URLs:
```
https://www.icloud.com/shortcuts/abc123def456
                                   └─────────┘
                                   shortcut-id
```

## Response

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
        "downloadURL": "https://cvws.icloud-content.com/B/...",
        "size": 21999,
        "fileChecksum": "AS+awyMxWh4FNhzQwxBaAncQhV3b"
      }
    },
    "shortcut": {
      "type": "ASSETID",
      "value": {
        "downloadURL": "https://cvws.icloud-content.com/B/...",
        "size": 3555,
        "fileChecksum": "AS5UVGE3xtLimCUuxcLQ7eRs8tZl"
      }
    },
    "signedShortcut": {
      "type": "ASSETID",
      "value": {
        "downloadURL": "https://cvws.icloud-content.com/B/...",
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

## Fields

| Field | Type | Description | Used |
|-------|------|-------------|------|
| `name` | STRING | Display name of the shortcut | Yes |
| `icon_color` | NUMBER_INT64 | Internal color code (see [Color Codes](#color-codes)) | Yes |
| `icon_glyph` | NUMBER_INT64 | SF Symbol glyph ID (see [IconGlyph-Research.md](IconGlyph-Research.md)) | Yes |
| `icon` | ASSETID | Custom icon image - PNG format (see [Asset Formats](#asset-formats)) | Yes |
| `shortcut` | ASSETID | The shortcut file - binary plist (see [Asset Formats](#asset-formats)) | Yes |
| `signedShortcut` | ASSETID | Signed version of the shortcut | No |
| `signingStatus` | STRING | Signing status, e.g. "APPROVED" | Yes |
| `signingCertificateExpirationDate` | TIMESTAMP | Signing cert expiration | No |
| `maliciousScanningContentVersion` | NUMBER_INT64 | Malware scan version | No |

## Timestamps

The `created` and `modified` objects contain:

| Field | Type | Description |
|-------|------|-------------|
| `timestamp` | NUMBER_INT64 | Milliseconds since Unix epoch |
| `userRecordName` | STRING | Internal user identifier |
| `deviceID` | STRING | Device that made the change |

SwiftShortcuts parses `created.timestamp` and `modified.timestamp` into `Date` objects on `ShortcutData`.

## Color Codes

Apple stores shortcut colors as Int64 values. Known mappings:

| Code | Color |
|------|-------|
| 4282601983 | Red |
| 12365313 | Red (alt) |
| 4251333119 | Dark Orange |
| 43634177 | Dark Orange (alt) |
| 4271458815 | Orange |
| 23508481 | Orange (alt) |
| 4274264319 | Yellow |
| 20702977 | Yellow (alt) |
| 4292093695 | Green |
| 2873601 | Green (alt) |
| 431817727 | Teal |
| 1440408063 | Light Blue |
| 463140863 | Blue |
| 946986751 | Dark Blue |
| 2071128575 | Purple |
| 3679049983 | Light Purple |
| 61591313 | Light Purple (alt) |
| 3980825855 | Pink |
| 314141441 | Pink (alt) |
| 255 | Gray |
| 1263359489 | Gray (alt) |
| 3031607807 | Green-Gray |
| 1448498689 | Brown |
| 2846468607 | Brown (alt) |

Some colors have alternate codes that map to the same gradient.

## Asset Formats

### `icon` Asset

**Format:** PNG image

The custom icon set by the user (if any). Not all shortcuts have this - when absent, the app displays the default glyph with the background color.

### `shortcut` Asset

**Format:** Binary plist (bplist)

The complete workflow definition - you can see every action/step in the shortcut. Contains:

- **Workflow metadata** - version, client version, icon properties
- **Actions array** - every step in order, fully visible
- **Parameters** - inputs, filters, app references for each action
- **Control flow** - conditionals, loops, variables

Example structure (conceptual):
```
{
  WFWorkflowMinimumClientVersion: 900,
  WFWorkflowIcon: { ... },
  WFWorkflowActions: [
    { WFWorkflowActionIdentifier: "is.workflow.actions.getupcomingcalendarevents", ... },
    { WFWorkflowActionIdentifier: "is.workflow.actions.filter.notes", ... },
    { WFWorkflowActionIdentifier: "is.workflow.actions.conditional", ... },
    ...
  ]
}
```

Action identifiers follow the pattern `is.workflow.actions.*` for built-in actions, or app bundle identifiers for third-party integrations.

### Download URL Format

Asset URLs contain a `${f}` placeholder for the filename:
```
https://cvws.icloud-content.com/B/{checksum}/${f}?...
```

Replace `${f}` with any filename (e.g., `shortcut.plist`, `icon.png`).

## Notes

- This is an undocumented API and may change without notice
- The API is read-only; you cannot modify shortcuts through it
- Only publicly shared shortcuts are accessible
