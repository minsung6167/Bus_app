List<Map<String, dynamic>> getChatbotFaqs(String lang) {
  switch (lang) {
    case 'en':
      return [
        {
          'q': 'How do I cancel my booking?',
          'a': 'Go to My Page → My Bookings, select the booking and tap [Cancel].\n\nFull refund available up to 1 hour before departure.',
          'keywords': ['cancel', 'refund'],
        },
        {
          'q': 'How do I use mobile ticketing?',
          'a': 'After booking, find your QR code in My Bookings.\n\nShow the QR code to the driver when boarding — no separate ticket needed.',
          'keywords': ['ticket', 'qr', 'mobile', 'board'],
        },
        {
          'q': 'How much luggage can I bring?',
          'a': 'Up to 20kg of luggage per seat is free.\n\nExtra charges may apply for excess baggage. Please inquire at the terminal.',
          'keywords': ['luggage', 'baggage', 'bag', 'weight'],
        },
        {
          'q': 'How do I change the app language?',
          'a': 'Go to My Page → Language Settings and select Korean, English, Chinese, or Japanese.',
          'keywords': ['language', 'english', 'chinese', 'japanese'],
        },
        {
          'q': 'Can I book without signing up?',
          'a': 'Guest booking is not supported. Please log in to book.\n\nSign-up only requires an email address and takes seconds.',
          'keywords': ['guest', 'signup', 'login', 'register'],
        },
      ];
    case 'zh':
      return [
        {
          'q': '如何取消预订？',
          'a': '进入我的页面 → 预订记录，选择要取消的预订后点击[取消]。\n\n出发前1小时内可全额退款。',
          'keywords': ['取消', '退款', 'cancel', 'refund'],
        },
        {
          'q': '如何使用手机取票？',
          'a': '预订完成后，在预订记录中可查看QR码。\n\n上车时向司机展示QR码即可，无需另行取票。',
          'keywords': ['取票', 'qr', '手机', '乘车'],
        },
        {
          'q': '能携带多少行李？',
          'a': '每个座位可免费携带20kg以内的行李。\n\n超重可能产生额外费用，请向终点站咨询。',
          'keywords': ['行李', '重量', '包'],
        },
        {
          'q': '如何更改应用语言？',
          'a': '进入我的页面 → 语言设置，选择韩语、英语、中文或日语。',
          'keywords': ['语言', '中文', '英语', '日语'],
        },
        {
          'q': '不注册可以预订吗？',
          'a': '暂不支持游客预订，请登录后进行预订。\n\n注册只需邮箱地址，即可快速完成。',
          'keywords': ['游客', '注册', '登录'],
        },
      ];
    case 'ja':
      return [
        {
          'q': '予約のキャンセル方法は？',
          'a': 'マイページ → 予約履歴でキャンセルしたい予約を選び、[キャンセル]をタップしてください。\n\n出発1時間前まで全額返金可能です。',
          'keywords': ['キャンセル', '返金', 'cancel', 'refund'],
        },
        {
          'q': 'モバイル発券の使い方は？',
          'a': '予約完了後、予約履歴からQRコードを確認できます。\n\n乗車時に運転手にQRコードを提示するだけで乗車できます。',
          'keywords': ['発券', 'qr', 'モバイル', '乗車'],
        },
        {
          'q': '荷物はどのくらい持ち込めますか？',
          'a': '座席1つにつき20kg以内の手荷物を無料で預けられます。\n\n超過する場合は追加料金が発生する場合があります。',
          'keywords': ['荷物', '重量', 'バッグ'],
        },
        {
          'q': 'アプリの言語を変えたい',
          'a': 'マイページ → 言語設定から韓国語・英語・中国語・日本語を選択できます。',
          'keywords': ['言語', '英語', '中国語', '日本語'],
        },
        {
          'q': '会員登録なしで予約できますか？',
          'a': '非会員予約はサポートしていません。ログイン後にご予約ください。\n\n会員登録はメールアドレスだけで素早く完了できます。',
          'keywords': ['非会員', '登録', 'ログイン'],
        },
      ];
    default: // ko
      return [
        {
          'q': '예매 취소는 어떻게 하나요?',
          'a': '마이페이지 → 예매내역 탭에서 취소할 예매를 선택한 후 [취소] 버튼을 누르시면 됩니다.\n\n출발 1시간 전까지는 100% 환불이 가능합니다.',
          'keywords': ['취소', '환불', 'cancel', 'refund'],
        },
        {
          'q': '모바일 발권은 어떻게 사용하나요?',
          'a': '예매 완료 후 예매내역에서 QR코드를 확인할 수 있습니다.\n\n버스 탑승 시 기사님께 QR코드를 보여주시면 별도 발권 없이 탑승 가능합니다.',
          'keywords': ['발권', 'qr', 'QR', '모바일', '탑승', 'ticket'],
        },
        {
          'q': '짐은 얼마나 가져갈 수 있나요?',
          'a': '좌석 1개당 20kg 이내의 수하물을 무료로 보관하실 수 있습니다.\n\n초과 시 추가 요금이 발생할 수 있으니 터미널에 문의해 주세요.',
          'keywords': ['짐', '수하물', '가방', '무게', 'luggage', 'baggage'],
        },
        {
          'q': '앱 언어를 바꾸고 싶어요',
          'a': '마이페이지 → 언어 설정에서 한국어, English, 中文, 日本語 중 원하는 언어를 선택하실 수 있습니다.',
          'keywords': ['언어', '영어', '중국어', '일본어', 'language', '바꾸'],
        },
        {
          'q': '회원가입 없이 예매할 수 있나요?',
          'a': '비회원 예매는 지원하지 않습니다. 로그인 후 예매가 가능합니다.\n\n회원가입은 이메일 주소만 있으면 빠르게 완료할 수 있습니다.',
          'keywords': ['비회원', '회원가입', '로그인', '가입', 'login', 'signup'],
        },
      ];
  }
}
