import std/[osproc, times, streams, strutils]
import strformat
import cligen
import smtp


type 
  CommandResult = object
    command: string
    exitCode: int
    elapsedTime: float
    output: string


proc runCommand(command: string, args: seq[string]): CommandResult =
  let startTime = epochTime()
  let options = {poUsePath, poEvalCommand, poStdErrToStdOut}
  let fullCmd = if args.len > 0: "bash" & " -c \"source ~/.bashrc && " & command & " " & args.join(" ") & "\""
                else: command
  echo &"Running: {fullCmd}"
  let p = startProcess(
    fullCmd,
    args = @[],
    options = options
  )
  defer: close(p)
  let exitCode = p.waitForExit()
  var output: string = ""
  if p.outputStream != nil:
      output = p.outputStream.readAll()
  let endTime = epochTime()
  let elapsedTime = endTime - startTime
  return CommandResult(
    command: fullCmd,
    exitCode: exitCode,
    elapsedTime: elapsedTime,
    output: output
  )


proc sendEmail(outbox: string, password: string, inbox: string, subject: string, body: string) =
  let smtpConn = newSmtp(useSsl = true, debug=true)
  smtpConn.connect("smtp.gmail.com", Port 465)
  smtpConn.auth(outbox, password)
  let msg = createMessage(subject, body)
  smtpConn.sendMail(outbox, @[inbox], $msg)
  smtpConn.close()


proc draftEmail(metrics: CommandResult): (string, string) =
  let subject = &"Your command exited with {metrics.exitCode} in {metrics.elapsedTime:.4g} seconds!"
  let body = &"""
    Command: 
      
  {metrics.command.strip()}

    Exit code: 

  {metrics.exitCode}

    Elapsed time:

  {metrics.elapsedTime:.4f} seconds

    Output:

  {metrics.output}
  """
  return (subject, body)


proc main(
  outbox: string,
  password: string,
  inbox: string,
  command: string,
  args: seq[string] = @[]
) =
  echo &"Outbox: {outbox}"
  echo &"Inbox: {inbox}"
  let result = runCommand(command, args)
  let (subject, body) = draftEmail(result)
  sendEmail(outbox, password, inbox, subject, body)


when isMainModule:
  dispatch(main, help = {
    "outbox": "Sender email",
    "password": "SMTP password",
    "inbox": "Recipient email",
    "command": "Command to execute",
    "args": "Command arguments (space-separated)"
  }, short = {
    "outbox": 'o',
    "password": 'p',
    "inbox": 'i',
    "command": 'c',
    "args": 'a'
  })
