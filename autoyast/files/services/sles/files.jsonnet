{
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
      url: "http://weiss-2.weiss.ddnss.de/autoyast/files/trusted-ca-bundle.pem"
    }
  ]
}
