# Note

**Note** is a command line tool for managing text content — Skills, Commands, Prompts, Rules, Knowledge, whatever the flavor — in a local [Logseq](https://logseq.com) repo.  Unlike MCP Servers, CLIs are ephemeral, composeable and available to humans 🧔🏼 and agents 🤖 alike .

<p align="center">
  <img src="./images/logo.png" style="width: 300px; max-width: 100%;" />
</p>

Your local-first commonplace book 📖 is memory scaffolding, a near perfect spot for accessing and keeping the information and instructions an agent needs to thrive — all in an ubiquitous language of your making.  How better to align with and teach an agent your craft than by sharing your second 🧠 with it.

The tool was designed to minimize ceremony, to compose, and to mind the Unix philosophy.  That's why subcommands can frequently receive the primary operand directly or via stdin.

## Getting Started

Install the tool into your path or extend your path, whichever you like:
```zsh
export PATH=~/Documents/nt/bin:$PATH
```

Have `pwsh` and `deno` and `node` installed.  The interal scripts target these runtimes over `zsh` and `bash` to accommodate everyone, whether on Mac, Linux or Windows.

Run Logseq in Developer Mode.  Flip it on under `Settings > Advanced`.  Then enable the local HTTP API via the button in the upper right. You must [set up a token](https://wiki.jamesravey.me/books/software-misc/page/logseq-http-api).  This setup and tooling transforms Logseq into a lightweight MCP server.

Create a config file in the default location `~/.config/nt/config.toml`.  If you prefer to keep it elsewhere specify where in the environment var:

* **NOTE_CONFIG** - path to config file

In it, specify your `repo`, `endpoint`, and `token`:

```toml
# config.toml
[logseq]
repo = 'D:\notes'
endpoint = 'http://127.0.0.1:12315/api'
token = 'mellon'
```

Or omit it and specify them as environment vars:

* **LOGSEQ_REPO** - path to the Logseq repo
* **LOGSEQ_ENDPOINT** - HTTP API endpoint (default is http://127.0.0.1:12315/api)
* **LOGSEQ_TOKEN** - a token you configured for the HTTP API

Once done, start Logseq, and then your shell. Issue some commands.

```zsh
nt page Atomic # show some page, for example
```

These commands can, of course, be issued directly in [pi](https://pi.dev), [OpenCode](https://opencode.ai), Gemini, Claude, etc.  — by you or by any agent with with [computer use](https://www.anthropic.com/news/3-5-models-and-computer-use).

### Agent Integration

Plug it into your favorite agent.

### Pi (π)

From wherever `nt` exists:

```zsh
pi install ~/Documents/nt/adapters/pi/nt.js
```

## Going Deeper

### Automatic Prompt Expansion

Key wikilinks into your prompts, such that

```md
You are [[Coding]] a Sokoban game using [[Atomic]].
```

is expanded and enriched with your Logseq content.  This can be skills, instructions — anything at all.  This happens recursively by expanding any `prerequisites` it encounters.  It also filters selective blocks that might otherwise confuse the agent.

Since this only happens with wikilinks, omit them to interact with your agent as usual.

### Generating `AGENTS.md`

While technically possible to give the agent a minimal `AGENTS.md` and ask it to lookup even the baseline instructions, that's just slow.  Although the content will be redundant (in Logseq and in your filesystem), it's more expedient to bootstrap your agent from a file written to your project or to the designated place used by your preferred agentic runtime.

The following assumes the target page `prerequisites` is replete with your most crucial rules and instructions.  The `document` command slightly flattens Logseq's outline formatting.

```zsh
nt about "Agent Instructions" --agent | nt document --para | cat -s
```

### Progressive Disclosure

Take skills.  Want to provide a menu of capabilities?  Create a page called `Skills` in Logseq with some general instruction for skill use for agents. Then start defining pages, tagging them `Skills`, and add a `description` property.

After defining a bunch, they can, conveniently, be listed via:

```zsh
nt skills
```

Seeing the properties — or frontmatter — for a page gives a sense of it:

```zsh
nt props Coding
```

```md
# Coding
tags:: AI, [[Making apps]], Skills
alias:: [[Spec Coding]], [[Vibe Coding]]
prerequisites:: [[Clojure Way]], [[Coding Style]]
description:: Use when you're writing, refactoring or fixing code
```

### Prerequisites

Some topics build on other other topics and cannot stand on their own.  These pages require that added context to make sense.  Include a `prerequisites` property on the page that links to any prerequisites.  Whenever the page is retrieved via `about`, they'll automatically — and recursively — be included.

```zsh
nt about Coding
```

### Content Filtering

The most typical way to view a page is handing a page name to the `nt page` command:
```zsh
nt page Atomic
```

Because I use Logseq for both [PKM](https://en.wikipedia.org/wiki/Personal_knowledge_management) and [GTD](https://en.wikipedia.org/wiki/Getting_Things_Done), my pages have mixed content.  I have pages with a smattering of links to interesting sites and — since some are projects — tasks in various stages.  A page may also have information and/or instructions.

Some content is useful only to me.  It's not a question of sensitivity or leaks. I don't keep that kind of content in my stores.  It's about making a good hand-off to an agent.  I don't want it seeing meaningless or confusing context.

To help, `nt` provides basic filtering.  A filter operates at the block level on what is effectively a single line in Logseq.  If a block is filtered, it carries with it all its children.

This command filters out task blocks:

```zsh
nt page Atomic --less '^(TODO|DOING|DONE|LATER|NOW|CANCELED|WAITING)'
```

While, conversely, this one shows only task blocks:

```zsh
nt page Atomic --only '^(TODO|DOING|DONE|LATER|NOW|CANCELED|WAITING)'
```

You can send in multiple values:

```zsh
nt page Atomic --less '^https?://[^)]+$' --less '^[.*](https?://[^)]+)$'
```

But typing that will get tedious fast.  Better to define in and select from filter tables in config.  Since the default filter is `agent`, let's define it:

```toml
[agent]
props = "^[^\\s:]+::"
tasks = "^(TODO|DOING|DONE|LATER|NOW|CANCELED|WAITING)"
links = "^\\s*(?:https?:\\/\\/\\S+|\\[[^\\]\\r\\n]+\\]\\(\\s*https?:\\/\\/[^\\s)]+(?:\\s+\"[^\"\\r\\n]*\")?\\s*\\))\\s*$"
```

Having that, you can exclude blocks by their keys:
```zsh
nt page Atomic --less tasks
```

Or include blocks by their keys:
```zsh
nt page Atomic --only tasks
```

Or target multiple:

```zsh
nt page Atomic --less tasks --less links
```

Some of the examples in the tool `--help` anticipate these defintions.

This displays content for the **human** and shows what'd normally be filtered out:
```zsh
nt page Atomic --only
```

This one is for the **agent** and filters out that noise:
```zsh
nt page Atomic --less
```
Internally, this what `about` does to faciliate a clean agent hand-off.

The following option flags are synonyms — their audience-focused terms: memory aids.
```zsh
nt page Atomic --human # i.e., only
nt page Atomic --agent # i.e., less
```

If you have other filtering needs, you can define another filter table, then select it with `--filter`.  It all works the same except for swapping the filter source.

```zsh
nt page Atomic --only --filter=public
nt page Atomic --less --filter=public
```

### Querying via Datalog

Logseq's superpower is its [DataScript](https://github.com/tonsky/datascript) spine.  With Datalog queries in easy reach, there's no limit to the queries and custom commands you can build.  The innards build on this.  They can be parameterized.

It's a reason to prefer Logseq to Obsidian.

```zsh
nt q '[:find (pull ?p [*]) :where [?p :block/original-name "$1"]]' Atomic
```

Any quirks around whether a query runs come from the HTTP API’s implementation, not from `nt` itself. If you’re testing what the API does or doesn’t support, call it directly with `curl`.  For example, if you get

```zsh
Error: Missing rules var '%' in :in
```

there's likely something in the advanced query syntax it can't support.

Look here for help forming valid queries:

* https://adxsoft.github.io/logseqadvancedquerybuilder/

## License
[MIT](./LICENSE.md)
