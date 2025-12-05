---
permalink: "/{{ year }}/{{ month }}/{{ day }}/incident-report-a-compiler-bug-and-json"
title: "Incident Report: A compiler bug and JSON"
published_date: "2025-12-01 12:01:00 +0100"
layout: post.liquid
data:
  route: blog
excerpt: |
  TODO
---

It all started rather inconspicuous:
The Data Engineering team filed [a bug report][1999791] about a sudden increase in schema errors at ingestion of telemetry data from Firefox for Android.
At that point in time about 0.9% of all incoming pings were not passing our schema validation checks.

The data we were seeing was surprising.
Our ingestion endpoint received valid JSON that contained snippets like this:

```json
{
    "metrics": {
        "schema: counter": {
            "glean.validation.pings_submitted": {
                "events": 1
            }
        },
        ...
    },
    ...
}
```

What we would expect and would pass our schema validation is this:

```json
{
    "metrics": {
        "labeled_counter": {
            "glean.validation.pings_submitted": {
                "events": 1
            }
        },
        ...
    },
    ...
}
```

The difference? 8 characters:

```patch
-        "schema: counter": {
+        "labeled_counter": {
```

8 different characters that still make up valid JSON, but break validation.

A week later the number of errors kept increasing, affecting up to 2% of all ingested pings from Firefox for Android Beta.
That's worryingly high.
That's enough to drop other work and call an incident.

## Aside: Telemetry ingestion

In Firefox the data is collected using the [Glean SDK][glean].
Data is stored in a local database and eventually assembled into what we call a [ping][ping-doc]:
A bundle of related metrics, gathered in a JSON payload to be transmitted.
This JSON document is then `POST`ed to the [Telemetry edge server][edge-spec].
From there the decoder eventually picks it up and preprocesses it further.
One of the early things it does is verify the received data against one of the [pre-defined schemas][mps].
When data is coming from the Glean SDK it must pass [the pre-defined `glean.1.schema.json`][mps-glean].
This essentially describes which fields to expect in the nested JSON object.
One thing it is expecting is [a `labeled_counter`][labeled_counter-spec]
A thing it is NOT expecting is `schema: counter`. In fact keys other than the listed ones [are forbidden][additionalProperties].

## The missing schema:_

The data we were receiving from a growing number of clients contained 8 bytes that we didn't expect in that place: `schema: `.
That 8-character string didn't even show up in the [Glean SDK source code][searchfox-schema].
Where does it come from? Why was it showing up now?

We do receive entirely valid JSON, so it's unlikely to be simple memory corruption[^1].
More like memory confusion, if that's a thing.

We know where the payload is constructed.
The nested object for labeled metrics is constructed [in its own function][ping_section_format].
It's a string format:

```rust
let ping_section = format!("labeled_{}", metric.ping_section());
```

There's our 8-character string `labeled_` that gets swapped.
The Glean SDK is embedded into Firefox inside mozilla-central and compiled with all the other code together.
A single candidate for the `schema: ` string [exists in that codebase][searchfox-schema2].
That's another clue it could be memory confusion.

## My schema? Confused.

I don't know much about how string formatting in Rust works under the hood,
but luckily [Mara] blogged about it 2 years ago: [Behind the Scenes of Rust String Formatting: format\_args!()][format-args]
(and then [recently improved the implementation][format-improvements][^2]).

So the `format!` from above expands into something like this:

```rust
std::io::_format(
    // Simplified expansion of format_args!():
    std::fmt::Arguments {
        template: &[Str("labeled_ "), Arg(0)],
        arguments: &[&metric.ping_section() as &dyn Display],
    }
);
```

## Architecturing more clues

Whenever we're faced with data anomalies we [start by dissecting the data][data-investigations] to figure out if the anomalies are from a particular subset of clients.
The hope is that identifying the subset of clients where it happens gives us more clues about the bug itself.

After initially focusing too much on actual _devices_ colleagues helpfully pointed out that the actual split was the device's architecture[^3]:

