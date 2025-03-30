# Synology AutoVPN

Scripts to schedule VPN connection and disconnection on a Synology NAS (e.g., DS216play) using DSM Task Scheduler.

## Prerequisites

- A configured VPN profile in DSM (`Control Panel > Network > Network Interface`).
- A shared folder on the NAS (e.g., `/volume1/scripts`).
- Admin access to DSM.
- Git installed on the NAS or a local machine for pulling updates.

## Installation

1. **Clone or Pull the Repository:**

   On a local machine or NAS with Git:
   `git clone https://github.com/byipr/synology.git /volume1/scripts/autovpn`  # Update URL if new repo
   
   Or run the setup script:
   `chmod +x /volume1/scripts/autovpn/setup.sh`
   `sudo /volume1/scripts/autovpn/setup.sh`

   If Git isn’t available, download the ZIP from GitHub and extract to `/volume1/scripts/autovpn` using DSM `File Station` or SFTP.

2. **Run Setup Script:**

   - Connect your VPN manually via DSM GUI first to populate `/usr/syno/etc/synovpnclient/vpnc_last_connect`.
   - Run:
     `sudo /volume1/scripts/autovpn/setup.sh`
   - This populates your `conf_id` into the scripts.

3. **Schedule Tasks:**

   - Open `Control Panel > Task Scheduler` in DSM.
   - Create two tasks:
     - **VPN Connect:**
       - General: Name=`VPN Connect`, User=`root`
       - Schedule: Set connect time (e.g., 9:00 AM daily)
       - Task Settings: Script=`/volume1/scripts/autovpn/vpn_connect.sh`
     - **VPN Disconnect:**
       - General: Name=`VPN Disconnect`, User=`root`
       - Schedule: Set disconnect time (e.g., 5:00 PM daily)
       - Task Settings: Script=`/volume1/scripts/autovpn/vpn_disconnect.sh`

4. **Test the Scripts:**

   - Manually via SSH:
     `sudo /volume1/scripts/autovpn/vpn_connect.sh`
     `sudo /volume1/scripts/autovpn/vpn_disconnect.sh`
   - Or in Task Scheduler, select each task and click `Run`.
   - Verify VPN status in `Control Panel > Network > Network Interface`.
   - Check logs at `/volume1/scripts/autovpn/vpn_log.txt`.

5. **Enable Tasks:**

   - Edit each task, check `Enabled`, and save.

## Updating

Pull updates from Git:
`cd /volume1/scripts/autovpn && git pull`

Then re-run:
`sudo /volume1/scripts/autovpn/setup.sh`

## Notes

- `setup.sh` extracts your VPN’s `conf_id` from `/usr/syno/etc/synovpnclient/vpnc_last_connect` and embeds it into the scripts.
- Logging writes to `/volume1/scripts/autovpn/vpn_log.txt`.
- Tasks must run as `root` in Task Scheduler for proper permissions.
- Adjust `conf_name` and `proto` in `vpn_connect.sh` if your VPN differs (e.g., `pptp`, `l2tp`).