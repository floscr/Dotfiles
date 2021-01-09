import os
import osproc
import strutils
import sequtils
import strformat
import fp/option
import fp/list
import lib/utils
import sugar

{.experimental.}

let desktopApplicationsDir = expandTilde "/etc/profiles/per-user/floscr/share/applications"
let config = expandTilde("~/.config/cmder/cmd.csv")
let splitChar = ",,,"
let commandSplitChar = "​" # Zero Width Space

type
  ConfigItem = ref object
    description: string
    command: string
    binding: Option[string]

proc commands*(xs: seq[ConfigItem]): string =
  xs
    .mapIt(it.description)
    .join("\n")

proc renderBinding(x: Option[string]): string =
  x
    .fold(
      () => "",
      (x) => &"<span gravity=\"east\" size=\"x-small\" font_style=\"italic\" foreground=\"#5c606b\"> {x}</span>",
    )

proc prettyCommands*(xs: seq[ConfigItem]): string =
  xs
    .mapIt(&"<span>{commandSplitChar}{it.description}{commandSplitChar}</span>{renderBinding(it.binding)}")
    .join("\n")

proc parseConfigLine(x:string): ConfigItem =
  let line = x.split(splitChar)
  return ConfigItem(
    description : line[0],
    command : line[1],
    binding : optionIndex(line, 2).filter((x) => x != ""),
  )

proc parseConfig(): seq[ConfigItem] =
  return config
    .readfile
    .strip()
    .splitLines()
    .map(parseConfigLine)

proc exec(x: string, config = parseConfig()) =
  let y = config
    .findIt(it.description == x.split(splitChar)[1])
  echo y.command

proc parseDesktopFile(f: string): ConfigItem =
  var
    exec: string
    name: string
  for line in lines(f):
    if line.startsWith("Exec"):
      exec = line.split("=")[1].replace(" %u", "").replace(" %U", "")
    if line.startsWith("Name") and name.isEmptyOrWhitespace:
      name = line.split("=")[1]
  ConfigItem(
    description: name,
    command: exec,
    binding: none(string),
  )

proc getDesktopApplications(): any =
  toSeq(walkDir(desktopApplicationsDir, true))
    .filter(x => x.path.endsWith("desktop"))
    .map(c => joinPath(desktopApplicationsDir, c.path) |> parseDesktopFile)

proc main() =
  let config = parseConfig()
  let desktopApplications = getDesktopApplications()
  let items = config.concat(desktopApplications)
  let response = execProcess(&"echo '{items.prettyCommands()}'| rofi -i -levenshtein-sort -dmenu -p \"Run\" -markup-rows").replace("\n", "")
  if response != "":
    let description = response
      .split(commandSplitChar)[1]

    let item = items.findIt(it.description == description)
    echo item
    discard execShellCmd(item.command)

main()