![Data since 2025-11-11 showing a sharp increase in errors for armeabi-v7a clients](https://tmp.fnordig.de/blog/2025/2025-12-01-schema-counter-error-architecture.png)

ARMv8, the 64-bit architecture, did not run into this issue[^4].
ARMv7, purely 32-bit, was the sole driver of this data anomaly.
Another clue that something in the code specifically for this architecture was causing this.

## Logically unchanged

With a hypothesis what was happening, but no definite answer why, we went to speculative engineering:
Let's avoid the code path that we think is problematic.

By explicitly listing out the different strings we want to have in the payload we avoid the formatting
and thus hopefully any memory confusing.

```rust
let ping_section = match metric.ping_section() {
    "boolean" => "labeled_boolean".to_string(),
    "counter" => "labeled_counter".to_string(),
    // <snip>
    _ => format!("labeled_{}", metric.ping_section()),
};
```

This was implemented in [912fc80][fix-commit] and shipped in [Glean v66.1.2][release-66-1-2].
Landed in Firefox the same day of the release and made it to Firefox for Android Beta last Friday.
And it's working, no more memory confusion!

![The number of errors have been on a downturn ever since the fix landed on 2025-11-26](https://tmp.fnordig.de/blog/2025/2025-12-01-schema-counter-error-downwards.png)

## A bug gone but still there

The immediate incident-causing data anomaly is mitigated, the bug is not making it to the [Firefox 146 release][release146].

My Mozilla colleagues Yannis and Serge have been doing additional work to track down further what exactly is happening in the code.
[The bug][bug2003320] contains more information on the investigation.

While I was trying to read and understand the disassembly of the broken builds
they went ahead and wrote a tiny emulator (based on the [Unicorn engine][unicorn])
that runs just enough of the code to find the offending code path[^5].

```
> python ./emulator.py libxul.so
Path: libxul.so
GNU build id: 1b9e9c8f439b649244c7b3acf649d1f33200f441
Symbol server ID: 8F9C9E1B9B43926444C7B3ACF649D1F30
Please wait, downloading symbols from: https://symbols.mozilla.org/try/libxul.so/8F9C9E1B9B43926444C7B3ACF649D1F30/libxul.so.sym
Please wait, uncompressing symbols...
Please wait, processing symbols...
Proceeding to emulation.
Result of emulation: bytearray(b'schema: ')
This is a BAD build.
```

The relevant section of the code boils down to this:

```asm
ldr   r3, [pc, #0x20c]
add   r3, pc
strd  r3, r0, [sp, #0xd0]
add   r1, sp, #0xd0
bl    alloc::fmt::format_inner
```

> The first two instructions build the pointer to the slice in r3, by using a pc-relative offset found in a nearby constant.
> Then we store that pointer at `sp+0xd0`, and we put the address `sp+0xd0` into `r1`.
> So before we reach `alloc::fmt::format_inner`, `r1` points to a stack location that contains a pointer to the slice of interest.
> The slice lives in `.data.rel.ro` and contains a pointer to the string, and the length of the string (8).
> The string itself lives in `.rodata`.

In good builds the `.rodata` `r3` points to looks like this:

```
0x06f0c3d4: 0x005dac18  -->  "labeled_"
0x06f0c3d8:        0x8
0x06f0c3dc: 0x0185d707  -->  "/builds/<snip>/rust/glean-core/src/storage/mod.rs"
0x06f0c3e0:       0x4d
```

In bad build however it points to something that has our dreaded `schema: ` string:

```
0x06d651c8: 0x010aa2e8  -->  "schema: "
0x06d651cc:        0x8
0x06d651d0: 0x01a869a7  -->  "maintenance: "
0x06d651d4:        0xd
0x06d651d8: 0x01a869b4  -->  "storage dir: "
0x06d651dc:        0xd
0x06d651e0: 0x01a869c8  -->  "from variant of type "
0x06d651e4:       0x15
0x06d651e8: 0x017f793c  -->  ": "
0x06d651ec:        0x2
```

This confirms the suspicion that it's a compiler/linker bug.
Now the question was how to fix that.

Firefox builds with a variety of Clang/LLVM versions.
Mozilla uses its own build of LLVM and Clang to build the final applications,
the exact version used is [updated as soon as possible, but never on release][clang-update-policy].
Sometimes additional patches are applied on top of the Clang release, most often some backports fixing another bug.

After identifying that this is indeed a bug in the linker and that is has been patch in later LLVM versions,
Serge did all the work to bisect the LLVM release to find which patches to apply to Mozilla's own Clang build.
Ultimately he tracked it down to these two patches for LLVM:

* [[InstCombine] Don't handle non-canonical index type in icmp of load fold](https://github.com/llvm/llvm-project/pull/151346)
* [[InstCombine] Make foldCmpLoadFromIndexedGlobal more resiliant to non-array geps.](https://github.com/llvm/llvm-project/pull/150639)

With those patches applied the old code, before we applied the small code rearrangement, does not lead to broken builds anymore.

With the Glean code patched, the ingestion errors dropping and the certainty that we have identified and patched the compiler bug, we can safely ship the next release of Firefox (for Android).

## Collaboration

Incidents are stressful situations, but a great place for collaboration across the whole company.
The number of people involved in resolving this is long.

Thanks to Eduardo & Ben from Data Engineering for raising the issue.  
Thanks to Alessio (my manager) for managing the incident.  
Thanks to chutten and Travis (from my team) for brainstorming what caused this and suggesting solutions/workarounds.  
Thanks to Donal (Release Management) for fast-tracking the mitigation into a Beta release.  
Thanks to Alex (Release Engineering) for some initial investigation into the linker bug.  
Thanks to Brad (Data Science) for handling the data analysis side.  
Thanks to Yannis and Serge (OS integration) for identifying, finding and patching the linker bug.

[1999791]: https://bugzilla.mozilla.org/show_bug.cgi?id=1999791
[data-pipeline]: https://docs.telemetry.mozilla.org/concepts/pipeline/gcp_data_pipeline
[edge-spec]: https://docs.telemetry.mozilla.org/concepts/pipeline/http_edge_spec
[glean]: https://github.com/mozilla/glean
[ping-doc]: https://mozilla.github.io/glean/book/appendix/glossary.html#ping
[mps]: https://github.com/mozilla-services/mozilla-pipeline-schemas
[mps-glean]: https://github.com/mozilla-services/mozilla-pipeline-schemas/blob/main/schemas/glean/glean/glean.1.schema.json
[labeled_counter-spec]: https://github.com/mozilla-services/mozilla-pipeline-schemas/blob/1f4e1dada6a32f7ff1718034c74427b1a351a1df/schemas/glean/glean/glean.1.schema.json#L299-L310
[additionalProperties]: https://github.com/mozilla-services/mozilla-pipeline-schemas/blob/1f4e1dada6a32f7ff1718034c74427b1a351a1df/schemas/glean/glean/glean.1.schema.json#L173
[searchfox-schema]: https://searchfox.org/glean/search?q=schema%3A+&path=*.rs&case=true&regexp=false
[searchfox-schema2]: https://searchfox.org/firefox-main/search?q=%22schema%3A&path=&case=false&regexp=false
[ping_section_format]: https://github.com/mozilla/glean/blob/88e30a21f6bf621757c4139c271afda8c8a6123e/glean-core/src/storage/mod.rs#L35
[mara]: https://marabos.nl/
[format-improvements]: https://hachyderm.io/@Mara/115542621720999480
[format-args]: https://blog.m-ou.se/format-args/
[data-investigations]: https://mozilla.github.io/glean/book/user/howto/investigating-data-issues/investigating-data-issues.html
[arch-commit]: https://github.com/mozilla/glean/commit/8693a13ff9057454984cc4cbff08a1ff712d87ff
[fix-commit]: https://github.com/mozilla/glean/commit/912fc8063575df48c5b3d838944036a1a37d6fc3
[release-66-1-2]: https://github.com/mozilla/glean/releases/tag/v66.1.2
[release146]: https://whattrainisitnow.com/release/?version=146
[bug2003320]: https://bugzilla.mozilla.org/show_bug.cgi?id=2003320
[unicorn]: https://www.unicorn-engine.org/
[clang-update-policy]: https://firefox-source-docs.mozilla.org/build/buildsystem/toolchains-update-policy.html#clang

---

_Footnotes:_

[^1]: Memory corruption is never "simple". But if it were memory corruption we would expect data to be broken worse or in other places too. Not just a string swap in a single place.  
[^2]: That improvement is not yet available to us. The application experiencing the issue was compiled using Rust 1.86.0.  
[^3]: Our checklist initially omitted architecture. [A mistake we since fixed][arch-commit].  
[^4]: Apparently we do see _some_ errors, but they are so infrequent that we can ignore them for now.  
[^5]: Later Yannis wrote a script that can identify broken builds purely much quicker, just by searching for the right string patterns.
