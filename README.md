# sh-gettext

Fully portable gettext library for POSIX-compliant shell scripts.

## Introduction

sh-gettext is an easy to use and highly portable internationalization library for shell scripts. It supports all POSIX-compliant shells and can run in any environment. It is based on the gettext API and only commands `gettext` and `ngettext` are required. These API and commands will be standardized in POSIX.1-2023 (Issue 8). sh-gettext works with OS standard commands. If these commands are not installed, fallback to work with default messages.

This is an alternative library that aims to replace [GNU `gettext.sh`](https://www.gnu.org/software/gettext/manual/html_node/sh.html). It is currently in beta release. We will try to maintain the specifications as much as possible, but may change them in the future.

## sh-gettext vs GNU gettext.sh

|                                                       | sh-gettext     | GNU gettext.sh              |
| ----------------------------------------------------- | -------------- | --------------------------- |
| Portability                                           | Fully portable | Depends on GNU gettext      |
| Supported gettext implementation                      | All supported  | GNU gettext and compatibles |
| POSIX shells (modern sh, dash, bash and others)       | All supported  | All supported (probably)    |
| Bourne shell (obsolete sh)                            | No             | Yes (probably)              |
| Use only POSIX (Issue 8) commands                     | Yes            | No (depends on `envsubst`)  |
| Environment without `gettext` and `ngettext` commands | Works          | Does not work               |
| Dollar-Single-Quotes (`$'...'`) for MSGID             | All supported  | Shell dependent             |
| Parameter field (`%1$s`)                              | All supported  | Shell dependent             |
| Locale-dependent number separator (`%'d`)             | All supported  | Shell dependent             |
| Locale-dependent decimal point symbols (`.`, `,`)     | All supported  | Shell dependent             |
| Shorthand                                             | `_`, `_n`      | Nothing                     |
| Faster than GNU gettext.sh                            | Yes            | No                          |

## Tutorial

```sh
#!/bin/sh

set -eu

. "${0%/*}/lib/sh-gettext.sh"

export TEXTDOMAIN="sh-gettext-example"
export TEXTDOMAINDIR="${0%/*}/locale"

echo "==== Basic ===="
_ 'Hello World.'
_ 'Hello, %s.' -- Ken
echo

echo "==== Plural forms ===="
_n 'Here is %d apple.' 'Here are %d apples.' 2
_n '%2$s has %1$d apple.' '%2$s has %1$d apples.' 1 Ken
echo

echo "==== Using backslash escape sequences ===="
_ $'Here is a tab =>\t<=.'
_ $'It\047s a small world.\n' -n
echo

echo "==== Locale-dependent numeric values ===="
_ "The distance from the earth to the sun is %'d km." 149597870000
_ "PI is %f." 3.1415926535
echo

echo "==== Use \$'...' for msgid that begin with \$. ===="
_ $'$100 is about %\047d Japanese yen.' $((100 * 130))
```

```console
$ LANG=ja_JP.UTF-8 ./example.sh
==== Basic ====
こんにちは世界。
こんにちは、Ken。

==== Plural forms ====
ここに 2 個のリンゴがあります。
Ken は 1 個のリンゴを持っています。

==== Using backslash escape sequences ====
ここにはタブ =>	<= があります。
世界は小さい。

==== Using decimal separator ====
地球から太陽までの距離は 149,597,870,000 km です。
円周率は 3.141593 です。

==== Use $'...' for msgid that begin with $. ====
$100 ドルは日本円でおそよ 13,000 円です。
```

**NOTE:** If it cannot be translated, the message catalog may need to be reworked.

```sh
msgfmt -o locale/ja/LC_MESSAGES/sh-gettext-example.mo po/ja.po
```

## Requirements

- **POSIX shell**
  - dash, bash, ksh, zsh, etc
- **`gettext` and `ngettext` commands**
  - These commands are standardized in POSIX issue 8
  - If not installed, fall back to the implementation without translation
- `msgfmt` command (Recommendation)
- `xgettext` with shell script support (Development)

`gettext`, `ngettext`, `msgfmt`, and `xgettext` are standardized in POSIX.1-2023 (Issue 8).

## API

- Functions
  - [shgettext\_print ( \_ )](#shgettext_print--_-)
  - [shgettext\_nprint ( \_n )](#shgettext_nprint--_n-)
  - [shgettext\_gettext](#shgettext_gettext)
  - [shgettext\_ngettext](#shgettext_ngettext)
  - [shgettext\_printf](#shgettext_printf)
  - [shgettext\_echo](#shgettext_echo)
  - [shgettext\_replace\_all](#shgettext_replace_all)
  - [shgettext\_detect\_decimal\_point](#shgettext_detect_decimal_point)
- Environment Variables
  - [SHGETTEXT\_GETTEXT, SHGETTEXT\_NGETTEXT](#shgettext_gettext-shgettext_ngettext)
  - [SHGETTEXT\_PRINTF](#shgettext_printf-1)

### MSGID

MSGID is the key used for translation. For example, `_ "Hello World"`, `_ 'Hello World'`, `_ $'Hello World'` would be the MSGID of the message `Hello World`. If no translation is found, the MSGID is output as is.

It is not possible to include variables or command substitutions in the MSGID. To be precise, the translation itself works, but `xgettext`, which generates the message catalog, does not recognize it as a string to be translated.

```sh
# Wrong MSGIDs
_ "Hello${TAB}World"
_ "Hello$(printf '\t')World"
```

`$'...'` is a shell feature called "Dollar-Single-Quotes" that will be standardized in POSIX Issue 8. When newlines or tabs are included in A `$'...'`, it can be written with escape sequences like `$'FOO\tBAR\n'`.

Dollar-Single-Quotes is a feature that is already available in many shells, such as bash, but not yet in dash. However, sh-gettext implements a workaround so that Dollar-Single-Quotes can be used in shells that do not support Dollar-Single-Quotes as far as MSGID is concerned (The feature does not make Dollar-Single-Quote available to the entire shell script). If Dollar-Single-Quotes is not used, it could be written as follows, but it would be difficult to read.

```sh
_ 'Hello	World' # It contains a tab character
_ 'Hello
World' # It contains a newline character

_ $'Hello\tWorld\n' # Legible
```

#### Dollar-Single-Quotes Limitations

sh-gettext has the unique feature of being able to use Dollar-Single-Quotes with MSGID, which is useful for including tabs and newlines in messages. However, the following Limitations are made so that shells that support Dollar-Single-Quotes and shells that do not support Dollar-Single-Quotes can be written in the same way.

**If the first character of the MSGID is `$`, it cannot be written as `'MSGID'` or `"MSGID"`.** If the first character is `$`, you must write `$'$ is dollar'`. This is because shells that do not support dollar-single quoting use the leading `$` to determine whether to interpret backslash escape sequences.

```sh
#  Shells that do not support $'...' cannot distinguish between
_ '$ is dollar'
_ $'is dollar'

# It should be written as follows
_ $'$ is dollar'
```

**Cannot split a string into multiple quotes.** The entire message must be written in a single Dollar-Single-Quote. This is because the decision to interpret backslash escape sequences is made only at the beginning of the string.

```sh
# The entire message must be written in one $'...'
_ $'Hello world\n'    # Correct
_ $'Hello '$'world\n' # Wrong
_ $'Hello ''world\n'  # Wrong
```

**If you want to include single quotes in a string, you cannot use `\'`.** You must use `\47` or `\047` instead.

```sh
# Wrong
_ $'It\'s a small world\n'

# Correct
_ $'It\47s a small world\n'
_ $'It\047s a small world\n'
```

Despite this limitation, we believe it is more convenient to make Dollar-Single-Quote available because messages often contain tabs and newlines.

### shgettext_print ( _ )

```txt
_ MSGID [-n | --] [ARGUMENT]...
shgettext_print MSGID [-n | --] [ARGUMENT]...
```

In many other programming languages, `_` is an alias for the `gettext` function, but in sh-gettext it is an alias for the `shgettext_print` shell function. The `shgettext_print` shell function performs variable expansion, similar to the `eval_gettext` shell function in `gettext.sh`.

The second argument is a flag, specify `-n` or `--`. If `-n` is specified, suppresses output of trailing a newline. If `--` is specified, a newline is output. `--` is optional, but we recommend not omitting it given the possibility that the value of ARGUMENT is `--`.

If the MSGID contains the `%` format, the arguments are expanded and the value passed in ARGUMENT is assigned. See `shgettext_printf` for about format.

### shgettext_nprint ( _n )

```txt
_n MSGID MSGID-PLURAL [-n | --] N [ARGUMENT]...
shgettext_nprint MSGID MSGID-PLURAL [-n | --] N [ARGUMENT]...
```

Use `_n` to internationalize messages for plurals. It is an alias for the `shgettext_nprint` shell function. The `shgettext_nprint` shell function performs variable expansion, similar to the `eval_ngettext` shell function in `gettext.sh`.

The third argument is a flag, specify `-n` or `--`. If `-n` is specified, suppresses output of trailing a newline. If `--` is specified, a newline is output. `--` is optional. Since the next argument is numeric, `--` can safely be omitted.

If the fourth argument is `1`, MSGID is used as the message; if it is not `1`, MSGID-PLURAL is used.

If the MSGID contains the `%` format, the arguments are expanded and the value passed in ARGUMENT is assigned. See `shgettext_printf` for about format.

### shgettext_gettext

```txt
shgettext_gettext MSGID
```

Equivalent to `gettext -E`. Options are not available and escape sequences are not interpreted.

### shgettext_ngettext

```txt
shgettext_ngettext MSGID MSGID-PLURAL N
```

Equivalent to `ngettext -E`. Options are not available and escape sequences are not interpreted.

### shgettext_printf

```txt
shgettext_printf FORMAT [ARGUMENT]...
```

The values passed in ARGUMENT is expanded according to FORMAT. It internally executes the `printf` command and basically interprets the same format as the `printf` command, but with the following differences.

- Supports positional variable references with the format `<number>$`
- Support for output grouping numbers by the `'` flag (e.g. `%'d`)
  - If the `printf` implementation does not support the `'` flag, it is ignored
- Arguments remaining after FORMAT consumes arguments are ignored
- If the argument referenced by FORMAT does not exist, the format remains in place

### shgettext_echo

```txt
shgettext_echo STRING
```

This function is provided as a transition from `gettext.sh`. Those who don't need it don't need to use it. It has the same functionality as the function set in `the $echo` variable of `gettext.sh`, outputting the first argument and newline and not interpreting backslash escape sequences.

If you want, you can have it do the equivalent of `$echo` by doing the following

```txt
echo='shgettext_echo'
$echo foo
```

For more information on `$echo`, see [here](https://www.gnu.org/software/gettext/manual/html_node/gettext_002esh.html).

### shgettext_replace_all

```txt
shgettext_replace_all VAR ARGUMENT SEARCH REPLACE
```

Replace all SEARCHs found in ARGUMENT with REPLACE and assign them to VAR variable.

### shgettext_detect_decimal_point

```txt
shgettext_detect_decimal_point STRING
```

Re-detect locale-dependent decimal point symbols.

## Environment Variables

### SHGETTEXT_GETTEXT, SHGETTEXT_NGETTEXT

Set this environment variable if you want to use different implementations of `gettext` and `ngettext`. It must be set before loading `sh-gettext.sh`.

```sh
if type ggettext >/dev/null 2>&1; then
  SHGETTEXT_GETTEXT=ggettext
fi

. sh-gettext.sh
```

### SHGETTEXT_PRINTF

Set this environment variable if you want to use different implementations of `printf`. It must be set before loading `sh-gettext.sh`.

```sh
SHGETTEXT_PRINTF=/usr/bin/printf

. sh-gettext.sh
```

## Notes on using the xgettext command

To create a message catalog, see [here](https://www.gnu.org/software/gettext/manual/html_node/index.html).

Since the messages to be translated are defined by keywords that differ from the standard, an option to add the keywords must be specified.

```sh
# To add only _ and _n as keywords
xgettext -k_:1 -k_n:1,2 example.sh

# To add all functions as keywords
xgettext -k_:1 -k_n:1,2 -kshgettext_gettext:1 -kshgettext_ngettext:1,2 example.sh

# In POSIX, -K option is standardized instead of -k option.
# (I don't know of any implementation that can use the -K option)
xgettext -K _:1 -K _n:1,2 example.sh
xgettext -K _:1 -K _n:1,2 -K shgettext_gettext:1 -K shgettext_ngettext:1,2 example.sh
```
