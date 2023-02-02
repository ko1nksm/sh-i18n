# sh-i18n

Fully portable gettext library for POSIX-compliant shell scripts.

## Introduction

sh-i18n is an easy to use and highly portable internationalization library for shell scripts. It supports all POSIX-compliant shells and can run in any environment. It is based on the gettext API and only commands `gettext` and `ngettext` are required. These API and commands will be standardized in POSIX.1-2023 (Issue 8). sh-i18n works with OS standard commands. If these commands are not installed, fallback to work with default messages.

This is an alternative library that aims to replace [GNU `gettext.sh`](https://www.gnu.org/software/gettext/manual/html_node/sh.html). It is currently in **beta release**. We will try to maintain the specifications as much as possible, but may change them in the future.

## sh-i18n vs GNU gettext.sh

|                                                      | sh-i18n          | GNU gettext.sh             |
| ---------------------------------------------------- | ---------------- | -------------------------- |
| Portability                                          | ✅ Fully portable | Depends on GNU `gettext`   |
| POSIX shells (modern sh, dash, bash and others)      | ✅ All supported  | ✅ All supported (probably) |
| Bourne shell (obsolete sh)                           | No               | ✅ Yes (probably)           |
| Use only POSIX (Issue 8) commands                    | ✅ Yes            | No (depends on `envsubst`) |
| Environment without `gettext`, `ngettext` commands   | ✅ Works          | Does not work              |
| Shorthand (`_`, `n_`, `s_`, `ns_`, `p_`, `np_`)      | ✅ Available      | Nothing                    |
| `gettext_noop` (`N_`) and similar                    | ✅ Available      | Nothing                    |
| `sgettext`, `nsgettext`                              | ✅ Available      | Nothing                    |
| `pgettext`, `npgettext` (GNU gettext extensions)     | ✅ Available      | ✅ Available                |
| Dollar-Single-Quotes (`$'...'`) for MSGID            | ✅ All supported  | Shell dependent            |
| Parameter field (`%1$s`)                             | ✅ All supported  | Shell dependent            |
| Locale-dependent number separator (`%'d`)            | ✅ All supported  | Shell dependent            |
| Locale-dependent decimal point symbols (`.` `,` `٫`) | ✅ All supported  | Shell dependent            |
| Faster than GNU gettext.sh                           | ✅ Yes            | No                         |

## Tutorial

```sh
#!/bin/sh

set -eu

. "${0%/*}/lib/i18n.sh"

export TEXTDOMAIN="sh-i18n"
export TEXTDOMAINDIR="${0%/*}/locale"

# Used in some XSI-compliant environments (e.g. OpenIndiana)
export NLSPATH="${0%/*}/locale/%l/LC_MESSAGES/%N.mo"

echo "==== Basic ===="
_ 'Hello World.'
_ 'Hello, %s.' -- Ken
echo

echo "==== Plural forms ===="
n_ 'Here is %d apple.' 'Here are %d apples.' 2
n_ '%2$s has %1$d apple.' '%2$s has %1$d apples.' 1 Ken
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
msgfmt -o locale/ja/LC_MESSAGES/sh-i18n.mo po/ja.po
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

Shells that we have decided not to support due to shell bugs:

- pdksh (v5.2.14 99/07/13.2), posh (0.14.1)
  - bug: `set -- abc a; echo ${1#"$2"}` => falsely empty
- ksh88 (Version M-11/16/88), ksh93 (Version JM 93t+ 2009-05-01)
  - bug: "@: parameter not set" (It works if you don't `set -u`)
- bash (2.04)
  - bug: Segmentation fault

## API

Gettext Functions

| Basic                                   | Context (p)                                 | Scope (s)                                   |
| --------------------------------------- | ------------------------------------------- | ------------------------------------------- |
| [i18n_print ( _ )](#i18n_print--_-)     | [i18n_pprint ( p_ )](#i18n_pprint--p_-)     | [i18n_sprint ( s_ )](#i18n_sprint--s_-)     |
| [i18n_nprint ( n_ )](#i18n_nprint--n_-) | [i18n_npprint ( np_ )](#i18n_npprint--np_-) | [i18n_nsprint ( ns_ )](#i18n_nsprint--ns_-) |
| [i18n_gettext](#i18n_gettext)           | [i18n_pgettext](#i18n_pgettext)             | [i18n_sgettext](#i18n_sgettext)             |
| [i18n_ngettext](#i18n_ngettext)         | [i18n_npgettext](#i18n_npgettext)           | [i18n_nsgettext](#i18n_nsgettext)           |

Gettext Helper (experimental)

- [i18n_build_array](#i18n_build_array)
- [i18n_set_array](#i18n_set_array)
- [i18n_gettext_noop ( N_ )](#i18n_gettext_noop--n_-)
- [i18n_gettext_s2v ( S_ )](#i18n_gettext_s2v--s_-)
- [i18n_gettext_a2p ( @_ )](#i18n_gettext_a2p--_-_)
- [i18n_gettext_a2v ( V_ )](#i18n_gettext_a2v--v_-)
- [i18n_gettext_a2a ( A_ )](#i18n_gettext_a2a--a_-)
- [i18n_gettext_a2aa ( AA_ )](#i18n_gettext_a2aa--aa_-)

Utilities

- [i18n_printf](#i18n_printf)
- [i18n_printfln](#i18n_printfln)
- [i18n_echo](#i18n_echo)
- [i18n_detect_decimal_point](#i18n_detect_decimal_point)

Environment Variables

- [I18N_GETTEXT, I18N_NGETTEXT](#i18n_gettext-i18n_ngettext)
- [I18N_PRINTF](#i18n_printf-1)

### MSGID

MSGID is the key used for translation. For example, `_ "Hello World"`, `_ 'Hello World'`, `_ $'Hello World'` would be the MSGID of the message `Hello World`. If no translation is found, the MSGID is output as is.

It is not possible to include variables or command substitutions in the MSGID. To be precise, the translation itself works, but `xgettext`, which generates the message catalog, does not recognize it as a string to be translated.

```sh
# Wrong MSGIDs
_ "Hello${TAB}World"
_ "Hello$(printf '\t')World"
```

`$'...'` is a shell feature called "Dollar-Single-Quotes" that will be standardized in POSIX Issue 8. When newlines or tabs are included in A `$'...'`, it can be written with escape sequences like `$'FOO\tBAR\n'`.

Dollar-Single-Quotes is a feature that is already available in many shells, such as bash, but not yet in dash. However, sh-i18n implements a workaround so that Dollar-Single-Quotes can be used in shells that do not support Dollar-Single-Quotes as far as MSGID is concerned (The feature does not make Dollar-Single-Quote available to the entire shell script). If Dollar-Single-Quotes is not used, it could be written as follows, but it would be difficult to read.

```sh
_ 'Hello	World' # It contains a tab character
_ 'Hello
World' # It contains a newline character

_ $'Hello\tWorld\n' # Legible
```

#### Dollar-Single-Quotes Limitations

sh-i18n has the unique feature of being able to use Dollar-Single-Quotes with MSGID, which is useful for including tabs and newlines in messages. However, the following Limitations are made so that shells that support Dollar-Single-Quotes and shells that do not support Dollar-Single-Quotes can be written in the same way.

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

### Gettext Functions

#### i18n_print ( _ )

```txt
_ MSGID [-n | --] [ARGUMENT]...
i18n_print MSGID [-n | --] [ARGUMENT]...
```

In many other programming languages, `_` is an alias for the `gettext` function, but in sh-i18n it is an alias for the `i18n_print` shell function. The `i18n_print` shell function performs variable expansion, similar to the `eval_gettext` shell function in `gettext.sh`.

The second argument is a flag, specify `-n` or `--`. If `-n` is specified, suppresses output of trailing a newline. If `--` is specified, a newline is output. `--` is optional, but we recommend not omitting it given the possibility that the value of ARGUMENT is `--`.

If the MSGID contains the `%` format, the arguments are expanded and the value passed in ARGUMENT is assigned. See `i18n_printf` for about format.

#### i18n_nprint ( n_ )

```txt
n_ MSGID MSGID-PLURAL [-n | --] N [ARGUMENT]...
i18n_nprint MSGID MSGID-PLURAL [-n | --] N [ARGUMENT]...
```

Use `n_` to internationalize messages for plurals. It is an alias for the `i18n_nprint` shell function. The `i18n_nprint` shell function performs variable expansion, similar to the `eval_ngettext` shell function in `gettext.sh`.

The third argument is a flag, specify `-n` or `--`. If `-n` is specified, suppresses output of trailing a newline. If `--` is specified, a newline is output. `--` is optional. Since the next argument is numeric, `--` can safely be omitted.

If the fourth argument is `1`, MSGID is used as the message; if it is not `1`, MSGID-PLURAL is used.

If the MSGID contains the `%` format, the arguments are expanded and the value passed in ARGUMENT is assigned. See `i18n_printf` for about format.

#### i18n_sprint ( s_ )

```txt
s_ SCOPE'|'MSGID [-n | --] [ARGUMENT]...
i18n_sprint SCOPE'|'MSGID [-n | --] [ARGUMENT]...
```

#### i18n_nsprint ( ns_ )

```txt
ns_ SCOPE'|'MSGID MSGID-PLURAL [-n | --] N [ARGUMENT]...
i18n_nsprint SCOPE'|'MSGID MSGID-PLURAL [-n | --] N [ARGUMENT]...
```

#### i18n_pprint ( p_ )

```txt
p_ MSGCTXT MSGID [-n | --] [ARGUMENT]...
i18n_pprint MSGCTXT MSGID [-n | --] [ARGUMENT]...
```

#### i18n_npprint ( np_ )

```txt
np_ MSGCTXT MSGID MSGID-PLURAL [-n | --] N [ARGUMENT]...
i18n_npprint MSGCTXT MSGID MSGID-PLURAL [-n | --] N [ARGUMENT]...
```

#### i18n_gettext

```txt
i18n_gettext VARNAME MSGID
```

Get the specified MSGID and assign it to the variable specified by VARNAME. Options are not available and escape sequences are not interpreted　as with `gettext -E`.

#### i18n_ngettext

```txt
i18n_ngettext VARNAME MSGID MSGID-PLURAL N
```

Get the specified MSGID and assign it to the variable specified by VARNAME. Options are not available and escape sequences are not interpreted　as with `ngettext -E`.

#### i18n_sgettext

```txt
i18n_sgettext VARNAME SCOPE'|'MSGID
```

#### i18n_nsgettext

```txt
i18n_nsgettext VARNAME SCOPE'|'MSGID MSGID-PLURAL N
```

#### i18n_pgettext

```txt
i18n_pgettext VARNAME MSGCTXT MSGID
```

#### i18n_npgettext

```txt
i18n_npgettext VARNAME MSGCTXT MSGID MSGID-PLURAL N
```

### Gettext Helpers

Used to assign MSGID to a variable.

#### i18n_build_array

```txt
i18n_build_array VARNAME
```

Used to build variable arrays, arrays, and associative arrays. See below.

```sh
typeset -a ary
i18n_build_array ary
{
  A_ "Array 1"
  A_ "Array 2"
  A_ "Array 3"
}

for i in "${ary[@]}"; do
  _ "$i"
done
```

#### i18n_set_array

```txt
i18n_build_array VARIABLE
```

Used to make positional parameters from an array of variables. Please refer to the `i18n_gettext_a2v` ( `V_` ) example.

#### i18n_gettext_noop ( N_ )

```txt
N_ MSGID
```

It works like the `N_` macro in other languages, but is difficult to use in the shell for two reasons:

- Consecutive trailing newlines disappear when used with command substitution
- Command substitution is poor performance

However, the following example works fine.

```sh
var=$(N_ "Apple")
_ "$var"

set -- "$(N_ "Apple")" "$(N_ "Banana")" "$(N_ "Orange")"
for i in "$@"; do
  _ "$i"
done

ary=("$(N_ "Apple")" "$(N_ "Banana")" "$(N_ "Orange")")
for i in "${ary[@]}"; do
  _ "$i"
done
```

#### i18n_gettext_s2v ( S_ )

```txt
S_ VARNAME MSGID
```

Store the MSGID to the variable.

```sh
S_ var "Hello World."
_ "$var"
```

#### i18n_gettext_a2p ( @_ )

```txt
@_ MSGID
```

Add MSGID to the position parameters.

```sh
set --
{
  @_ "Positional Parameters 1"
  @_ "Positional Parameters 2"
  @_ "Positional Parameters 3"
}
for i in "$@"; do
  _ "$i"
done
```

**NOTE** Because of the dependence on `alias` command, please execute `shopt -s expand_aliases` in bash to make `alias` available.

#### i18n_gettext_a2v ( V_ )

```txt
V_ MSGID
```

Stores multiple MSGIDs in a single variable. When used, use `i18n_set_array` to set it to the position parameters.

```sh
var=''
i18n_build_array var
{
  V_ "Variable Array 1"
  V_ "Variable Array 2"
  V_ "Variable Array 3"
}
i18n_set_array "$var"
for i in "$@"; do
  _ "$i"
done
```

**NOTE** Because of the dependence on `alias` command, please execute `shopt -s expand_aliases` in bash to make `alias` available.

#### i18n_gettext_a2a ( A_ )

```txt
A_ MSGID
```

Stores multiple MSGIDs in a single array. Requires array support in the shell.

```sh
typeset -a ary
i18n_build_array ary
{
  A_ "Array 1"
  A_ "Array 2"
  A_ "Array 3"
}
for i in "${ary[@]}"; do
  _ "$i"
done
```

#### i18n_gettext_a2aa ( AA_ )

```txt
AA_ KEY MSGID
```

Stores multiple MSGIDs in a single associative array. Requires associative array support in the shell.

```sh
typeset -A aary
i18n_build_array aary
{
  AA_ key1 "Associative Array 1"
  AA_ key2 "Associative Array 2"
  AA_ key3 "Associative Array 3"
}
for i in "${aary[@]}"; do
  _ "$i"
done
```

### Utilities

#### i18n_printf

```txt
i18n_printf FORMAT [ARGUMENT]...
```

The values passed in ARGUMENT is expanded according to FORMAT. It internally executes the `printf` command and basically interprets the same format as the `printf` command, but with the following differences.

- Do not interpret backslash escape sequences (only % format is interpreted)
- Supports positional variable references with the format `<number>$`
- Support for output grouping numbers by the `'` flag (e.g. `%'d`)
  - If the `printf` implementation does not support the `'` flag, it is ignored
- Arguments remaining after FORMAT consumes arguments are ignored
- If the argument referenced by FORMAT does not exist, the format remains in place

#### i18n_printfln

```txt
i18n_printfln FORMAT [ARGUMENT]...
```

Same as `i18n_printf` except for the addition of a newline at the end of the output.

#### i18n_echo

```txt
i18n_echo STRING
```

This function is provided as a transition from `gettext.sh`. Those who don't need it don't need to use it. It has the same functionality as the function set in `the $echo` variable of `gettext.sh`, outputting the first argument and newline and not interpreting backslash escape sequences.

If you want, you can have it do the equivalent of `$echo` by doing the following

```txt
echo='i18n_echo'
$echo foo
```

For more information on `$echo`, see [here](https://www.gnu.org/software/gettext/manual/html_node/gettext_002esh.html).

#### i18n_detect_decimal_point

```txt
i18n_detect_decimal_point STRING
```

Re-detect locale-dependent decimal point symbols.

## Environment Variables

### I18N_GETTEXT, I18N_NGETTEXT

Set this environment variable if you want to use different implementations of `gettext` and `ngettext`. It must be set before loading `i18n.sh`.

```sh
if type ggettext >/dev/null 2>&1; then
  I18N_GETTEXT=ggettext
fi

. i18n.sh
```

### I18N_PRINTF

Set this environment variable if you want to use different implementations of `printf`. It must be set before loading `i18n.sh`.

```sh
I18N_PRINTF=/usr/bin/printf

. i18n.sh
```

## Notes on using the xgettext command

To create a message catalog, see [here](https://www.gnu.org/software/gettext/manual/html_node/index.html).

Since the messages to be translated are defined by keywords that differ from the standard, an option to add the keywords must be specified.

```sh
# To add only shorthands as keywords
xgettext -k_:1 -kn_:1,2 -ks_:1 -kns_:1,2 -kp_:1c,2 -knp_:1c,2,3 \
  -kN_ -kS_:2 -k@_ -kV_ -kA_ -kAA_:2 example.sh

# To add all shorthands and functions as keywords
xgettext \
  -k_:1 -kn_:1,2 -ks_:1 -kns_:1,2 -kp_:1c,2 -knp_:1c,2,3 \
  -kN_ -kS_:2 -k@_ -kV_ -kA_ -kAA_:2 \
  -ki18n_gettext:2 -ki18n_ngettext:2,3 \
  -ki18n_sgettext:2 -ki18n_nsgettext:2,3 \
  -ki18n_pgettext:2c,3 -ki18n_nsgettext:2c,3,4 \
  -ki18n_gettext_noop -ki18n_gettext_s2v:2 \
  -ki18n_gettext_a2v -ki18n_gettext_a2a -ki18n_gettext_a2aa:2 \
  example.sh

# In POSIX, -K option is standardized instead of -k option.
# (I don't know of any implementation that can use the -K option)
xgettext -K _:1 -K n_:1,2 example.sh
```
