{
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
}
