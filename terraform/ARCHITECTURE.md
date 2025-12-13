# Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         AWS VPC (10.0.0.0/16)                   │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │           Public Subnet (10.0.1.0/24)                     │ │
│  │                                                           │ │
│  │  ┌─────────────────────────────────────────────────┐     │ │
│  │  │         Master Node (t3.medium)                 │     │ │
│  │  │  ┌──────────────────────────────────────┐       │     │ │
│  │  │  │      Puppet Server (8140)            │       │     │ │
│  │  │  │  - Manages slave configurations      │       │     │ │
│  │  │  │  - Auto-signs certificates           │       │     │ │
│  │  │  └──────────────────────────────────────┘       │     │ │
│  │  │  ┌──────────────────────────────────────┐       │     │ │
│  │  │  │      Nagios Core (HTTP:80)           │       │     │ │
│  │  │  │  - Web interface on port 80          │       │     │ │
│  │  │  │  - Monitors all slave nodes          │       │     │ │
│  │  │  │  - CPU, Memory, Disk monitoring      │       │     │ │
│  │  │  │  - NRPE client (checks slaves)       │       │     │ │
│  │  │  └──────────────────────────────────────┘       │     │ │
│  │  │                                                  │     │ │
│  │  │  Public IP: x.x.x.x                             │     │ │
│  │  │  Private IP: 10.0.1.x                           │     │ │
│  │  └─────────────────────────────────────────────────┘     │ │
│  │                          │                                │ │
│  │                          │ Puppet (8140)                  │ │
│  │                          │ NRPE (5666)                    │ │
│  │           ┌──────────────┴──────────────┐                │ │
│  │           │                             │                │ │
│  │  ┌────────▼──────────┐         ┌───────▼─────────┐      │ │
│  │  │  Slave 1          │         │  Slave 2        │      │ │
│  │  │  (t3.small)       │         │  (t3.small)     │      │ │
│  │  │                   │         │                 │      │ │
│  │  │  ┌─────────────┐  │         │  ┌─────────────┐│      │ │
│  │  │  │Puppet Agent │  │         │  │Puppet Agent ││      │ │
│  │  │  │- Auto config│  │         │  │- Auto config││      │ │
│  │  │  └─────────────┘  │         │  └─────────────┘│      │ │
│  │  │  ┌─────────────┐  │         │  ┌─────────────┐│      │ │
│  │  │  │NRPE Server  │  │         │  │NRPE Server  ││      │ │
│  │  │  │- Port 5666  │  │         │  │- Port 5666  ││      │ │
│  │  │  │- CPU checks │  │         │  │- CPU checks ││      │ │
│  │  │  │- Mem checks │  │         │  │- Mem checks ││      │ │
│  │  │  │- Disk checks│  │         │  │- Disk checks││      │ │
│  │  │  └─────────────┘  │         │  └─────────────┘│      │ │
│  │  │                   │         │                 │      │ │
│  │  │  Public: y.y.y.y  │         │  Public: z.z.z.z│      │ │
│  │  │  Private:10.0.1.y │         │  Private:10.0.1.z│     │ │
│  │  └───────────────────┘         └─────────────────┘      │ │
│  │                                                          │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │                  Internet Gateway                         │ │
│  └──────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                               │
                               │ Internet
                               ▼
                        ┌─────────────┐
                        │   Users     │
                        │   (SSH)     │
                        │   (HTTP)    │
                        └─────────────┘
```

## Component Details

### Master Node Components
- **Puppet Server**: Configuration management server
- **Nagios Core**: Monitoring server with web UI
- **Apache**: Web server for Nagios interface
- **NRPE Client**: Executes remote checks on slaves

### Slave Node Components
- **Puppet Agent**: Receives and applies configurations
- **NRPE Server**: Responds to monitoring requests
- **Monitoring Scripts**: Custom CPU and memory checks

## Communication Flow

### Puppet Configuration Management
1. Master: Puppet Server runs on port 8140
2. Slaves: Puppet Agents connect to master every 30 minutes
3. Slaves: Request and receive configurations
4. Slaves: Apply configurations automatically

### Nagios Monitoring
1. Master: Nagios server initiates checks every 5 minutes
2. Master: Sends NRPE requests to slaves on port 5666
3. Slaves: Execute monitoring scripts locally
4. Slaves: Return results to Nagios
5. Master: Updates web interface with status

## Monitoring Metrics

### CPU Health
- **Check**: Load average (1, 5, 15 minutes)
- **Warning**: 15, 10, 5
- **Critical**: 30, 25, 20
- **Frequency**: Every 5 minutes

### Memory Health
- **Check**: Memory usage percentage
- **Warning**: 80% used
- **Critical**: 90% used
- **Frequency**: Every 5 minutes

### Disk Health
- **Check**: Disk space percentage
- **Warning**: 20% free
- **Critical**: 10% free
- **Frequency**: Every 5 minutes

## Security Groups

### Master Security Group
- Inbound:
  - SSH (22) from 0.0.0.0/0
  - HTTP (80) from 0.0.0.0/0 (Nagios web)
  - HTTPS (443) from 0.0.0.0/0
  - Puppet (8140) from VPC only
  - NRPE (5666) from VPC only
- Outbound: All traffic

### Slave Security Group
- Inbound:
  - SSH (22) from 0.0.0.0/0
  - NRPE (5666) from Master SG only
  - App Port (8000) from 0.0.0.0/0
- Outbound: All traffic
