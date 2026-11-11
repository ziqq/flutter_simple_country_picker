# Google libphonenumber metadata

The generated phone formatting rules in
`lib/src/constant/country_phone_rules.g.dart` are derived from
[Google libphonenumber](https://github.com/google/libphonenumber).

Copyright (C) 2009 The Libphonenumber Authors

Licensed under the Apache License, Version 2.0. The complete upstream license
is included in [libphonenumber-LICENSE.txt](libphonenumber-LICENSE.txt).

Source:
[PhoneNumberMetadata.xml at commit 8593ab70fa4fadffc042b2714034f4c52bef7daf](https://github.com/google/libphonenumber/blob/8593ab70fa4fadffc042b2714034f4c52bef7daf/resources/PhoneNumberMetadata.xml)

Source XML SHA-256:
`b6491939ddaeb9d585a34fe0f0ebd096e83c5ac9a1c5d6dddf38ba4b162b28ca`

The gzip-compressed test fixture at
`test/fixtures/libphonenumber-metadata.xml.gz` contains the original pinned XML.

The metadata was transformed on 4 November 2026 by
`tool/generate_phone_rules.dart`. The generated subset:

- Selects compatible countries already present in the package's bundled data.
- Excludes non-geographic `001` records, missing HM/GS metadata, and VA because
  the bundled calling code `379` conflicts with the operational source code `39`.
- Uses effective fixed-line/mobile national lengths, excluding local-only and
  additional service-only lengths. A supported length does not validate a
  telephone number, its assignment, reachability, or SMS capability.
- Inherits formatting rules from the main region of a shared calling code.
- Selects international formats, omits `NA` formats, and derives partial-input
  capture sizes while preserving the original formatting regexes and order.
- Stores only prefix rules that can be applied by deletion. Upstream prefix
  transforms that add or rewrite digits are not implemented; their documented
  literal trunk prefix is retained where present.

The generated rules are compiled into the package. No libphonenumber runtime
code or Telegram source code is included.
