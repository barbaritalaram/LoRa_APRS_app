# Communication Protocol

## Overview

The communication protocol is designed to be simple, efficient, and robust, enabling bidirectional communication between the mobile application and LoRa APRS devices.

## Message Format

### Basic Structure
```
[TYPE]|[DATA]|[CHECKSUM]
```

### Message Types

1. **MSG** - Text message
   ```
   MSG|message text|checksum
   ```

2. **BEACON** - Location information
   ```
   BEACON|lat,lon,alt,spd|checksum
   ```

3. **STATUS** - Device status
   ```
   STATUS|battery,strength,errors|checksum
   ```

4. **CONFIG** - Configuration
   ```
   CONFIG|param,value|checksum
   ```

## Data Fields

### Message (MSG)
- **text**: String (max. 160 characters)
- **timestamp**: Unix timestamp
- **sender**: Sender ID
- **recipient**: Recipient ID (optional)

### Beacon (BEACON)
- **lat**: Latitude (decimal)
- **lon**: Longitude (decimal)
- **alt**: Altitude (meters)
- **spd**: Speed (km/h)
- **course**: Direction (degrees)
- **timestamp**: Unix timestamp

### Status (STATUS)
- **battery**: Battery level (0-100)
- **strength**: RSSI signal
- **errors**: Error counter
- **uptime**: Uptime

### Config (CONFIG)
- **param**: Parameter name
- **value**: Parameter value

## Checksum

- Algorithm: CRC-16-CCITT
- Implementation: Polynomial 0x1021
- Initial value: 0xFFFF

## Encoding

### Text
- Encoding: UTF-8
- Escape special characters:
  - `|` → `\|`
  - `\` → `\\`

### Numbers
- Integers: Base 10
- Decimals: Dot as separator
- Negatives: Prefix `-`

## Communication Sequence

### Connection
1. Device scanning
2. Pairing
3. Authentication
4. State synchronization

### Sending a Message
1. Data validation
2. Encryption (if applicable)
3. Formatting
4. Checksum calculation
5. Sending
6. Reception confirmation

### Receiving a Message
1. Data reception
2. Checksum validation
3. Decoding
4. Decryption (if applicable)
5. Processing
6. Reception confirmation

## Error Handling

### Error Codes
- `E001`: Invalid checksum
- `E002`: Invalid format
- `E003`: Message too long
- `E004`: Device not found
- `E005`: Authentication error

### Recovery
1. Automatic retry (max. 3)
2. User notification
3. Error logging

## Security

### Encryption
- Algorithm: AES-256
- Mode: GCM
- IV: Randomly generated
- Authentication tag: 128 bits

### Authentication
- 6-digit PIN
- Expiration time: 24 hours
- Maximum attempts: 3

## Limits and Restrictions

### Sizes
- Max message: 160 bytes
- Max beacon: 64 bytes
- Max status: 32 bytes
- Max config: 48 bytes

### Frequencies
- Beacon: every 5 minutes
- Status: every minute
- Retries: 3 times
- Timeout: 5 seconds

## Examples

### Simple Message
```
MSG|Hello world|A1B2
```

### Beacon
```
BEACON|40.7128,-74.0060,10,0|C3D4
```

### Status
```
STATUS|85,-65,0,3600|E5F6
```

### Config
```
CONFIG|power,high|G7H8
```

## Implementation

### Libraries
- Encryption: pointycastle
- Checksum: crc
- Serialization: json_serializable

### Considerations
- Buffer management
- Timeouts
- Automatic reconnection
- Logging
- Metrics 