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
  }
}
