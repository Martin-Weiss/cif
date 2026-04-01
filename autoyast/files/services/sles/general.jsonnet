{
  product: {
    id: 'SLES',
    mode: "immutable",
    registrationUrl: 'https://weiss-2.weiss.ddnss.de:444',
    addons: [
      {
        id: 'sle-ha',
      },
      {
        id: 'PackageHub',
      }
    ]
  },
  questions: {
    policy: 'auto',
    answers: [
      {
        answer: 'Trust',
        class: 'software.import_gpg',
        data: {
          fingerprint: 'BF3F 9A67 D3A2 FF98 A73F 5E07 488C 583D 287A 0027',
          id: '488C583D287A0027'
        }
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
    static: '%%HOST_NAME%%.%%DOMAIN_NAME%%',
    transient: '%%HOST_NAME%%.%%DOMAIN_NAME%%',
  },
  root: {
    hashedPassword: false,
    password: 'suse1234',
    sshPublicKey: '%%SSH_KEYS%%' ,
  },
  user: {
    hashedPassword: false,
    fullName: 'Martin Weiss',
    userName: 'mweiss',
    password: 'suse1234'
  },
  localization: {
    language: '%%LANGUAGE%%',
    keyboard: '%%KEYMAP%%',
    timezone: '%%TIME_ZONE%%',
  },
  network: {
    connections: [
      {
        id: 'ENP1S0-CONNECTION',
        interface: 'enp1s0',
        method4: 'manual',
        method6: 'disabled',
        addresses: ['%%my_ipaddress%%/%%my_preflen_1%%'],
        gateway4: '%%GATEWAY%%',
        nameservers: ['192.168.0.31', '192.168.0.54'],
        autoconnect: true,
      }
    ]
  },
  scripts: {
    post: [
      {
        name: "update-ca-certificates",
        chroot: true,
        content: |||
          #!/usr/bin/bash
          /usr/sbin/update-ca-certificates
        |||
      }
    ]
  },
  files: [
    {
      destination: "/etc/chrony.d/ntpserver.conf",
      permissions: "0644",
      content: |||
        pool 192.168.0.31 iburst
      |||
    },
    {
      destination: "/etc/pki/trust/anchors/trusted-ca-bundle.pem",
      permissions: "0644",
      url: "trusted-ca-bundle.pem"
    }
  ]
}
