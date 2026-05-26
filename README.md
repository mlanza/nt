# Note

**Note** is a command line tool for managing text content — skills, commands, prompts, rules, knowledge, whatever the flavor — in a local [Logseq](https://logseq.com) repo.  Unlike MCP Servers, CLIs are ephemeral, composeable and available to humans 🧔🏼 and agents 🤖 alike .

<p align="center">
  <img src="./images/logo.png" style="width: 300px; max-width: 100%;" />
</p>

Your local-first commonplace book 📖 is memory scaffolding, a near perfect spot for accessing and keeping the information and instructions an agent needs to thrive — all in an ubiquitous language of your making.  How better to align with and teach an agent your craft than by sharing your second 🧠 with it.

The tool was designed to minimize ceremony, to compose, and to mind the Unix philosophy.  That's why subcommands can frequently receive the primary operand directly or via stdin.

<details>
  <summary><code>nt --help</code></summary>

```console
Usage:   nt
Version: 1.0.0-beta

Description:

  A general-purpose tool for interacting with Logseq content.

   📨 = supply primary argument directly or pipe them in
   📥 = pipeline-only operations

Options:

  -h, --help     - Show this help.
  -V, --version  - Show the version number for this program.

Commands:

  pages                                   - List pages
  page, p         [name|datestamp]        - Get page 📨
  post            [name] [content]        - Sends content to page or, if omitted, to today's journal entry 📥
  write           <name>                  - Write page from stdin
  wipe            [name]                  - Wipe content, but not properties, from a page
  export          <name>                  - Export page content to destination
  tags, t         [tags...]               - List pages with all the given tags 📨
  has, h          [prop] [vals...]        - List pages having a given prop with value(s) 📨
  prereq          [name]                  - Recursively list page prerequisites 📨
  path            [name]                  - The path to the page file 📨
  props           [name] [properties...]  - Get page properties 📨
  search, s       [term]                  - Search pages 📨
  name, n         [id|name]               - Get page name as cased from page ID or case-insensitive name. 📨
  alias           [alias]                 - Get page name from alias 📨
  backlinks, b    [name]                  - List pages that link to a given page 📨
  query, q        <query> [args...]       - Run Datalog query supplying args 📨
  list, l         [item...]               - List items
  day, d          [offset]                - Find date from offset 📨
  skills                                  - List skills and their descriptions
  about, a        [name...]               - Retrieves information about a topic including prequisites
  prompt                                  - Expands wikilinks in a prompt, ignoring fenced code blocks 📨
  prop            📥                      - Rewrite page properties
  parse           📥                      - Convert flat markdown to structured blocks
  stringify, str  📥                      - Convert structured blocks back to markdown
  seen            📥                      - Filters to seen lines
  exists          📥                      - Filters paths for existing files
  links           📥                      - Extracts links from content
  wikilinks       📥                      - Extracts wikilinks from content
  sections        📥                      - Filter content by Markdown section names
  clean           📥                      - Clean invisible and zero-width control characters
  config                                  - Show configuration
```

</details>

## Conjuring and Composing Context

You gain a suite of commands for retrieving and reusing carefully-crafted context:

```zsh
nt page Atomic
```

It makes your ubiquitous language — the concepts, rules, workflows, and skills you're perpetually refining — modular, portable, and agent agnostic.  Your context goes with you *wherever you are*, whether in [Pi](https://pi.dev), [OpenCode](https://opencode.ai), Gemini, or Claude Code.  Conjure it into conversations.

It happens when you key wikilinks into your prompts, such that

```md
You are [[Coding]] a Sokoban game using [[Atomic]].
```

is expanded.  In addition to the prompt you entered you also get the Coding page, the Atomic page, the prerequisites of both, and their prerequisites, recursively.  It elevates Logseq into a first-class, local-first retrieval system.

> 💡 As a rule of thumb, I name skills using gerunds — sometimes a single word like Coding or Debugging, other times a more specific gerund phrase like Writing Documentation or Planning Releases. I treat skills as recurring activities or modes of work: practices worth refining and reusing.

**Prerequisites** are the backbone, a lightweight form of inheritance.  Concepts build on other concepts, recursively pulling in the necessary context.  Prompting, in turn, becomes an act of composition: combining modular pieces of language, craft, and instruction deliberately.

Unlike some [RAG](https://en.wikipedia.org/wiki/Retrieval-augmented_generation) systems, things intentionally remain transparent and predictable.  You're not guessing what system prompt or retrieval process an agent is using.  You're designing pages and their connections so that in every chat you control how context combines and decide exactly what enters the conversation.

## Getting Started

Install it in a preferred location:

```zsh
git clone https://github.com/mlanza/nt.git ~/.local/share/nt
```

Set `nt` on path in your profile:

```zsh
export PATH="$HOME/.local/share/nt/bin:$PATH"
```

Set these env vars:

* **LOGSEQ_REPO** - path to the Logseq repo
* **LOGSEQ_ENDPOINT** - HTTP API endpoint (default is http://127.0.0.1:12315/api)
* **LOGSEQ_TOKEN** - a token you configured for the HTTP API
* **NOTE_CONFIG** - path to optional config (e.g., `~/.config/nt/config.toml`)

The config file, in addition to providing an alternate means to setting `repo`, `endpoint`, and `token`, is useful for [content filtering](#content-filtering).

```toml
# config.toml
[logseq]
repo = '~/Documents/notes' # on Windows: 'D:\notes'
endpoint = 'http://127.0.0.1:12315/api'
token = 'mellon'
```

Ensure `pwsh` and `deno` are installed.

Run Logseq in Developer Mode.  Flip it on under `Settings > Advanced`.  Then enable the local HTTP API via the button in the upper right. You must [set up a token](https://wiki.jamesravey.me/books/software-misc/page/logseq-http-api).  This setup and tooling transforms Logseq into a lightweight MCP server.

## Going Deeper

### Prompt Expansion

An agent, naturally, has access to nt as a command line tool. The prompt expansion feature must be installed separately. Once installed, wikilinks entered into prompts expand automatically.

This feature is my daily driver — the lever that feels magical when used. Like casting a spell. That’s why I describe it as “conjuring.”

#### Pi (π)

Point the agent at your your `nt` installation:

```zsh
pi install ~/.local/share/nt/adapters/pi/nt.js
```

### Generating `AGENTS.md`

While technically possible to give the agent a robust `AGENTS.md` describing all the activities you perform together, there's no need.  If your Logseq pages are well-defined and modular, conjure the page for the activity when the need arises.

Instead, bootstrap only the fundamentals in `AGENTS.md`.  Mine currently looks like this:

```md
# Agent Instructions
prerequisites:: [[Ubiquitous Language]], [[Director]]
Your chief aim is aligning yourself with and serving the [[Director]].  It helps to understand his values and methodology.  Recognizing and looking up the [[Ubiquitous Language]] by which he communicates aids this.
```

And I generate it occasionally to real filesystem locations only to avoid having to start every chat session by repeating the basics.

```zsh
nt about "Agent Instructions" | nt document --para | cat -s
```

The ubiquitous language I refer to there are wiki terms, things I've deliberately defined in Logseq pages.  The page about Ubiquitous Language is linked to a preprequisite skill telling the agent how to navigate terms with `nt`.

While I code routinely, I don't mention **Coding** in `AGENTS.md`.   That's because when it's time to code, the mere mention of it — a sentence like the one in the intro — conjures context tailor-made to the activity:

```md
# Coding
tags:: AI, Skill, [[Command Line]], [[Atomic Way]]
prerequisites:: [[Designing for Validation]], [[Keeping a Notepad]], [[Ensuring Reversibility]], [[Delivering in Baby Steps]], [[Core Docs]]
description:: Use when developing or debugging a program or an app.
You are [[Keeping a Notepad]] and [[Ensuring Reversibility]] while [[Delivering in Baby Steps]].
```

Each piece of that prompt links to some recursively-expanded skill or context.  **Ensuring Reversibility** explains using `git` as a safety net for all filesystem changes.

No need to track skills in the filesystem the way most agent runtimes prescribe.  Logseq subsumes skills, commands and most other jobs since everything agents do, more or less, relies on putting the right context in front of them at the right time.

### Progressive Disclosure

Take skills.  Want to provide a menu of capabilities?  Create a Logseq page called `Skill`. Then start defining pages, tagging them `Skill`, and adding a `description` property.

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
tags:: AI, Skill, [[Command Line]], [[Atomic Way]]
prerequisites:: [[Designing for Validation]], [[Keeping a Notepad]], [[Ensuring Reversibility]], [[Delivering in Baby Steps]], [[Core Docs]]
description:: Use when developing or debugging a program or an app.
```

### Prerequisites

Some topics build on other other topics and cannot stand on their own.  These pages require that added context to make sense.  Include a `prerequisites` property on the page that links to any prerequisites.  Whenever the page is retrieved via `about` or `prompt`, they'll automatically — and recursively — be included.

```zsh
nt prompt "You are [[Coding]] a Sokoban game using [[Atomic]]."
```

The above identifies the terms and where it might call

```zsh
nt list Coding Atomic | nt page
```

that doesn't go far enough.  That would expose just the 2 pages themselves.  Rather it calls

```zsh
nt list Coding Atomic | nt about
```

which goes farther.  It recursively expands page prerequisites.

### Content Filtering

The typical way to view a page is via `nt page`:
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
Internally, this is what `about` does to faciliate a clean agent hand-off.

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

Store named queries in the config

```toml
[query]
page = '[:find (pull ?p [*]) :where [?p :block/original-name "$1"]]'
```

to enable shorthand calls:

```zsh
nt q page Atomic
```

Add as many as you like:

```toml
between = """
[:find (pull ?b [*])
  :in $ ?start ?end
  :where
  [?b :block/content ?blockcontent]
  [?b :block/page ?page]
  [?page :block/name ?name]
  [?b :block/scheduled ?scheduled]
  [(>= ?scheduled ?start)]
  [(<= ?scheduled ?end)]]
"""
```
```zsh
nt q between 20260501 20260601
```

These calls return JSON.

Any quirks around whether a query runs come from the HTTP API’s implementation, not from `nt` itself. If you’re testing what the API does or doesn’t support, call it directly with `curl`.  For example, if you get

```zsh
Error: Missing rules var '%' in :in
```

there's likely something in the advanced query syntax it can't support.

Look [here](https://adxsoft.github.io/logseqadvancedquerybuilder/) for help forming valid queries.

## License
[MIT](./LICENSE.md)
