{
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
      url: "http://weiss-2.weiss.ddnss.de/autoyast/agama/trusted-ca-bundle.pem"
    }
  ]
}
