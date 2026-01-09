{
  product: {
    id: 'SLES',
    registrationUrl: 'https://weiss-2.weiss.ddnss.de:444',
    addons: [
      {
        id: 'sle-ha',
      }
    ]
  },
  security: {
    sslCertificates: [
      {
        fingerprint: 'A0:DF:EE:9F:C7:5E:CA:0E:B3:EB:62:A7:A0:AC:C1:B7:3D:C8:C2:BA',
        algorithm: 'SHA1',
      }
    ]
  },
  hostname: {
    static: 'sles16-2.weiss.ddnss.de',
    transient: 'sles16-2.weiss.ddnss.de',
  },
  root: {
    hashedPassword: false,
    password: 'suse1234',
    sshPublicKey: 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAv1DS2t+Kmh7spHYFg2t0592otcq8YUnZXb17WgkpaWU5cS/2eLZoNbImURkbqpVC54zVwT2dUauJZG/2bXQBul8p2OK0Rgo+Vhhrbmtnvs4GXMfgxRUo3b+zadbMPZzOAxrEWJj8nkg5PV5+5jdxLR6/3ykZtRXn2kvh2/TMHMRpxE7x5xKwyAvXiGMK9kN0dTNEun9KKfNycXX1ZbvfJ02WuzQPA7K3i8eUZZeHlnRXso/66RWsmEPCipNua23wPrBXocsNFx75hvxDFwwvj1rj4SwB9afzcQbvvnLwPheEt8pl30Xozl7qZSVaYllZaEUMcrdklXESKhj87fKDhw== root@weiss-2',
  },
  user: {
    hashedPassword: false,
    fullName: 'Martin Weiss',
    userName: 'mweiss',
    password: 'suse1234',
    sshPublicKey: 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAv1DS2t+Kmh7spHYFg2t0592otcq8YUnZXb17WgkpaWU5cS/2eLZoNbImURkbqpVC54zVwT2dUauJZG/2bXQBul8p2OK0Rgo+Vhhrbmtnvs4GXMfgxRUo3b+zadbMPZzOAxrEWJj8nkg5PV5+5jdxLR6/3ykZtRXn2kvh2/TMHMRpxE7x5xKwyAvXiGMK9kN0dTNEun9KKfNycXX1ZbvfJ02WuzQPA7K3i8eUZZeHlnRXso/66RWsmEPCipNua23wPrBXocsNFx75hvxDFwwvj1rj4SwB9afzcQbvvnLwPheEt8pl30Xozl7qZSVaYllZaEUMcrdklXESKhj87fKDhw== root@weiss-2',
  },
  localization: {
    language: 'en_US.UTF-8',
    keyboard: 'de',
    timezone: 'Europe/Berlin',
  },
  network: {
    connections: [
      {
        id: 'ENP1S0-CONNECTION',
        interface: 'enp1s0',
        method4: 'manual',
        method6: 'disabled',
        addresses: ['192.168.0.181/24'],
        gateway4: '192.168.0.1',
        nameservers: ['192.168.0.31', '192.168.0.54'],
        autoconnect: true,
      }
    ]
  },
  "storage": {
    "drives": [
      {
      "partitions": [
        {
          "filesystem": { "path": "/", "type": "btrfs" },
          "size": "40 GiB"
        },
        {
          "filesystem": { "path": "swap", "type": "swap" },
          "size": "4 GiB"
        },
        {
          "filesystem": { "path": "/home", "type": "xfs" },
          "size": "5 GiB"
        }
        ]
      }
    ]
  },
  software: {
    patterns: ["cockpit", "devel_basis", "dhcp_dns_server", "documentation", "kvm_server", "sw_management"],
    packages: [ "tuned", "git-core", "chrony-pool-empty", "iptables", "nfs-client", "open-iscsi" ]
  },
  files: [
    {
      destination: "/etc/chrony.d/ntpserver.conf",
      permissions: "0644",
      content: |||
        pool 192.168.0.31 iburst
      |||
    }
  ]
}
