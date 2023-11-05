# Introduction

The TurnerTech_Tags addon is intended to provide a lighweight tagging functionality, both as an easy ingame way to keep track of what your bag items are for, and as an API to allow other addons to provide automation functionality based on Tags (e.g. auto sell all items tagged "sell").

# API

The ```TagitAddonMixin``` defines the intended API. Access it via the global frame ```TurnerTech_Tags```. For example, the following functions in ```TurnerTech_Tags.lua```:

```lua
TagitAddonMixin:TagItem(item, tagKey)
TagitAddonMixin:EnumerateTags()
```

can be accessed globally once the addon is loaded via:

```lua
TurnerTech_Tags:TagItem(item, tagKey)
TurnerTech_Tags:EnumerateTags()
```

## Concept

The addon stores two kinds of records.

- "Tag" objects. These have a globaly unique ID, and a label.
- "ItemTags". A database of Tags assigned to Items.

## Terminology

- Delete means destructive "it is gone". Deleting a Tag will remove all traces of the tag, including the "Tag" object itself.
- Removing means "remove from". As in Remove Tag X from Item Y.
- Tag means "to tag". As in "Tag Item X".