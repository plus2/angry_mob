## 0.2.2

Changes:

  - `#to_normal_hash` can now return a hash with symbol keys. The default is still to use string keys as is default within `AngryHash`.

## 0.2.1

Changes:

  - In `#merge` & friends `other` hash is now converted to an AngryHash before merging.
    This ensures subhashes in `other` but not `this` end up as AngryHashes in `this` after merging.

## 0.2.0

Features:

  - Extension tracking extracted from PeaceLove. PeaceLove will use this in favour of its own implementation in the its version.
