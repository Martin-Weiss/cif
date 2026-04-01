{
  product: {
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
  software: {
    patterns: ["cockpit", "devel_basis", "dhcp_dns_server", "documentation", "kvm_server", "sw_management"],
    packages: [ "tuned", "git-core", "chrony-pool-empty", "iptables", "nfs-client", "open-iscsi" ]
  }
}
