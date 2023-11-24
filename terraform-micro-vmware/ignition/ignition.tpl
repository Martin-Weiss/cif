{
  "ignition": { "version": "3.4.0" },
  "passwd": {
    "users": [
      {
        "name": "root",
        "sshAuthorizedKeys": ${authorized_keys}
      }
    ]
  },
  "storage": {
    "files": [
    {
      "path": "/etc/hostname",
      "mode": 420,
      "overwrite": true,
      "contents": { "source": "data:,${servername}" }
    },
    {
        "path": "/etc/NetworkManager/system-connections/eth0.nmconnection",
        "mode": 384,
        "overwrite": true,
        "contents": {
          "source": "data:text/plain;charset=utf-8;base64,${networkconfig}" }
    }
   ]
  }
}
