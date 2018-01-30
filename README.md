# DNS engine based around LuaJIT for capturing, parsing, replaying and statistics gathering

**dnsjit** is a combination of parts taken from **dsc**, **dnscap**, **drool**,
and put together around Lua to create a script-based engine for easy
capturing, parsing and statistics gathering of DNS message while also
providing facilities for replaying DNS traffic.

One of the core functionality that **dnsjit** brings is to tie together C
and Lua modules through a receiver/receive interface.
This allows creation of custom chains of functionality to meet various
requirements.
Another core functionality is the ability to parse and process DNS messages
even if the messages are non-compliant with the DNS standards.

**NOTE** current implementation is _ALPHA_ which means functionality are not
set and may be changed or removed.

The following Lua module categories exists:
- dnsjit.core
  Core modules for handling things like logging, DNS messages and receiver/receive functionality.
- dnsjit.input
  Input modules used to read DNS messages in various ways.
- dnsjit.filter
  Filter modules to process or manipulate DNS messages.
- dnsjit.output
  Output modules used to display DNS message, export to various formats or replay them against other targets.

See each category's man-page for more information.

## Build

```shell
git clone https://github.com/DNS-OARC/dnsjit
cd dnsjit
git submodule update --init
sh autogen.sh
./configure
make
```

## Documentation

Most documentation exists in man-pages and you do not have to install to
access them, after building you can do:

```shell
man src/dnsjit.1
man src/dnsjit.core.3
man src/dnsjit.input.3
man src/dnsjit.filter.3
man src/dnsjit.output.3
```

## Usage

Run a Lua script:

```shell
dnsjit file.lua ...
```

Shebang-style:
```lua
#!/usr/bin/env dnsjit
...
```

## Example

Following example display the DNS ID found in queries.

```lua
local input = require("dnsjit.input.pcap").new()
local output = require("dnsjit.filter.lua").new()

output:func(function(filter, query)
    print(query:id())
end)

input:open_offline("file.pcap")
input:only_queries(true)
input:receiver(output)
input:run()
```

See more examples in the [examples](https://github.com/DNS-OARC/dnsjit/tree/develop/examples) directory.

## Copyright

Copyright (c) 2018, OARC, Inc.

All rights reserved.

```
This file is part of dnsjit.

dnsjit is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

dnsjit is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with dnsjit.  If not, see <http://www.gnu.org/licenses/>.
```
